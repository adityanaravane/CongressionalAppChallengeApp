//
//  HealthStoreManager.swift
//  HeartSense
//
//  Created by Aditya Naravane on 10/27/25.
//

import Foundation
import HealthKit

@MainActor
class HealthStoreManager {

    // 1.
    static let shared = HealthStoreManager()
    private var healthStore : HKHealthStore?

    private init() {}

    // 2.
    func requestAuthorization() async throws -> Bool {
        // Ensure HealthKit is available on this device
        
        guard HKHealthStore.isHealthDataAvailable() else { print("health data is not available"); return false }
        print("health data is available")

        self.healthStore = HKHealthStore()
        // Define the types we want to read
        let readTypes: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .bloodGlucose)!,
            HKObjectType.quantityType(forIdentifier: .dietaryCholesterol)!,
            HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
            HKObjectType.quantityType(forIdentifier: .walkingHeartRateAverage)!,
            HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)!,
            HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic)!,
            HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!,
            HKObjectType.characteristicType(forIdentifier: .biologicalSex)!,
            HKObjectType.clinicalType(forIdentifier: .labResultRecord)!,
            HKObjectType.electrocardiogramType()
        ]

        print("requesting Authorization")
        let promptStatus: Bool = try await withCheckedThrowingContinuation { continuation in
            healthStore?.requestAuthorization(toShare: [], read: readTypes) { success, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: success)
                }
            }
        }
        
        if promptStatus { print("Prompt successful") } else { print("Authorization prompt failed"); return false }
        
        //now check if all data was authorized
        let allAuthorized: Bool = true
        //readTypes.forEach { t in
        //    if !checkAuthorizationStatus(for: t) {
        //        print(t.identifier)
         //       allAuthorized = false
         //   }
        //}
        
        //if !allAuthorized { print("Not all health data was authorized, setting authorization status to false") }
        
        return allAuthorized
        
    }
    
    func checkAuthorizationStatus(for type: HKObjectType) -> Bool {
        let status : HKAuthorizationStatus? = healthStore?.authorizationStatus(for: type)
        return (status == .sharingAuthorized)
    }

    // 3.
    func fetchMostRecentSample(for identifier: HKQuantityTypeIdentifier) async throws -> HKQuantitySample? {
        // Get the quantity type for the identifier
        guard let quantityType = HKObjectType.quantityType(forIdentifier: identifier) else {
            return nil
        }

        // Query for samples from start of today until now, sorted by end date descending
        let predicate = HKQuery.predicateForSamples(
            withStart: Date.distantPast,
            end: Date(),
            options: .strictEndDate
        )
        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierEndDate,
            ascending: false
        )

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: quantityType,
                predicate: predicate,
                limit: 1,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: samples?.first as? HKQuantitySample)
                }
            }
            healthStore?.execute(query)
        }
    }
    
    func fetchCholesterol() async throws -> Int? {
        
        guard let recordType = HKObjectType.clinicalType(forIdentifier: .labResultRecord) else {
            fatalError("*** Unable to fetch cholesterol type ***")
        }

        return try await withCheckedThrowingContinuation { continuation in
            let labQuery = HKSampleQuery(sampleType: recordType, predicate: nil, limit: 1, sortDescriptors: nil) { (_, samples, error) in
                
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    guard let actualSamples = samples else {
                        // Handle the error here.
                        print("*** An error occurred: \(error?.localizedDescription ?? "nil") ***")
                        return
                    }
                    
                    let labResults = actualSamples[0] as? HKClinicalRecord
                    guard let fhirRecord = labResults?.fhirResource else {
                        print("No FHIR record found!")
                        return
                    }


                    do {
                        let jsonDictionary = try JSONSerialization.jsonObject(with: fhirRecord.data, options: [])
                        
                        if let object = jsonDictionary as? [String: Any] {
                            //print(jsonDictionary)
                     
                            let valueQuantity = object["valueQuantity"] as! [String: AnyObject]
                            print(valueQuantity)
                            let value = valueQuantity["value"] as! Double
                            print("Cholesterol: \(Int(value))")
                            continuation.resume(returning: Int(value))
                            
                        }
                        else {
                            print("Unable to parse JSON dictionary.")
                            return
                        }
                    }
                    catch let error {
                        print("*** An error occurred while parsing the FHIR data: \(error.localizedDescription) ***")
                        continuation.resume(throwing: error)
                    }
                }
            }
            
            healthStore?.execute(labQuery)
        }
        
    }
    
    func fetchECGWaveform() async throws -> ECGWaveform? {
        guard let ecgSample = try await fetchECG() else { print("fetchECG failed"); return nil }
        
        return try await withCheckedThrowingContinuation { continuation in
            var waveform = ECGWaveform()

            let voltageQuery = HKElectrocardiogramQuery(ecgSample) { query, result in
                switch result {
                case .measurement(let measurement):
                    if let voltageQuantity = measurement.quantity(for: .appleWatchSimilarToLeadI) {
                        var ecgData : ecgData = ecgData()
                        ecgData.time = Double(measurement.timeSinceSampleStart)
                        ecgData.voltage = voltageQuantity.doubleValue(for: HKUnit.voltUnit(with: .milli))
                        
                        
                        if ecgData.time < 2 {
                            waveform.ecgData.append(ecgData)
                        }
                        
                        print("time: \(measurement.timeSinceSampleStart), voltage: \(voltageQuantity.doubleValue(for: HKUnit.voltUnit(with: .milli)))")
                        //waveform.timeValues.append(Double(measurement.timeSinceSampleStart))
                        //waveform.voltageValues.append(voltageQuantity.doubleValue(for: HKUnit.voltUnit(with: .milli)))
                    }
                case .done:
                    continuation.resume(returning: waveform)
                case .error(let error):
                    continuation.resume(throwing: error)
                @unknown default:
                    continuation.resume(throwing: NSError(domain: "HealthStoreManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown ECG query result"]))
                }
            }

            healthStore?.execute(voltageQuery)
        }
    }
    
    
    func fetchECG() async throws -> HKElectrocardiogram? {
        // Query for samples from start of today until now, sorted by end date descending
        let predicate = HKQuery.predicateForSamples(
            withStart: Date.distantPast,
            end: Date.distantFuture
        )
        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierEndDate,
            ascending: false
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: HKObjectType.electrocardiogramType(),
                predicate: predicate,
                limit: 1,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, error in
                if let error = error {
                    print("Not able to get ECG: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                } else {
                    print("Got ECG")
                    continuation.resume(returning: samples?.first as? HKElectrocardiogram)
                }
            }
            healthStore?.execute(query)
        }
    }
    
    func fetchBiologicalSex() -> String {
        var sex = "male" //default
        do{
            let biologicalSexObject = try healthStore?.biologicalSex()
            let biologicalSex = biologicalSexObject?.biologicalSex
            switch biologicalSex {
                case .female:
                    sex = "female"
                case .male:
                    sex = "male"
                case .other:
                    sex = "other"
                case .notSet:
                    sex = "not set"
                default:
                    sex = "male"
            }
            
        }catch{
        }
        return sex
    }
    
    func fetchBiologicalAge() -> Int {
        var age: Int = 0
        do {
            // Use the non-deprecated API to fetch date of birth components
            if let components = try healthStore?.dateOfBirthComponents(),
               let birthDate = Calendar.current.date(from: components) {
                print(components)
                let ageComponents = Calendar.current.dateComponents([.year], from: birthDate, to: Date())
                age = ageComponents.year ?? 0
                print(ageComponents)
            }
        } catch {
            print("Error in fetching date of birth")
        }
        return age
    }
    
}
