//
//  APInterVideoView.swift
//  SdkAdLibrary
//
//  Created by 임재혁 on 2023/03/08.
//

import UIKit
import MyFramework

open class APInterVideoModule: UIViewController, APSSPInterstitialVideoAdDelegate{
    
    // MARK: - Properties
    var interVideoView: AdPopcornSSPInterstitialVideoAd!
    
    public init(key: String, pid: String){
        super.init(nibName: nil, bundle: nil)
        setInterVideoAd(appKey: key, placementId: pid)
    }
    
    required public init?(coder: NSCoder, key: String, pid: String) {
        super.init(coder: coder)
        setInterVideoAd(appKey: key, placementId: pid)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setInterVideoAd(appKey: String, placementId: String){
        interVideoView = AdPopcornSSPInterstitialVideoAd.init(key: appKey,
                                                              placementId: placementId,
                                                              viewController: self)
        interVideoView.delegate = self
    }
    
    public func load(){
        interVideoView.loadRequest()
    }
    
    public func apsspInterstitialVideoAdLoadSuccess(_ interstitialVideoAd: AdPopcornSSPInterstitialVideoAd!) {
        print("LIM: InterVideo apsspInterstitialVideoAdLoadSuccess")
        interstitialVideoAd.present(from: self)
    }
    
    open func apsspInterstitialVideoAdClosed(_ interstitialVideoAd: AdPopcornSSPInterstitialVideoAd!) {
        print("LIM: InterVideo apsspInterstitialVideoAdClosed")
    }
    
    public func apsspInterstitialVideoAdShowFail(_ interstitialVideoAd: AdPopcornSSPInterstitialVideoAd!) {
        print("LIM: InterVideo apsspInterstitialVideoAdShowFail")
    }
    
    public func apsspInterstitialVideoAdShowSuccess(_ interstitialVideoAd: AdPopcornSSPInterstitialVideoAd!) {
        print("LIM: InterVideo apsspInterstitialVideoAdShowSuccess")
    }
    
    public func apsspInterstitialVideoAdLoadFail(_ interstitialVideoAd: AdPopcornSSPInterstitialVideoAd!, error: AdPopcornSSPError!) {
        print("LIM: InterVideo apsspInterstitialVideoAdLoadFail \(error.code)")
    }
}
