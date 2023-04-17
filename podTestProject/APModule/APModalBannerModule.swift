//
//  APModalBannerView.swift
//  SdkAdLibrary
//
//  Created by 임재혁 on 2023/03/08.
//

import UIKit
import MyFramework

public class APModalBannerModule: UIView, APSSPBannerViewDelegate{
    // MARK: - Properties
    var modalView: AdPopcornSSPBannerView!
    
    var closeBtnTrailing: NSLayoutConstraint?
    var closeBtnBottom: NSLayoutConstraint?
    var modalViewX: NSLayoutConstraint?
    var modalViewY: NSLayoutConstraint?
    
    private lazy var dimmingView: UIView = {
        let dimmingView = UIView()
        dimmingView.backgroundColor = .white
        dimmingView.alpha = 0.5
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        return dimmingView
    }()
    
    private lazy var closeBtn: UIButton = {
       let closeBtn = UIButton()
        closeBtn.setTitle("", for: .normal)
        closeBtn.setImage(UIImage(systemName: "x.square.fill"), for: .normal)
        closeBtn.setTitleColor(.black, for: .normal)
        closeBtn.translatesAutoresizingMaskIntoConstraints = false
        return closeBtn
    }()
    
    // MARK: - class Init
    public init(appKey: String, placementId: String) {
        super.init(frame: CGRect(x: 0, y: 0, width: 300, height: 250))
        setModalAd(key: appKey, pid: placementId)
    }
    
    required public init?(coder: NSCoder, appKey: String, placementId: String) {
        super.init(coder: coder)
        setModalAd(key: appKey, pid: placementId)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setting
    private func setModalAd(key: String, pid: String){
        modalView = AdPopcornSSPBannerView.init(bannerViewSize: SSPBannerViewSize300x250,
                                                origin: CGPoint(x: 0.0, y: 0.0),
                                                appKey: key,
                                                placementId: pid,
                                                view: self,
                                                rootViewController: nil)
        modalView.delegate = self
        modalView.adRefreshRate = -1
        modalView.setAutoBgColor(false)
        modalView.translatesAutoresizingMaskIntoConstraints = false
        
        
        closeBtn.addTarget(self, action: #selector(closeBtnAction), for: .touchUpInside)
        
    }
    
    // MARK: - Constraint
    private func setConstraint(){
        NSLayoutConstraint.activate([
            dimmingView.topAnchor.constraint(equalTo: self.topAnchor),
            dimmingView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            dimmingView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            dimmingView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            modalView.widthAnchor.constraint(equalToConstant: 300),
            modalView.heightAnchor.constraint(equalToConstant: 250)
        ])
        modalViewX?.isActive = false
        modalViewX = modalView.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        modalViewX?.isActive = true
        modalViewY?.isActive = false
        modalViewY = modalView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        modalViewY?.isActive = true
    }
    
    private func setCloseBtnConstraint(){
        closeBtnBottom?.isActive = false
        closeBtnBottom = closeBtn.bottomAnchor.constraint(equalTo: self.modalView.topAnchor, constant: -5)
        closeBtnBottom?.isActive = true
        closeBtnTrailing?.isActive = false
        closeBtnTrailing = closeBtn.trailingAnchor.constraint(equalTo: self.modalView.trailingAnchor, constant: -40)
        closeBtnTrailing?.isActive = true
    }
    
    // MARK: - Action
    @objc private func closeBtnAction(){
        print("LIM: closeBtn")
        stop()
    }
    
    private func loadSetting(){
        self.addSubview(dimmingView)
        self.addSubview(modalView)
        self.addSubview(closeBtn)
        
        setConstraint()
        setCloseBtnConstraint()
    }
    
    public func load(frameX: Double,frameY: Double){
        loadSetting()
        modalViewX?.isActive = false
        modalViewX = modalView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: frameX)
        modalViewX?.isActive = true
        modalViewY?.isActive = false
        modalViewY = modalView.topAnchor.constraint(equalTo: self.topAnchor, constant: frameY)
        modalViewY?.isActive = true
        
        setCloseBtnConstraint()
        
        modalView.loadRequest()
    }
    
    public func load(){
        loadSetting()
        modalViewX?.isActive = false
        modalViewX = modalView.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        modalViewX?.isActive = true
        modalViewY?.isActive = false
        modalViewY = modalView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        modalViewY?.isActive = true
        
        setCloseBtnConstraint()
        
        modalView.loadRequest()
    }
    
    public func stop(){
        modalView.stopAd()
        self.removeFromSuperview()
    }
    
    // MARK: - AdPopcornSSP Event
    public func apsspBannerViewClicked(_ bannerView: AdPopcornSSPBannerView!) {
        print("LIM: 300x250 Banner apsspBannerViewClicked")
    }
    public func apsspBannerViewLoadSuccess(_ bannerView: AdPopcornSSPBannerView!) {
        print("LIM: 300x250 Banner apsspBannerViewLoadSuccess")
    }
    public func apsspBannerViewLoadFail(_ bannerView: AdPopcornSSPBannerView!, error: AdPopcornSSPError!) {
        print("LIM: 300x250 Banner apsspBannerViewLoadFail \(error.code)")
    }
}
