//
//  AnimatedImage.swift
//  HeartSense
//
//  Created by Aditya Naravane on 10/27/25.
//

import SwiftUI

import SwiftUI

struct AnimatedImage: View {
    let imageNames: [String] = ["heart_1", "heart_2", "heart_3", "heart_4", "heart_5", "heart_6", "heart_7", "heart_8", "heart_9", "heart_10", "heart_11", "heart_12", "heart_12", "heart_13", "heart_14", "heart_15", "heart_16", "heart_17", "heart_18", "heart_19", "heart_20", "heart_21", "heart_22", "heart_23", "heart_24", "heart_25", "heart_26", "heart_27", "heart_28"] // Array of heart image names
    @State private var currentIndex: Int = 0
    @State private var timer: Timer? = nil

    var body: some View {
        VStack{
            ZStack{
                Color("blue_back")
                Image("heart_" + String(currentIndex + 1))
                    .resizable()
                    .frame(width: 250, height: 300)
                    .onAppear(perform: startAnimation)
                    .onDisappear(perform: stopAnimation)
            }
            .ignoresSafeArea()
            
            .navigationBarTitle("Check my health...", displayMode: .large)
        }
    }

    private func startAnimation() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            currentIndex = (currentIndex + 1) % 28
        }
    }

    private func stopAnimation() {
        timer?.invalidate()
        timer = nil
    }
}
