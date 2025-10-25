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
    
    
    var body: some View {
        VStack {
            Text("Today's Steps")
                .font(.title)
            Text("\(Int(stepCount))")
                .font(.largeTitle)
                .bold()
            
            Button("Fetch Steps") {
                healthStore
                    .fetchStepCount { steps, error in
                        if let error {
                            // You could surface this to the UI later
                            print("Failed to fetch steps: \(error.localizedDescription)")
                        }
                        stepCount = steps
                    }
            }
            .buttonStyle(
                .borderedProminent
            )
        }
        .padding()
        .onAppear {
            requestHealthKitAccess()
        }
    }
    
    func requestHealthKitAccess() {
        healthStore.requestAuthorization {
            success, error in
            if let error = error {
                print("HealthKit authorization denied.")
            } else {
                print("HealthKit authorization granted.")
            }
        }
    }
}

#Preview {
    ContentView()
}
