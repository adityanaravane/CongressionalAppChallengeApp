//
//  nnrunner.swift
//  HeartSense
//
//  Created by Aditya Naravane on 10/25/25.
//

import Foundation
import CoreML

// If your generated class is capitalized `Heart`, change the alias below to `typealias HeartGeneratedModel = Heart`
typealias HeartGeneratedModel = heart

/// Runner for the Core ML model exported from ONNX (e.g., `heart.mlmodel`).
/// Feature order expected:
/// [age, sex, cp, trestbps, chol, fbs, restecg, thalach, exang, oldpeak, slope, ca]
final class HeartModelRunner {
    private let model: HeartGeneratedModel
    private let inputName: String
    private let inputShape: [Int]                // e.g., [1, 12]
    private let inputDataType: MLMultiArrayDataType

    init?() {
        do {
            let config = MLModelConfiguration()
            self.model = try HeartGeneratedModel(configuration: config)

            // Introspect the (first) input to get name/shape/dtype
            let inputs = model.model.modelDescription.inputDescriptionsByName
            guard let (name, desc) = inputs.first,
                  let mac = desc.multiArrayConstraint else {
                print("Model input not found or not a MultiArray.")
                return nil
            }

            self.inputName = name
            // Replace any flexible (-1) dims with 1 (batch)
            self.inputShape = mac.shape.map { max($0.intValue, 1) }
            self.inputDataType = mac.dataType

            print("Model input '\(name)' expects shape \(inputShape) (rank \(inputShape.count)) dtype \(inputDataType)")
        } catch {
            print("Failed to load model: \(error)")
            return nil
        }
    }

    // MARK: - Public API

    /// Returns `true`/`false` using `threshold` on positive-class probability, or `nil` if parsing fails.
    func predictManual(
        age: Double, sex: Double, cp: Double, trestbps: Double, chol: Double,
        fbs: Double, restecg: Double, thalach: Double, exang: Double,
        oldpeak: Double, slope: Double, ca: Double,
        threshold: Double = 0.5
    ) -> Bool? {
        guard let p = predictProbability(
            age: age, sex: sex, cp: cp, trestbps: trestbps, chol: chol,
            fbs: fbs, restecg: restecg, thalach: thalach, exang: exang,
            oldpeak: oldpeak, slope: slope, ca: ca
        ) else { return nil }
        print(p)
        return p >= threshold
    }
    
    func predict(userdata userData: AllData) -> Bool? {
        let age: Double = Double(userData.healthkitInfo.age)
        let sex: Double = (userData.healthkitInfo.gender == .female) ? 1.0 : 0.0
        let cp: Double = Double(userData.chestPain.rawValue)
        let trestbps: Double = Double(userData.healthkitInfo.heartRate)
        let chol: Double = Double(userData.healthkitInfo.cholesterol)
        let fbs: Double = userData.healthkitInfo.bloodGlucose > 120 ? 1.0 : 0.0
        let thalach: Double = Double(userData.healthkitInfo.heartRate)
        let exang: Double = userData.exerciseInducedPain ? 1.0 : 0.0
        let oldpeak: Double = Double(userData.stDepression)
        let slope: Double = Double(userData.stSlope)
        let ca: Double = Double(userData.numVessels)
        var restecg: Double = 0.0
        if userData.ecgResults == .normal {
            restecg = 0.0
        }
        else if userData.ecgResults == .abnormal {
             restecg = 1.0
            
        } else {
             restecg = 0.0
        }
        
        print("age: \(age)")
        print("sex: \(sex)")
        print("cp: \(cp)")
        print("trestbps: \(trestbps)")
        print("chol: \(chol)")
        print("fbs: \(fbs)")
        print("restecg: \(restecg)")
        print("thalach: \(thalach)")
        print("exang: \(exang)")
        print("oldpeak: \(oldpeak)")
        print("slope: \(slope)")
        print("ca: \(ca)")
        print("restecg: \(restecg)")
        
        return predictManual(
            age: age, sex: sex, cp: cp, trestbps: trestbps, chol: chol,
            fbs: fbs, restecg: restecg, thalach: thalach, exang: exang,
            oldpeak: oldpeak, slope: slope, ca: ca, threshold: 0.5
        )
    }

    /// Returns positive-class probability in [0,1] if parseable; otherwise `nil`.
    func predictProbability(
        age: Double, sex: Double, cp: Double, trestbps: Double, chol: Double,
        fbs: Double, restecg: Double, thalach: Double, exang: Double,
        oldpeak: Double, slope: Double, ca: Double
    ) -> Double? {

        let features: [Double] = [age, sex, cp, trestbps, chol, fbs, restecg, thalach, exang, oldpeak, slope, ca]

        // Build input MLMultiArray with correct rank/shape/dtype (e.g., [1,12])
        guard let inputArray = makeInputArray(features) else { return nil }

        do {
            // Use a generic provider keyed by the discovered input name
            let provider = try MLDictionaryFeatureProvider(dictionary: [inputName: MLFeatureValue(multiArray: inputArray)])
            let out = try model.model.prediction(from: provider)
            print("Heart model prediction: \(out)")
            // Parse to probability
            return parseOutputToProbability(out)
        } catch {
            print("Heart model prediction failed: \(error)")
            return nil
        }
    }

    // MARK: - Internals

    private func makeInputArray(_ features: [Double]) -> MLMultiArray? {
        let totalCount = inputShape.reduce(1, *)
        var buffer = Array<Double>(repeating: 0, count: totalCount)
        for i in 0..<min(features.count, totalCount) { buffer[i] = features[i] }

        let shapeNS = inputShape.map { NSNumber(value: $0) }
        guard let arr = try? MLMultiArray(shape: shapeNS, dataType: inputDataType) else {
            print("Failed to create MLMultiArray shape \(inputShape) dtype \(inputDataType)")
            return nil
        }
        // Write via NSNumber (Core ML converts to the underlying dtype: float16/32/double)
        for i in 0..<totalCount { arr[i] = NSNumber(value: buffer[i]) }
        return arr
    }

    /// Heuristically converts a Core ML prediction output to a positive-class probability.
    /// Handles:
    ///  - "classProbability" / "classLabel" (classifier)
    ///  - "output" (scalar)
    ///  - Single anonymous output key such as "var_15" (scalar or vector)
    private func parseOutputToProbability(_ out: MLFeatureProvider) -> Double? {
        // 1) Standard classifier
        if let dict = out.featureValue(for: "classProbability")?.dictionaryValue as? [String: Double] {
            if let p = dict["1"] ?? dict["yes"] ?? dict["positive"] { return clamp01(p) }
        }
        if let label = out.featureValue(for: "classLabel")?.stringValue {
            // If only a label exists, map to 0/1
            return (label == "1" || label.lowercased() == "yes" || label.lowercased() == "positive") ? 1.0 : 0.0
        }

        // 2) Regressor/single-output under a conventional name
        if let p = out.featureValue(for: "output")?.doubleValue {
            return asProbability(p)
        }

        // 3) ONNX → Core ML anonymous output (e.g., "var_15")
        if let onlyKey = out.featureNames.first,
           let fv = out.featureValue(for: onlyKey) {

            // Scalar number case
            if let d = fv.asDouble {
                return asProbability(d)
            }

            // MultiArray case
            if fv.type == .multiArray, let ma = fv.multiArrayValue {
                let n = ma.count
                func val(_ i: Int) -> Double { ma[i].doubleValue }

                if n == 1 { return asProbability(val(0)) }

                if n == 2 {
                    let a = val(0), b = val(1)
                    let sum = a + b
                    // If sums ~1, treat as probs; else argmax as 0/1
                    if approximatelyOne(sum) { return clamp01(b) }
                    return b > a ? 1.0 : 0.0
                }

                // General vector: if sums ~1, take last as P(positive); else argmax==last?
                var s = 0.0, maxV = -Double.infinity, maxI = -1
                for i in 0..<n { let v = val(i); s += v; if v > maxV { maxV = v; maxI = i } }
                if approximatelyOne(s) { return clamp01(val(n - 1)) }
                return (maxI == n - 1) ? 1.0 : 0.0
            }
        }

        print("Unexpected model output keys: \(Array(out.featureNames))")
        return nil
    }
    
}

// MARK: - Helpers

private func sigmoid(_ x: Double) -> Double {
    if x >= 0 { let e = exp(-x); return 1 / (1 + e) }
    let e = exp(x)
    return e / (1 + e)
}

private func asProbability(_ x: Double) -> Double {
    // If outside [0,1], assume it's a logit and apply sigmoid
    if x < 0 || x > 1 { return sigmoid(x) }
    return clamp01(x)
}

private func clamp01(_ p: Double) -> Double {
    return max(0.0, min(1.0, p))
}

private func approximatelyOne(_ s: Double, tol: Double = 1e-2) -> Bool {
    return abs(s - 1.0) <= tol
}

private extension MLFeatureValue {
    /// Returns a numeric scalar if this feature is `.double` or `.int64`, else `nil`.
    var asDouble: Double? {
        switch self.type {
        case .double: return self.doubleValue
        case .int64:  return Double(self.int64Value)
        default:      return nil
        }
    }
}

