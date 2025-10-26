//
//  ContentView.swift
//  HeartSense
//
//  Created by Aditya Naravane on 10/22/25.
//

import SwiftUI

struct ContentView: View {
    @State private var stepCount: Double = 0
    let healthStore = HealthStore()
    let nn = HeartModelRunner()

    var body: some View {
        VStack {
            Text("Today's Steps")
                .font(.title)
            Text("\(Int(stepCount))") // Display actual steps
                .font(.largeTitle)
                .bold()
        }
        .padding()
        .onAppear {
            // Run prediction
            let result = nn?.predict(
                age: 52,
                sex: 1,
                cp: 0,
                trestbps: 125,
                chol: 212,
                fbs: 0,
                restecg: 1,
                thalach: 168,
                exang: 0,
                oldpeak: 1,
                slope: 2,
                ca: 2,
                threshold: 0.5
            )
            print("Prediction result: \(result)")

            // Request HealthKit authorization and steps
//            healthStore.requestAuthorization { success, error in
//                if success {
//                    healthStore.getStepCount { steps in
//                        DispatchQueue.main.async {
//                            stepCount = steps
//                        }
//                    }
//                } else if let error = error {
//                    print("HealthKit authorization failed: \(error.localizedDescription)")
                
            
        }
    }
}

#Preview {
    ContentView()
}
