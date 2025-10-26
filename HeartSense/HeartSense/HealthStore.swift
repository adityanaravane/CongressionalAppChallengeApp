//
//  HealthStore.swift
//  HeartSense
//
//  Created by Aditya Naravane on 10/25/25.
//

import HealthKit

class HealthStore {
    let healthstore = HKHealthStore()
    
    //request permission
    func requestAuthorization(completion: @escaping(Bool, Error?) -> Void) {
        let stepcountType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let heartrateType = HKObjectType.quantityType(forIdentifier: .restingHeartRate)!
        let dobType = HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!
        let sex = HKObjectType.characteristicType(forIdentifier: .biologicalSex)!
        let cholesterolType = HKObjectType.quantityType(forIdentifier: .dietaryCholesterol)!
        let maxHeartRateType = HKObjectType.quantityType(forIdentifier: .walkingHeartRateAverage)!
        let bloodGlucose = HKObjectType.quantityType(forIdentifier: .bloodGlucose)!
        
        
        let typesToRead: Set<HKObjectType> = [stepcountType, heartrateType, dobType, sex, cholesterolType, maxHeartRateType, bloodGlucose]
        
        healthstore.requestAuthorization(toShare: nil, read: typesToRead) { (success, error) in
            completion(success, error)
        }
        
    }
    
    
    //fetch stepcount data
    
    func fetchStepCount(completion: @escaping(Double, Error?) -> Void) {
        let stepType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            let stepCount = result?.sumQuantity()?.doubleValue(for: .count()) ?? 0
            DispatchQueue.main.async {
                completion(stepCount, error)
            }
        }
        healthstore.execute(query)
    }
    
    func fetchAge(completion: @escaping (Int?, Error?) -> Void) {
        do {
            // Retrieve date of birth components from HealthKit
            let components = try healthstore.dateOfBirthComponents()
            // Build a date from the components using the current calendar
            if let dob = Calendar.current.date(from: components) {
                // Compute full years between dob and now
                let ageComponents = Calendar.current.dateComponents([.year], from: dob, to: Date())
                let age = ageComponents.year
                DispatchQueue.main.async {
                    completion(age, nil)
                }
            } else {
                // Could not form a date from components
                DispatchQueue.main.async {
                    let error = NSError(domain: "HealthStore", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to construct date of birth from components."])
                    completion(nil, error)
                }
            }
        } catch {
            // Propagate HealthKit error (e.g., not authorized or unavailable)
            DispatchQueue.main.async {
                completion(nil, error)
            }
        }
    }
}

