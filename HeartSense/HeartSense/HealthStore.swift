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
    
//    func fetchAge(completion: @escaping(double, Error?) -> Void) {
//        let dobType = HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!
//        let currentYear = Calendar.current.component(.year, from: Date())
//        
//    }
}

