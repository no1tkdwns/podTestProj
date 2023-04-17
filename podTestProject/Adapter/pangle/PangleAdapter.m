//
//  PangleAdapter.m
//  AdPopcornSSP
//
//  Created by mick on 2020. 10. 28..
//  Copyright (c) 2020년 igaworks All rights reserved.
//

// compatible with Pangle v4.7.0.5
#import "PangleAdapter.h"

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
        case AdPopcornSSPNoInterstitialVideoAdLoaded:
            return @"No Interstitial video ad Loaded";
        default: {
            return @"Success";
        }
    }
}

@interface PangleAdapter () <PAGRewardedAdDelegate, PAGLInterstitialAdDelegate>
{
    BOOL _isCurrentRunningAdapter;
    PAGRewardedAd *rewardedVideoAd;
    PAGLInterstitialAd *interstitialVideoAd;
    NSString *pangleAppId, *panglePlacementId;
    NSTimer *networkScheduleTimer;
    NSInteger adNetworkNo;
}

@end

@implementation PangleAdapter

@synthesize delegate = _delegate;
@synthesize integrationKey = _integrationKey;
@synthesize viewController = _viewController;
@synthesize bannerView = _bannerView;

- (instancetype)init
{
    self = [super init];
    if (self){}
    adNetworkNo = 18;
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

- (void)setRewardVideoViewController:(UIViewController *)viewController
{
    _viewController = viewController;
    _adType = SSPRewardVideoAdType;
}

- (void)setInterstitialVideoViewController:(UIViewController *)viewController
{
    _viewController = viewController;
    _adType = SSPInterstitialVideoAdType;
}

- (BOOL)isSupportInterstitialAd
{
    return NO;
}

- (BOOL)isSupportRewardVideoAd
{
    return YES;
}

- (BOOL)isSupportInterstitialVideoAd
{
    return YES;
}

- (void)loadAd
{
    if(networkScheduleTimer == nil)
    {
        networkScheduleTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(networkScheduleTimeoutHandler:) userInfo:nil repeats:NO];
    }
    else{
        [self invalidateNetworkTimer];
        networkScheduleTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(networkScheduleTimeoutHandler:) userInfo:nil repeats:NO];
    }
    
    PAGSDKInitializationState state = PAGSdk.initializationState;
    if(state == PAGSDKInitializationStateNotReady)
    {
        NSLog(@"PangleAdapter PAGSDKInitializationStateNotReady");
        if (_integrationKey != nil)
        {
            pangleAppId = [_integrationKey valueForKey:@"PangleAppId"];
            panglePlacementId = [_integrationKey valueForKey:@"PanglePlacementId"];
        }
        PAGConfig *config = [PAGConfig shareConfig];
        config.appID = pangleAppId;
        [PAGSdk startWithConfig:config completionHandler:^(BOOL success, NSError * _Nonnull error) {
            if (success) {
                [self loadAdCore];
            }
            else
            {
                if(_adType == SSPRewardVideoAdType)
                {
                    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdLoadFailError:adapter:)])
                    {
                        [_delegate AdPopcornSSPAdapterRewardVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPMediationInvalidIntegrationKey userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPMediationInvalidIntegrationKey)}] adapter:self];
                    }
                    [self invalidateNetworkTimer];
                }
                else if(_adType == SSPInterstitialVideoAdType)
                {
                    if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:adapter:)])
                    {
                        [_delegate AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPMediationInvalidIntegrationKey userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPMediationInvalidIntegrationKey)}] adapter:self];
                    }
                    [self invalidateNetworkTimer];
                }
            }
        }];
    }
    else
    {
        [self loadAdCore];
    }
}

- (void)loadAdCore
{
    if (_adType == SSPRewardVideoAdType)
    {
        NSLog(@"PangleAdapter %@ : SSPRewardVideoAdType loadAd", self);
        _isCurrentRunningAdapter = YES;
        if (_integrationKey != nil)
        {
            pangleAppId = [_integrationKey valueForKey:@"PangleAppId"];
            panglePlacementId = [_integrationKey valueForKey:@"PanglePlacementId"];
            
            //It is required to generate a new BURewardedVideoAd object each time calling the loadAdData method to request the latest rewarded video ad. Please do not reuse the local cache rewarded video ad.
            
            PAGRewardedRequest *request = [PAGRewardedRequest request];
            [PAGRewardedAd loadAdWithSlotID:panglePlacementId request:request completionHandler:^(PAGRewardedAd * _Nullable rewardedAd, NSError * _Nullable error) {
                if (error) {
                    NSLog(@"PangleAdapter RV load fail : %@",error);
                    if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdLoadFailError:adapter:)])
                    {
                        [_delegate AdPopcornSSPAdapterRewardVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
                    }
                    [self invalidateNetworkTimer];
                    return;
                }
                
                NSLog(@"PangleAdapter RV load success");
                rewardedVideoAd = rewardedAd;
                rewardedVideoAd.delegate = self;
                if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdLoadSuccess:)])
                {
                    [_delegate AdPopcornSSPAdapterRewardVideoAdLoadSuccess:self];
                }
                [self invalidateNetworkTimer];
            }];
        }
        else
        {
            NSLog(@"PangleAdapter rv no integrationKey");
            if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdLoadFailError:adapter:)])
            {
                [_delegate AdPopcornSSPAdapterRewardVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPMediationInvalidIntegrationKey userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPMediationInvalidIntegrationKey)}] adapter:self];
            }
            [self invalidateNetworkTimer];
        }
    }
    else if(_adType == SSPInterstitialVideoAdType)
    {
        _isCurrentRunningAdapter = YES;
        NSLog(@"PangleAdapter %@ : SSPInterstitialVideoAdType loadAd", self);
        if (_integrationKey != nil)
        {
            pangleAppId = [_integrationKey valueForKey:@"PangleAppId"];
            panglePlacementId = [_integrationKey valueForKey:@"PanglePlacementId"];
            
            //It is required to generate a new BURewardedVideoAd object each time calling the loadAdData method to request the latest rewarded video ad. Please do not reuse the local cache rewarded video ad.
            PAGInterstitialRequest *request = [PAGInterstitialRequest request];
            [PAGLInterstitialAd loadAdWithSlotID:panglePlacementId request:request completionHandler:^(PAGLInterstitialAd * _Nullable interstitialAd, NSError * _Nullable error) {
                    if (error) {
                        NSLog(@"PangleAdapter IV load fail : %@",error);
                        if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:adapter:)])
                        {
                            [_delegate AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
                        }
                        [self invalidateNetworkTimer];
                        return;
                    }
                    interstitialVideoAd = interstitialAd;
                    interstitialVideoAd.delegate = self;
                
                    NSLog(@"PangleAdapter IV load Success");
                    if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdLoadSuccess:)])
                    {
                        [_delegate AdPopcornSSPAdapterInterstitialVideoAdLoadSuccess:self];
                    }
                    [self invalidateNetworkTimer];
             }];
        }
        else
        {
            if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:adapter:)])
            {
                [_delegate AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPMediationInvalidIntegrationKey userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPMediationInvalidIntegrationKey)}] adapter:self];
            }
            [self invalidateNetworkTimer];
        }
    }
}

- (void)showAd
{
    NSLog(@"PangleAdapter : showAd");
    if (_adType == SSPRewardVideoAdType)
    {
        if (rewardedVideoAd) {
             [rewardedVideoAd presentFromRootViewController:_viewController];
        }
        else {
            if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdShowFailError:adapter:)])
            {
                [_delegate AdPopcornSSPAdapterRewardVideoAdShowFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPNoRewardVideoAdLoaded userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPNoRewardVideoAdLoaded)}] adapter:self];
            }
        }
    }
    else if(_adType == SSPInterstitialVideoAdType)
    {
        if(interstitialVideoAd){
            [interstitialVideoAd presentFromRootViewController:_viewController];
        }
        else{
            if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdShowFailError:adapter:)])
            {
                [_delegate AdPopcornSSPAdapterInterstitialVideoAdShowFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPNoInterstitialVideoAdLoaded userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPNoInterstitialVideoAdLoaded)}] adapter:self];
            }
        }
    }
}

- (void)closeAd
{
    NSLog(@"PangleAdapter closeAd");
    _isCurrentRunningAdapter = NO;
}

- (void)loadRequest
{
    // Not used any more
}

-(void)networkScheduleTimeoutHandler:(NSTimer*) timer
{
    if(_adType == SSPRewardVideoAdType)
    {
        NSLog(@"PangleAdapter rv load timeout");
        if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdLoadFailError:adapter:)])
        {
            [_delegate AdPopcornSSPAdapterRewardVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
        }
    }
    else if(_adType == SSPInterstitialVideoAdType)
    {
        NSLog(@"PangleAdapter iv load timeout");
        if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:adapter:)])
        {
            [_delegate AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
        }
    }
    [self invalidateNetworkTimer];
}

-(void)invalidateNetworkTimer
{
    if(networkScheduleTimer != nil)
        [networkScheduleTimer invalidate];
}

#pragma mark PAGRewardedAdDelegate, PAGLInterstitialAdDelegate
- (void)adDidShow:(PAGRewardedAd *)ad {
    NSLog(@"PangleAdapter adDidShow");
    if(_adType == SSPRewardVideoAdType)
    {
        if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdShowSuccess:)])
        {
            [_delegate AdPopcornSSPAdapterRewardVideoAdShowSuccess:self];
        }
    }
    else if(_adType == SSPInterstitialVideoAdType)
    {
        if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdShowSuccess:)])
        {
            [_delegate AdPopcornSSPAdapterInterstitialVideoAdShowSuccess:self];
        }
    }
}

- (void)adDidClick:(PAGRewardedAd *)ad {
    NSLog(@"PangleAdapter adDidClick");
}

- (void)adDidDismiss:(PAGRewardedAd *)ad {
    NSLog(@"PangleAdapter adDidDismiss");
    if(_adType == SSPRewardVideoAdType)
    {
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdClose:)])
        {
            [_delegate AdPopcornSSPAdapterRewardVideoAdClose:self];
        }
        _isCurrentRunningAdapter = NO;
    }
    else if(_adType == SSPInterstitialVideoAdType)
    {
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdClose:)])
        {
            [_delegate AdPopcornSSPAdapterInterstitialVideoAdClose:self];
        }
        _isCurrentRunningAdapter = NO;
    }
}

#pragma mark PAGRewardedAdDelegate
- (void)rewardedAd:(PAGRewardedAd *)rewardedAd userDidEarnReward:(PAGRewardModel *)rewardModel {
    NSLog(@"PangleAdapter reward earned! rewardName:%@ rewardMount:%ld",rewardModel.rewardName,(long)rewardModel.rewardAmount);
    if ([_delegate respondsToSelector:@selector(onCompleteTrackingEvent:isCompleted:)])
    {
        [_delegate onCompleteTrackingEvent:adNetworkNo isCompleted:YES];
    }
}
@end
