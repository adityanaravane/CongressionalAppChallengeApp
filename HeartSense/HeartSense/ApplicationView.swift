//
//  ApplicationView.swift
//  Cardian
//
//  Created by Aditya Naravane on 10/28/25.
//

import Foundation
import SwiftUI

enum Gender: String, CaseIterable, Identifiable, Hashable {
    case male
    case female
    var id: String { rawValue }
}

struct HealthKitData {
    var age: Int = Int.random(in: 35...75)
    var ageAvailable: Bool = false
    var gender: Gender = .male
    var genderAvailable: Bool = false
    var heartRate: Int = Int.random(in: 50...200)
    var heartRateAvailable: Bool = false
    var bloodPressure: Int = Int.random(in: 70...150)
    var boodPressureAvailable: Bool = false
    var cholesterol: Int = Int.random(in: 150...300)
    var cholesterolAvailable: Bool = false
    var bloodGlucose: Int = Int.random(in: 70...200)
    var bloodGlucoseAvailable: Bool = false
    var authorized: Bool = false
    var ecgData: ECGWaveform = ECGWaveform()
}

enum ChestPainType: String, CaseIterable, Identifiable, Hashable {
    case nopain
    case mild
    case moderate
    case severe
    
    var id: String{ rawValue }
    var title: String {
        switch self {
        case .nopain: return "No Pain"
        case .mild: return "Mild"
        case .moderate: return "Moderate"
        case .severe: return "Severe"
        }
    }
}

enum ECGResultsType :  String, CaseIterable, Identifiable, Hashable{
    case normal
    case abnormal
    var id: String { rawValue }
    var title: String {
        switch self {
        case .normal: return "Normal"
        case .abnormal: return "Abnormal"
        }
    }
}

struct AllData {
    var healthkitInfo: HealthKitData = HealthKitData()
    var ecgResults: ECGResultsType = .normal
    var chestPain: ChestPainType = .nopain
    var exerciseInducedPain: Bool = false
    var stDepression: Double = Double.random(in: 0.0...5.6)
    var stSlope: Int = Int.random(in: 0...2)
    var numVessels: Int = Int.random(in: 0...3)
}

struct HealthInfoView: View {
    @Binding var healthInfo: HealthKitData

    var body: some View {
            Form {
                Section(header: Text("Basic Information")) {
                    Stepper(value: $healthInfo.age, in: 35...75, step: 1) {
                        HStack {
                            if healthInfo.ageAvailable {
                                Image("applehealthkit")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .scaledToFill()
                                    .clipped()
                            }
                            Text("Age")
                            Spacer()
                            Text("\(healthInfo.age)")
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    HStack{
                        if healthInfo.genderAvailable {
                            Image("applehealthkit")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .scaledToFill()
                                .clipped()
                        }
                        Picker("Gender", selection: $healthInfo.gender) {
                            ForEach(Gender.allCases) { g in
                                Text(g.rawValue.capitalized).tag(g)
                            }
                        }
                    }
                }.padding(1)
                
                Section(header: Text("Health Information")) {
                    Stepper(value: $healthInfo.heartRate, in: 50...200, step: 1) {
                        HStack {
                            if healthInfo.heartRateAvailable {
                                Image("applehealthkit")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .scaledToFill()
                                    .clipped()
                            }
                            Text("Maximum Heart Rate")
                            Spacer()
                            Text("\(healthInfo.heartRate)")
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Stepper(value: $healthInfo.bloodPressure, in:70...200, step:1){
                        HStack{
                            if healthInfo.boodPressureAvailable {
                                Image("applehealthkit")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .scaledToFill()
                                    .clipped()
                            }
                            Text("Blood Pressure")
                            Spacer()
                            Text("\(healthInfo.bloodPressure)")
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Stepper(value:$healthInfo.bloodGlucose, in:70...200, step:1){
                        HStack{
                            if healthInfo.bloodGlucoseAvailable {
                                Image("applehealthkit")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .scaledToFill()
                                    .clipped()
                            }
                            Text("Blood Glucose")
                            Spacer()
                            Text("\(healthInfo.bloodGlucose)")
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Stepper(value: $healthInfo.cholesterol, in:150...300, step:1){
                        HStack{
                            if healthInfo.cholesterolAvailable {
                                Image("applehealthkit")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .scaledToFill()
                                    .clipped()
                            }
                            Text("Cholesterol")
                            Spacer()
                            Text("\(healthInfo.cholesterol)")
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                }.padding(1)
            }
        }
}

struct OtherSymptomsView: View {
    @Binding var data: AllData

    var body: some View {
        Form{
            Section(header: Text("Chest Pain")){
                Toggle(isOn: $data.exerciseInducedPain){
                    VStack{
                        Text("Do you experience chest pain during or after physical exertion?")
                        Spacer()
                    }
                }
                
                Picker("Chest pain level", selection: $data.chestPain){
                    ForEach(ChestPainType.allCases){ g in
                        Text(g.title).tag(g)
                    }
                }
                    
            }.padding(1)
            
            Section(header: Text("ECG Results")){
                Picker("ECG Result type", selection: $data.ecgResults){
                    ForEach(ECGResultsType.allCases){ g in
                        Text(g.title).tag(g)
                    }
                }
            }
            
            Section(header: Text("Latest Electrocardiogram")){
                
                ECGView(ecg:$data.healthkitInfo.ecgData)
                
            }
        }
    }
}

struct ResultView: View {
    @Binding var data: AllData

    var body: some View {
        VStack(spacing: 16) {
            Text("Results")
        }
        .padding()
    }
}

enum ApplicationStep {
    case healthInfo
    case otherSymptoms
    case review

    var title: String {
        switch self {
        case .healthInfo: return "Preliminary Details"
        case .otherSymptoms: return "Other Symptoms"
        case .review: return "View Results"
        }
    }
}

struct ApplicationView: View {
    @State private var healthData = HealthDataModel()
    @State private var currentStep: ApplicationStep = .healthInfo
    @State private var data: AllData = AllData()
    @State private var isLoading: Bool = true
    @State private var authorized: Bool = false

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading health data...")
            } else {
                
                switch currentStep {
                case .healthInfo:
                    HealthInfoView(healthInfo: $data.healthkitInfo)
                        .toolbar {
                            ToolbarItem(placement: .bottomBar) {
                                Button(ApplicationStep.otherSymptoms.title) { currentStep = .otherSymptoms }
                            }
                        }
                case .otherSymptoms:
                    OtherSymptomsView(data: $data)
                        .toolbar {
                            ToolbarItem(placement:.bottomBar){
                                Button(ApplicationStep.healthInfo.title){currentStep = .healthInfo}
                            }
                            ToolbarItem(placement: .bottomBar) {
                                Button(ApplicationStep.review.title) { currentStep = .review }
                            }
                        }
                case .review:
                    ResultView(data: $data)
                        .toolbar {
                            ToolbarItem(placement:.bottomBar){
                                Button(ApplicationStep.otherSymptoms.title){currentStep = .otherSymptoms}
                            }
                        }
                }
            }
        }
        .navigationTitle(currentStep.title)
        .navigationBarTitleDisplayMode(.large)
        .task { // Use .task to trigger async operations when the view appears
            await healthData.requestAuthorization()
            self.initializeData()
        }
    }
 
    func initializeData() {
        authorized = healthData.isAuthorized
        data.healthkitInfo.authorized = healthData.isAuthorized
        print("Authorized: \(authorized)")
        print("Authorized inside healthInfo: \(data.healthkitInfo.authorized)")
        
        if(healthData.heartRate > 0){
            data.healthkitInfo.heartRate = healthData.heartRate
            data.healthkitInfo.heartRateAvailable = true
        }
        if(healthData.bloodPressure > 0){
            data.healthkitInfo.bloodPressure = healthData.bloodPressure
            data.healthkitInfo.boodPressureAvailable = true
        }
        if(healthData.bloodGlucose > 0) {
            data.healthkitInfo.bloodGlucose = healthData.bloodGlucose
            data.healthkitInfo.bloodGlucoseAvailable = true
        }
        if(healthData.cholesterol > 0){
            data.healthkitInfo.cholesterol = healthData.cholesterol
            data.healthkitInfo.cholesterolAvailable = true
        }
        if(healthData.Age > 0){
            data.healthkitInfo.age = healthData.Age
            data.healthkitInfo.ageAvailable = true
            data.healthkitInfo.genderAvailable = true
        }
        data.healthkitInfo.ecgData = healthData.ecg
        
        data.healthkitInfo.gender = Gender(rawValue: healthData.Gender) ?? .male
        
        isLoading = false
    }
}

#Preview {
    ApplicationView()
}
