//
//  APRewardVideoView.swift
//  SdkAdLibrary
//
//  Created by 임재혁 on 2023/03/08.
//

import UIKit
import MyFramework

open class APRewardVideoModule: UIViewController, APSSPRewardVideoAdDelegate{
    
    // MARK: - Properties
    var rewardVideoView: AdPopcornSSPRewardVideoAd!
    
    // MARK: - Init
    public init(key: String, pid: String){
        super.init(nibName: nil, bundle: nil)
        setRewardVideoAd(appKey: key, placementId: pid)
    }
    
    required public init?(coder: NSCoder, key: String, pid: String) {
        super.init(coder: coder)
        setRewardVideoAd(appKey: key, placementId: pid)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setRewardVideoAd(appKey: String, placementId: String){
        rewardVideoView = AdPopcornSSPRewardVideoAd.init(key: appKey,
                                                         placementId: placementId,
                                                         viewController: self)
        rewardVideoView.delegate = self
    }
    
    public func load(){
        rewardVideoView.loadRequest()
    }
    
    public func apsspRewardVideoAdLoadSuccess(_ rewardVideoAd: AdPopcornSSPRewardVideoAd!) {
        print("LIM: RewardVideo apsspRewardVideoAdLoadSuccess")
        rewardVideoAd.present(from: self)
    }
    
    open func apsspRewardVideoAdClosed(_ rewardVideoAd: AdPopcornSSPRewardVideoAd!) {
        print("LIM: RewardVideo apsspRewardVideoAdClosed")
    }
    
    public func apsspRewardVideoAdShowFail(_ rewardVideoAd: AdPopcornSSPRewardVideoAd!) {
        print("LIM: RewardVideo apsspRewardVideoAdShowFail")
    }
    
    public func apsspRewardVideoAdShowSuccess(_ rewardVideoAd: AdPopcornSSPRewardVideoAd!) {
        print("LIM: RewardVideo apsspRewardVideoAdShowSuccess")
    }
    
    public func apsspRewardVideoAdLoadFail(_ rewardVideoAd: AdPopcornSSPRewardVideoAd!, error: AdPopcornSSPError!) {
        print("LIM: RewardVideo apsspRewardVideoAdLoadFail \(error.code)")
    }
    
    public func apsspRewardVideoAdPlayCompleted(_ rewardVideoAd: AdPopcornSSPRewardVideoAd!, adNetworkNo: Int, completed: Bool) {
        print("LIM: RewardVideo apsspRewardVideoAdPlayCompleted")
    }
}
