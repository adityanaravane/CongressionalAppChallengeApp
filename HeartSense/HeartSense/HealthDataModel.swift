//
//  HealthDataModel.swift
//  HeartSense
//
//  Created by Aditya Naravane on 10/27/25.
//

import Foundation
import HealthKit
import Observation

@MainActor
@Observable class HealthDataModel {
    
    // 1.
    var bloodGlucose: Int = 0
    var heartRate: Int = 0
    var bloodPressure: Int = 0
    var cholesterol: Int = 0
    var Age: Int = 0
    var Gender: String = ""
    var isAuthorized: Bool = false
    var errorMessage: String?
    var ecg : ECGWaveform = ECGWaveform()

    //init() {}
     //   Task { await requestAuthorization() }
    //}

    // 2.
    func requestAuthorization() async {
        do {
            let success = try await HealthStoreManager.shared.requestAuthorization()
                self.isAuthorized = success
            if success {
                await fetchAllHealthData()
                print("health data authorized!!")
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    // 3.
    func fetchAllHealthData() async {
        async let bloodGlucose: () = fetchbloodGlucose()
        async let rate: ()  = fetchHeartRate()
        async let bloodPressure: () = fetchbloodPressure()
        async let cholesterol : () = fetchcholesterol()
        async let ecg : () = fetchECG()
        async let Age : () = fetchAge()
        async let Gender : () = fetchGender()
        _ = await (bloodGlucose, rate, cholesterol, bloodPressure, Age, Gender,ecg)
    }
    
    func fetchECG() async {
        if let ecg = try? await HealthStoreManager.shared.fetchECGWaveform() {
            self.ecg = ecg
        }
    }

    // 4.
    func fetchbloodGlucose() async {
        let bloodGlucoseUnit = HKUnit(from: "mg/dL")
        if let sample = try? await HealthStoreManager.shared.fetchMostRecentSample(for: .bloodGlucose) {
            let value = sample.quantity.doubleValue(for: bloodGlucoseUnit)
            self.bloodGlucose = Int(value)
        }
    }

    func fetchHeartRate() async {
        var heartRateValue : Double = 0
        var walkingHeartRate: Double = 0
        var restingHeartRate: Double = 0
        let heartRateUnit = HKUnit(from: "count/min")
        if let sample = try? await HealthStoreManager.shared.fetchMostRecentSample(for: .heartRate) {
            heartRateValue = sample.quantity
                .doubleValue(for: heartRateUnit)
            
        }
        
        if let sample = try? await HealthStoreManager.shared.fetchMostRecentSample(for: .walkingHeartRateAverage) {
            walkingHeartRate = sample.quantity
                .doubleValue(for: heartRateUnit)
            
        }
        
        if let sample = try? await HealthStoreManager.shared.fetchMostRecentSample(for: .restingHeartRate) {
            restingHeartRate = sample.quantity
                .doubleValue(for: heartRateUnit)
            
        }
        
        self.heartRate = Int(max(heartRateValue, walkingHeartRate, restingHeartRate))
    }

    func fetchbloodPressure() async {
        let bloodPressureUnit = HKUnit(from: "mmHg")
        if let sample = try? await HealthStoreManager.shared.fetchMostRecentSample(for: .bloodPressureSystolic) {
            let value = sample.quantity.doubleValue(for: bloodPressureUnit)
            self.bloodPressure = Int(value)
        }
    }
    
    func fetchcholesterol() async {
        //let cholesterolUnit = HKUnit(from: "mg")
        //if let sample = try? await HealthStoreManager.shared.fetchMostRecentSample(for: .dietaryCholesterol) {
        //    let value = sample.quantity.doubleValue(for: cholesterolUnit)
        //    self.cholesterol = Int(value)
        //}
        
        if let sample = try? await HealthStoreManager.shared.fetchCholesterol(){
            self.cholesterol = Int(sample)
            print("Got cholesterol: \(self.cholesterol)")
        }
    }
    
    func fetchGender() async {
        self.Gender = HealthStoreManager.shared.fetchBiologicalSex()
    }
    
    func fetchAge() async {
        self.Age = HealthStoreManager.shared.fetchBiologicalAge()
        print("Got age: \(self.Age)")
    }
}
