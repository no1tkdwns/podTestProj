//
//  APBStriptBannerView.swift
//  SdkAdLibrary
//
//  Created by 임재혁 on 2023/03/07.
//

import UIKit
import MyFramework

public class APBStriptBannerModule: UIView, APSSPBannerViewDelegate{
    // MARK: - Properties
    var bannerView: AdPopcornSSPBannerView!
    
    // MARK: - class Init
    public init(appKey: String, placementId: String){
        super.init(frame: CGRect(x: 0, y: 0, width: 320, height: 100))
        
        setBannerView(key: appKey, pid: placementId)
    }
    
    required public init?(coder: NSCoder, appKey: String, placementId: String) {
        super.init(coder: coder)
        
        setBannerView(key: appKey, pid: placementId)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setting
    private func setBannerView(key: String, pid: String){
        bannerView = AdPopcornSSPBannerView.init(bannerViewSize: SSPBannerViewSize320x100,
                                                 origin: CGPoint(x: 0.0, y: 0.0),
                                                 appKey: key,
                                                 placementId: pid,
                                                 view: self,
                                                 rootViewController: nil)
        bannerView.delegate = self
        bannerView.adRefreshRate = 50
        bannerView.setAutoBgColor(false)
        bannerView.setAnimType(SSPBannerViewAnimFlipFromLeft)
    }
    
    // MARK: - Helpers
    public func load(){
        bannerView.loadRequest()
    }
    
    public func stop(){
        self.removeFromSuperview()
        bannerView.stopAd()
    }
    
    public func apsspBannerViewClicked(_ bannerView: AdPopcornSSPBannerView!) {
        print("LIM: 320x100 apsspBannerViewClicked")
    }
    
    public func apsspBannerViewLoadSuccess(_ bannerView: AdPopcornSSPBannerView!) {
        print("LIM: 320x100 apsspBannerViewLoadSuccess")
    }
    
    public func apsspBannerViewLoadFail(_ bannerView: AdPopcornSSPBannerView!, error: AdPopcornSSPError!) {
        print("LIM: 320x100 apsspBannerViewLoadFail \(error.code)")
    }
    
}
