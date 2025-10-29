//
//  BasicInfo.swift
//  HeartSense
//
//  Created by Aditya Naravane on 10/27/25.
//

import Foundation
import SwiftUI


struct BasicInfo: View {
    
    @State private var healthData = HealthDataModel()
    
    // Input fields as Strings to bind to TextFields
    @State private var ageInput: String = ""
    @State private var sexInput: String = ""
    @State private var cpInput: String = ""
    @State private var trestbpsInput: String = ""
    @State private var cholInput: String = ""
    @State private var fbsInput: String = ""
    @State private var restecgInput: String = ""
    @State private var thalachInput: String = ""
    @State private var exangInput: String = ""
    @State private var oldpeakInput: String = ""
    @State private var slopeInput: String = ""
    @State private var caInput: String = ""
    

    // Result text
    @State private var resultText: String = ""

    // Model runner
    let nn = HeartModelRunner()

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Inputs")) {
                    inputField(title: "age", text: $ageInput)
                    inputField(title: "sex", text: $sexInput)
                    inputField(title: "cp", text: $cpInput)
                    inputField(title: "trestbps", text: $trestbpsInput)
                    inputField(title: "chol", text: $cholInput)
                    inputField(title: "fbs", text: $fbsInput)
                    inputField(title: "restecg", text: $restecgInput)
                    inputField(title: "thalach", text: $thalachInput)
                    inputField(title: "exang", text: $exangInput)
                    inputField(title: "oldpeak", text: $oldpeakInput)
                    inputField(title: "slope", text: $slopeInput)
                    inputField(title: "ca", text: $caInput)
                }

                Section {
                    Button("Predict") {
                        runPrediction()
                    }
                    .buttonStyle(.borderedProminent)

                    if !resultText.isEmpty {
                        Text(resultText)
                            .font(.headline)
                            .foregroundStyle(resultText.contains("likely") ? .red : .green)
                    }
                }
            }
            .navigationTitle("Health Data")
        }
    }

    // MARK: - Helpers

    private func inputField(title: String, text: Binding<String>) -> some View {
        HStack {
            Text(title)
            TextField(title, text: text)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
        }
    }

    private func runPrediction() {
        // Safely parse inputs; default to 0 if invalid
        let age = Double(ageInput) ?? 0
        let sex = Double(sexInput) ?? 0
        let cp = Double(cpInput) ?? 0
        let trestbps = Double(trestbpsInput) ?? 0
        let chol = Double(cholInput) ?? 0
        let fbs = Double(fbsInput) ?? 0
        let restecg = Double(restecgInput) ?? 0
        let thalach = Double(thalachInput) ?? 0
        let exang = Double(exangInput) ?? 0
        let oldpeak = Double(oldpeakInput) ?? 0
        let slope = Double(slopeInput) ?? 0
        let ca = Double(caInput) ?? 0

        let threshold = 0.5
        let result = nn?.predictManual(
            age: age,
            sex: sex,
            cp: cp,
            trestbps: trestbps,
            chol: chol,
            fbs: fbs,
            restecg: restecg,
            thalach: thalach,
            exang: exang,
            oldpeak: oldpeak,
            slope: slope,
            ca: ca,
            threshold: threshold
        )

        // Assume result is a Bool or something convertible; if optional, unwrap safely
        if let isLikely = result as? Bool {
            resultText = isLikely ? "Heart disease likely" : "Heart disease unlikely"
        } else if let isLikely = result as? NSNumber { // fallback if model returns NSNumber
            resultText = isLikely.boolValue ? "Heart disease likely" : "Heart disease unlikely"
        } else if let isLikely = result as? Int {
            resultText = isLikely != 0 ? "Heart disease likely" : "Heart disease unlikely"
        } else {
            // If model returns probability Double, compare to threshold
            if let probability = result as? Double {
                resultText = probability >= threshold ? "Heart disease likely" : "Heart disease unlikely"
            } else {
                resultText = "Unable to determine result"
            }
        }
    }
}

#Preview {
    BasicInfo()
}

