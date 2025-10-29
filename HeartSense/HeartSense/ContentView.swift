//
//  ContentView.swift
//  HeartSense
//
//  Created by Aditya Naravane on 10/22/25.
//

import SwiftUI

struct ContentView: View {
    // Input fields as Strings to bind to TextFields
    @State private var isHomeRootScreen = false

    var body: some View {
        ZStack{
            if isHomeRootScreen {
                ApplicationView()
            }else {
                NavigationStack {
                    VStack {
                        AnimatedImage()
                            .onTapGesture {
                                isHomeRootScreen.toggle()
                            }
                            .onSubmit {
                                isHomeRootScreen.toggle()
                            }
                    }
                    .navigationDestination(isPresented: $isHomeRootScreen) {
                        ApplicationView()
                    }
                }
            }
        }
        
    }
}

#Preview {
    ContentView()
}
