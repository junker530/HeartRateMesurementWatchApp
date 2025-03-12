//
//  HeartRateViewController.swift
//  WatchAppSample
//
//  Created by Shota Sakoda on 2025/03/12.
//

import WatchKit
import Foundation
import HealthKit

class HeartRateViewController: WKInterfaceController {
    
    @IBOutlet weak var heartRateLabel: WKInterfaceLabel!
    let healthKitManager = HealthKitManager()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        requestHealthKitPermission()
    }
    
    // HealthKitの許可をリクエスト
    func requestHealthKitPermission() {
        healthKitManager.requestAuthorization { success, error in
            if success {
                print("HealthKitの許可が成功しました")
                self.healthKitManager.fetchHeartRateData { heartRate in
                    DispatchQueue.main.async {
                        self.heartRateLabel.setText("心拍数: \(Int(heartRate)) BPM")
                    }
                }
                self.healthKitManager.startHeartRateObserver { heartRate in
                    DispatchQueue.main.async {
                        self.heartRateLabel.setText("心拍数: \(Int(heartRate)) BPM")
                    }
                }
            } else {
                print("HealthKitの許可に失敗しました: \(error?.localizedDescription ?? "不明なエラー")")
            }
        }
    }
}
