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
        let heartrateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let calorieType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        
        let typesToRead: Set<HKObjectType> = [stepcountType, heartrateType, calorieType]
        
        healthstore.requestAuthorization(toShare: nil, read: typesToRead) { (success, error) in
            completion(success, error)
        }
        
    }
    
    
    //fetch stepcount data
    
    func fetchStepCount(completion: @escaping(Double, Error?) -> Void) {
        let stepType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantitytype: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) {
            _, result, _ in
            let stepCount = result?.sumQuantity().doubleValue(for: .count()) ?? 0
            DispatchQueue.main.async {
                completion(stepCount)
            }
            
            
            
        }
        healthstore.execute(query)
    }
}
