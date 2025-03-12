//
//  ContentView.swift
//  WatchAppSample
//
//  Created by Shota Sakoda on 2025/03/12.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    @StateObject private var healthKitManager = HealthKitManager()
    @State private var heartRate: Double = 0.0
    
    var body: some View {
        VStack {
            Text("心拍数: \(Int(heartRate)) BPM")
                .font(.title2)
                .padding()
            
            Button(action: {
                healthKitManager.fetchHeartRateData { rate in
                    heartRate = rate
                }
            }) {
                Text("心拍数を更新")
            }
        }
        .onAppear {
            healthKitManager.requestAuthorization { success, error in
                if success {
                    healthKitManager.fetchHeartRateData { rate in
                        heartRate = rate
                    }
                    healthKitManager.startHeartRateObserver { rate in
                        heartRate = rate
                    }
                } else {
                    print("HealthKitの許可に失敗しました: \(error?.localizedDescription ?? "不明なエラー")")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
