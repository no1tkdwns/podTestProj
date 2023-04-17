//
//  CaulyAdapter.m
//  AdPopcornSSP
//
//  Created by mick on 2017. 9. 6..
//  Copyright (c) 2017년 igaworks All rights reserved.
//

// compatible with Cauly v3.1.16
#import "CaulyAdapter.h"

static inline NSString *SSPErrorString(SSPErrorCode code)
{
    switch (code)
    {
        case AdPopcornSSPException:
            return @"Exception";
        case AdPopcornSSPInvalidParameter:
            return @"Invalid Parameter";
        case AdPopcornSSPUnknownServerError:
            return @"Unknown Server Error";
        case AdPopcornSSPInvalidMediaKey:
            return @"Invalid Media key";
        case AdPopcornSSPInvalidPlacementId:
            return @"Invalid Placement Id";
        case AdPopcornSSPInvalidNativeAssetsConfig:
            return @"Invalid native assets config";
        case AdPopcornSSPNativePlacementDoesNotInitialized:
            return @"Native Placement Does Not Initialized";
        case AdPopcornSSPServerTimeout:
            return @"Server Timeout";
        case AdPopcornSSPLoadAdFailed:
            return @"Load Ad Failed";
        case AdPopcornSSPNoAd:
            return @"No Ad";
        case AdPopcornSSPNoInterstitialLoaded:
            return @"No Interstitial Loaded";
        case AdPopcornSSPNoRewardVideoAdLoaded:
            return @"No Reward video ad Loaded";
        case AdPopcornSSPMediationAdapterNotInitialized:
            return @"Mediation Adapter Not Initialized";
        default: {
            return @"Success";
        }
    }
}


@interface CaulyAdapter () <CaulyAdViewDelegate, CaulyInterstitialAdDelegate>
{
    
}

- (void)addAlignCenterConstraint;
@end

@implementation CaulyAdapter

@synthesize delegate = _delegate;
@synthesize integrationKey = _integrationKey;
@synthesize viewController = _viewController;
@synthesize bannerView = _bannerView;

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        
    }
    
    return self;
}


- (void)setViewController:(UIViewController *)viewController origin:(CGPoint)origin size:(CGSize)size bannerView:(AdPopcornSSPBannerView *)bannerView
{
    _viewController = viewController;
    _origin = origin;
    _size = size;
    _bannerView = bannerView;
    _adType = SSPAdBannerType;
}

- (void)setViewController:(UIViewController *)viewController
{
    _viewController = viewController;
    _adType = SSPAdInterstitialType;
}

- (BOOL)isSupportInterstitialAd
{
    return YES;
}

- (BOOL)isSupportRewardVideoAd
{
    return NO;
}

- (void)loadAd
{
    NSString *appCode = [_integrationKey valueForKey:[[_integrationKey allKeys] firstObject]];
    
    // Cauly Ad Setting
    CaulyAdSetting *adSetting = [CaulyAdSetting globalSetting];
    adSetting.appCode = appCode;
    adSetting.animType = CaulyAnimNone;
    adSetting.adSize = CaulyAdSize_IPhone;
    
    if (_adType == SSPAdBannerType)
    {
        if (appCode != nil)
        {
            _adBannerView = [[CaulyAdView alloc] initWithParentViewController:_viewController];
            [_bannerView addSubview:_adBannerView];
            [self addAlignCenterConstraint];
            
            _adBannerView.delegate = self;
            _adBannerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            
            // load request
            [_adBannerView startBannerAdRequest];
        }
        else
        {
          if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterBannerViewLoadFailError:adapter:)])
          {
              [_delegate AdPopcornSSPAdapterBannerViewLoadFailError:[AdPopcornSSPError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPMediationInvalidIntegrationKey userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPMediationInvalidIntegrationKey)}] adapter:self];
          }
          
          [self closeAd];
        }
    }
    else if (_adType == SSPAdInterstitialType)
    {
        if (_integrationKey != nil)
        {
            _interstitial = [[CaulyInterstitialAd alloc] initWithParentViewController:_viewController];
            _interstitial.delegate = self;
            [_interstitial startInterstitialAdRequest];
        }
        else
        {
            if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialAdLoadFailError:adapter:)])
            {
              [_delegate AdPopcornSSPAdapterInterstitialAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPMediationInvalidIntegrationKey userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPMediationInvalidIntegrationKey)}] adapter:self];
            }
          
            [self closeAd];
        }
    }
}

- (void)showAd
{
    NSLog(@"%@ : showAd", self);
    if (_adType == SSPAdInterstitialType)
    {
        [_interstitial show];
    }
}

- (void)closeAd
{
    NSLog(@"%@ : closeAd", self);
    if (_adType == SSPAdBannerType)
    {
        if(_adBannerView != nil)
        {
            [_adBannerView removeFromSuperview];
            _adBannerView.delegate = nil;
            _adBannerView = nil;
        }
    }
    else if (_adType == SSPAdInterstitialType)
    {
        if(_interstitial != nil)
        {
            _interstitial.delegate = nil;
            _interstitial = nil;
        }
    }
}

- (void)loadRequest
{
    if (_adType == SSPAdBannerType)
    {
        [_adBannerView startBannerAdRequest];
    }
    else if (_adType == SSPAdInterstitialType)
    {
        [_interstitial startInterstitialAdRequest];
    }
}

- (void)addAlignCenterConstraint
{
    // add constraints
    [_adBannerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    UIView *superview = _bannerView;
    [superview addConstraint: [NSLayoutConstraint constraintWithItem:_adBannerView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    
    [superview addConstraint: [NSLayoutConstraint constraintWithItem:_adBannerView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:_adBannerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeHeight multiplier:0.0 constant:_size.height]];
    
    [superview addConstraint:[NSLayoutConstraint constraintWithItem:_adBannerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:superview attribute:NSLayoutAttributeWidth multiplier:0.0 constant:_size.width]];
}

#pragma mark - CaulyAdViewDelegate
// 광고 정보 수신 성공
- (void)didReceiveAd:(CaulyAdView *)adView isChargeableAd:(BOOL)isChargeableAd{
    NSLog(@"CaulyAdapter didReceiveAd");
    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterBannerViewLoadSuccess:)])
    {
        [_delegate AdPopcornSSPAdapterBannerViewLoadSuccess:self];
    }
}

// 광고 정보 수신 실패
- (void)didFailToReceiveAd:(CaulyAdView *)adView errorCode:(int)errorCode errorMsg:(NSString *)errorMsg {
    NSLog(@"CaulyAdapter didFailToReceiveAd : %d(%@)", errorCode, errorMsg);

    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterBannerViewLoadFailError:adapter:)])
    {
        [_delegate AdPopcornSSPAdapterBannerViewLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
    }
    
    [self closeAd];
}

- (void)willShowLandingView:(CaulyAdView *)adView
{
    NSLog(@"CaulyAdapter willShowLandingView");
    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterBannerViewClicked:)])
    {
        [_delegate AdPopcornSSPAdapterBannerViewClicked:self];
    }
}

#pragma mark - CaulyInterstitialAdDelegate
// 광고 정보 수신 성공
- (void)didReceiveInterstitialAd:(CaulyInterstitialAd *)interstitialAd isChargeableAd:(BOOL)isChargeableAd {
    NSLog(@"CaulyAdapter didReceiveInterstitialAd");
    
    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialAdLoadSuccess:)])
    {
        [_delegate AdPopcornSSPAdapterInterstitialAdLoadSuccess:self];
    }
}

// 광고 정보 수신 실패
- (void)didFailToReceiveInterstitialAd:(CaulyInterstitialAd *)interstitialAd errorCode:(int)errorCode errorMsg:(NSString *)errorMsg {
    NSLog(@"CaulyAdapter didFailToReceiveInterstitialAd : %d(%@)", errorCode, errorMsg);
    
    [self closeAd];
    
    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialAdLoadFailError:adapter:)])
    {
        [_delegate AdPopcornSSPAdapterInterstitialAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
    }
}

// Interstitial 형태의 광고가 닫혔을 때
- (void)didCloseInterstitialAd:(CaulyInterstitialAd *)interstitialAd {
    NSLog(@"CaulyAdapter didCloseInterstitialAd");
    [self closeAd];
    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialAdClosed:)])
    {
        [_delegate AdPopcornSSPAdapterInterstitialAdClosed:self];
    }
}

// Interstitial 형태의 광고가 보여지기 직전
- (void)willShowInterstitialAd:(CaulyInterstitialAd *)interstitialAd {
    NSLog(@"CaulyAdapter willShowInterstitialAd");
    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialAdShowSuccess:)])
    {
        [_delegate AdPopcornSSPAdapterInterstitialAdShowSuccess:self];
    }
}
@end
