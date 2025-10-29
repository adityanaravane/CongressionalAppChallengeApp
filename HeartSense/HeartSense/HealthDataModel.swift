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

    init() {}
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
        _ = await (bloodGlucose, rate, cholesterol, bloodPressure, ecg)
    }
    
    func fetchECG() async {
        if let ecg = try? await HealthStoreManager.shared.fetchECGWaveform() {
            self.ecg = ecg
        }
    }

    // 4.
    func fetchbloodGlucose() async {
        if let sample = try? await HealthStoreManager.shared.fetchMostRecentSample(for: .bloodGlucose) {
            let value = sample.quantity.doubleValue(for: HKUnit.count())
            self.bloodGlucose = Int(value)
        }
    }

    func fetchHeartRate() async {
        var heartRateValue : Double = 0
        var walkingHeartRate: Double = 0
        var restingHeartRate: Double = 0
        if let sample = try? await HealthStoreManager.shared.fetchMostRecentSample(for: .heartRate) {
            heartRateValue = sample.quantity
                .doubleValue(for: HKUnit.count())
            
        }
        
        if let sample = try? await HealthStoreManager.shared.fetchMostRecentSample(for: .walkingHeartRateAverage) {
            walkingHeartRate = sample.quantity
                .doubleValue(for: HKUnit.count())
            
        }
        
        if let sample = try? await HealthStoreManager.shared.fetchMostRecentSample(for: .restingHeartRate) {
            restingHeartRate = sample.quantity
                .doubleValue(for: HKUnit.count())
            
        }
        
        self.heartRate = Int(max(heartRateValue, walkingHeartRate, restingHeartRate))
    }

    func fetchbloodPressure() async {
        if let sample = try? await HealthStoreManager.shared.fetchMostRecentSample(for: .bloodPressureSystolic) {
            let value = sample.quantity.doubleValue(for: HKUnit.count())
            self.bloodPressure = Int(value)
        }
    }
    
    func fetchcholesterol() async {
        if let sample = try? await HealthStoreManager.shared.fetchMostRecentSample(for: .dietaryCholesterol) {
            let value = sample.quantity.doubleValue(for: HKUnit.count())
            self.cholesterol = Int(value)
        }
    }
    
    func fetchGender() async {
        self.Gender = HealthStoreManager.shared.fetchBiologicalSex()
    }
    
    func fetchAge() async {
        self.Age = HealthStoreManager.shared.fetchBiologicalAge()
    }
}
