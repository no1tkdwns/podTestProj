//
//  APSSPInit.swift
//  SdkAdLibrary
//
//  Created by 임재혁 on 2023/03/06.
//

import UIKit
import AdSupport
import AppTrackingTransparency
import Datadog
import UnityAds
import PAGAdSDK
import VungleSDK
import AppLovinSDK
import MyFramework

public class APSSPInit{
    
    var arrayResult: AppSettingModel?
    
    public init(){
        
    }
    
    public func appSetting(completionHandler: @escaping (AppSettingModel) -> Void) {
        let appId: String = Bundle.main.object(forInfoDictionaryKey: "PointHomeSdkKey") as! String
        let input = AppSettingInput(sdkKey: appId)
        AppSettingDataManager().AppSettingDataManger(parameters: input, completion: completionHandler)

    }
    
    open func apSetting(){
        debugPrint("LIM: apSetting")
        AdPopcornSSP.setLogLevel(AdPopcornSSPLogTrace)
        AdPopcornSSP.initializeSDK("TEST_USN")
        AdPopcornSSP.setUserId("TEST_USN")
    }
    
    public func setMediCauly(appId: String, appCode: String){
        print("LIM: mediation Cauly setting")
        // Cauly
//        let adSetting : CaulyAdSetting = CaulyAdSetting.global()
//        CaulyAdSetting.setLogLevel(CaulyLogLevelInfo)
//        adSetting.appId = appId
//        adSetting.appCode = appCode
//        adSetting.animType = CaulyAnimNone
//        adSetting.closeOnLanding = true
    }
    
    public func setMediVungle(appId: String){
        print("LIM: mediation Vungle Setting")
        // Vungle
        do{
            try VungleSDK.shared().start(withAppId: appId)
        }catch{
            print("LIM: setMEdiVungle")
            print("LIM: \(error)")
        }
    }
    
    public func setMediAppLovin(){
        print("LIM: mediation AppLovin Setting")
        // AppLovin
        ALSdk.initializeSdk()
    }
    
    public func setMediPangle(appKey: String){
        print("LIM: mediation Pangle Setting")
        // pangle
        let config :PAGConfig = PAGConfig.share()
        config.appID = appKey
        PAGSdk.start(with: config)
    }
    
    
    open func mediationSetting(){
        debugPrint("LIM: Mediation")
        // Cauly
        let adSetting : CaulyAdSetting = CaulyAdSetting.global()
        CaulyAdSetting.setLogLevel(CaulyLogLevelInfo)
        adSetting.appId = "1234567"
        adSetting.appCode = "wAsKi1r6"
        adSetting.animType = CaulyAnimNone
        adSetting.closeOnLanding = true
        
        // Vungle
        do{
            try VungleSDK.shared().start(withAppId: "63db2422c08b2ab6cfe8cd58")
        }catch{
            print("LIM: setMEdiVungle")
            print("LIM: \(error)")
        }
        
        // AppLovin
        ALSdk.initializeSdk()
        
        // pangle
        let config :PAGConfig = PAGConfig.share()
        config.appID = "8108172"
        PAGSdk.start(with: config)
        
        
    }
    
    open func trackSetting(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization { status in
                    switch status {
                    case .authorized: // 허용됨
                        print("Authorized")
                        print("IDFA = \(ASIdentifierManager.shared().advertisingIdentifier)")
                    case .notDetermined:
                        print("notDetermined")
                    case .restricted:
                        print("restricted")
                    case .denied:
                        print("denied")
                    @unknown default:
                        print("Unkcow")
                    }
                }
            }
         }
    }
    
    
    public func DatadogInit(){
        Datadog.initialize(appContext: .init(),
                           trackingConsent: .granted,
                           configuration: Datadog.Configuration
            .builderUsing(clientToken: "pubeed559e6de02005a8ec328e35519cd20", environment: "info")
            .set(serviceName: "PointHomeSdk")
            .set(endpoint: .us1)
            .build()
        )
        
        Datadog.verbosityLevel = .debug
    }
    
    public let logger = Logger.builder
        .sendNetworkInfo(true)
        .printLogsToConsole(true, usingFormat: .shortWith(prefix: "[iOS APP] "))
        .set(datadogReportingThreshold: .debug)
        .build()
    
}
