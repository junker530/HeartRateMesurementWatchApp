//
//  HealthKitManager.swift
//  WatchAppSample
//
//  Created by Shota Sakoda on 2025/03/12.
//

import HealthKit
import Foundation
import SwiftUI // ObservableObjectを使用するために必要

class HealthKitManager: ObservableObject {
    let healthStore = HKHealthStore()
    
    // HealthKitの許可をリクエスト
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, nil)
            return
        }
        
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            completion(false, nil)
            return
        }
        
        healthStore.requestAuthorization(toShare: nil, read: [heartRateType]) { (success, error) in
            completion(success, error)
        }
    }
    
    // 最新の心拍数データを取得
    func fetchHeartRateData(completion: @escaping (Double) -> Void) {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            print("心拍数タイプが利用できません")
            return
        }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: heartRateType,
                                  predicate: nil,
                                  limit: 1,
                                  sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            guard let samples = samples, let mostRecentSample = samples.first as? HKQuantitySample else {
                print("心拍数データの取得に失敗しました: \(error?.localizedDescription ?? "データなし")")
                return
            }
            
            let heartRateUnit = HKUnit(from: "count/min")
            let heartRate = mostRecentSample.quantity.doubleValue(for: heartRateUnit)
            
            DispatchQueue.main.async {
                completion(heartRate)
            }
        }
        
        healthStore.execute(query)
    }
    
    // リアルタイム更新（Observer Query）
    func startHeartRateObserver(completion: @escaping (Double) -> Void) {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            print("心拍数タイプが利用できません")
            return
        }
        
        healthStore.enableBackgroundDelivery(for: heartRateType, frequency: .immediate) { (success, error) in
            if success {
                print("バックグラウンド更新が有効化されました")
            } else {
                print("バックグラウンド更新の有効化に失敗しました: \(error?.localizedDescription ?? "不明なエラー")")
            }
        }
        
        let observerQuery = HKObserverQuery(sampleType: heartRateType, predicate: nil) { [weak self] (query, completionHandler, error) in
            if let error = error {
                print("Observer Queryエラー: \(error.localizedDescription)")
                return
            }
            self?.fetchHeartRateData(completion: { heartRate in
                completion(heartRate)
            })
            completionHandler()
        }
        
        healthStore.execute(observerQuery)
    }
}
