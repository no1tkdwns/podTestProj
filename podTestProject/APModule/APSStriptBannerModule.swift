//
//  APSStriptBannerView.swift
//  SdkAdLibrary
//
//  Created by 임재혁 on 2023/03/07.
//

import UIKit
import MyFramework

public class APSStriptBannerModule: UIView, APSSPBannerViewDelegate {
    // MARK: - Properties
    var bannerView: AdPopcornSSPBannerView!
    
    // MARK: - class init
    public init(appKey: String, placementId: String, viewController: UIViewController){
        super.init(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        
        setBannerView(key: appKey, pid: placementId, vc: viewController)
    }
    
    required public init?(coder: NSCoder, appKey: String, placementId: String, viewController: UIViewController) {
        super.init(coder: coder)
        
        setBannerView(key: appKey, pid: placementId, vc: viewController)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setting
    private func setBannerView(key: String, pid: String, vc: UIViewController){
        bannerView = AdPopcornSSPBannerView.init(bannerViewSize: SSPBannerViewSize320x50,
                                                 origin: CGPoint(x: 0.0, y: 0.0),
                                                 appKey: key,
                                                 placementId: pid,
                                                 view: self,
                                                 rootViewController: vc)
        bannerView.delegate = self
        bannerView.adRefreshRate = 50
        bannerView.setAutoBgColor(false)
//        bannerView.setAnimType(SSPBannerViewAnimFlipFromLeft)
    }
    
    public func load(){
        bannerView.loadRequest()
    }
    
    public func stop(){
        self.removeFromSuperview()
        bannerView.stopAd()
    }
    
    public func apsspBannerViewLoadSuccess(_ bannerView: AdPopcornSSPBannerView!) {
        print("LIM: 320x50 apsspBannerViewLoadSuccess")
    }
    
    public func apsspBannerViewClicked(_ bannerView: AdPopcornSSPBannerView!) {
        print("LIM: 320x50 apsspBannerViewClicked")
    }
    
    public func apsspBannerViewLoadFail(_ bannerView: AdPopcornSSPBannerView!, error: AdPopcornSSPError!) {
        print("LIM: 320x50 apsspBannerViewLoadFail \(error.code)")
    }
    
}
