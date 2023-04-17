//
//  APInterView.swift
//  SdkAdLibrary
//
//  Created by 임재혁 on 2023/03/07.
//

import UIKit
import MyFramework

open class APInterModule: UIViewController, APSSPInterstitialAdDelegate{
    // MARK: - Properties
    var interstitialView: AdPopcornSSPInterstitialAd!
    
    // MARK: - init
    public init(key: String, pid: String){
        super.init(nibName: nil, bundle: nil)
        setInterAd(appKey: key, placementId: pid)
        
    }
    
    required public init?(coder: NSCoder, key: String, pid: String) {
        super.init(coder: coder)
        setInterAd(appKey: key, placementId: pid)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setInterAd(appKey: String, placementId: String){
        interstitialView = AdPopcornSSPInterstitialAd.init(
            key: appKey,
            placementId: placementId,
            viewController: self)
        interstitialView.delegate = self
    }
    
    public func load(){
        interstitialView.loadRequest()
    }
    
    public func apsspInterstitialAdLoadSuccess(_ interstitialAd: AdPopcornSSPInterstitialAd!) {
        print("LIM: Inter apsspInterstitialAdLoadSuccess")
        interstitialAd.present(from: self)
    }
    
    open func apsspInterstitialAdClosed(_ interstitialAd: AdPopcornSSPInterstitialAd!) {
        print("LIM: Inter APSSPinterstitialAdClosed")
    }
    
    public func apsspInterstitialAdClicked(_ interstitialAd: AdPopcornSSPInterstitialAd!) {
        print("LIM: Inter apsspInterstitialAdClicked")
    }
    
    public func apsspInterstitialAdShowSuccess(_ interstitialAd: AdPopcornSSPInterstitialAd!) {
        print("LIM: Inter apsspInterstitialAdShowSuccess")
    }
    
    public func apsspInterstitialAdLoadFail(_ interstitialAd: AdPopcornSSPInterstitialAd!, error: AdPopcornSSPError!) {
        print("LIM: Inter apsspInterstitialAdLoadFail \(error.code)")
    }
    
    public func apsspInterstitialAdShowFail(_ interstitialAd: AdPopcornSSPInterstitialAd!, error: AdPopcornSSPError!) {
        print("LIM: Inter apsspInterstitialAdShowFail \(error.code)")
    }
    
}
