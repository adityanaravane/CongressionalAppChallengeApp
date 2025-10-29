//
//  ECGWaveform.swift
//  Cardian
//
//  Created by Aditya Naravane on 10/29/25.
//

import Foundation
import SwiftUI
import Charts

struct ecgData: Identifiable {
    let id = UUID()
    var time: Double = 0.0
    var voltage: Double = 0.0
}

struct ECGWaveform {
    var ecgData: [ecgData] = []
    var printData: Void {
        for d in ecgData {
            print("\(d.time), \(d.voltage)")
        }
    }
}

struct ECGView: View {
    @Binding var ecg: ECGWaveform
    // Generate 101 sample times from 0 to 100
    private let sampleTimes: [Double] = Array(0...50).map { Double($0) }

    // Create matching random voltages in a computed array to avoid top-level executable code
    private var sampleVoltages: [Double] {
        sampleTimes.map { _ in Double.random(in: 40...50.0) }
    }

    // Combine times and voltages into chart-ready data
    private var dataPoints: [ecgData] {
        zip(sampleTimes, sampleVoltages).map { ecgData(time: $0.0, voltage: $0.1) }
    }

    var body: some View {
        let d = ecg.printData
        Chart(ecg.ecgData) { point in
            LineMark(
                x: .value("Time", point.time),
                y: .value("Voltage", point.voltage)
            )
            .foregroundStyle(.blue)
        }
        .padding()
    }
}

#Preview {
    @State var ecg: ECGWaveform = ECGWaveform()
    ECGView(ecg: $ecg)
}
