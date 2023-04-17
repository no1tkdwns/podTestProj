//
//  UnityAdsAdapter.m
//  AdPopcornSSP
//
//  Created by mick on 2019. 3. 19..
//  Copyright (c) 2019년 igaworks All rights reserved.

// compatible with UnityAds v4.2.1
#import "UnityAdsAdapter.h"

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

@interface UnityAdsAdapter () <UnityAdsInitializationDelegate, UnityAdsLoadDelegate, UnityAdsShowDelegate>
{
    NSString *_unityAdsRewardPlacementId, *_unityAdsInterstitialPlacementId;
    BOOL _isCurrentRunningAdapter;
    NSTimer *networkScheduleTimer;
    NSInteger adNetworkNo;
    BOOL isTestMode;
}

@end

@implementation UnityAdsAdapter

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
    adNetworkNo = 7;
    isTestMode = NO;
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
    NSLog(@"UnityAdsAdapter %@ : loadAd", self);
    if(networkScheduleTimer == nil)
    {
        networkScheduleTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(networkScheduleTimeoutHandler:) userInfo:nil repeats:NO];
    }
    else{
        [self invalidateNetworkTimer];
        networkScheduleTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(networkScheduleTimeoutHandler:) userInfo:nil repeats:NO];
    }
    
    if (_adType == SSPRewardVideoAdType)
    {
        _isCurrentRunningAdapter = YES;
        if (_integrationKey != nil)
        {
            NSString *_unityAdsGameId = [_integrationKey valueForKey:@"UnityGameId"];
            _unityAdsRewardPlacementId = [_integrationKey valueForKey:@"UnityPlacementId"];
            
            if([UnityAds isInitialized])
            {
                NSLog(@"UnityAds isInitialized true");
                [UnityAds load:_unityAdsRewardPlacementId loadDelegate:self];
            }
            else{
                NSLog(@"UnityAds try initialize");
                [UnityAds initialize:_unityAdsGameId testMode:isTestMode initializationDelegate:self];
            }
        }
        else
        {
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
        if (_integrationKey != nil)
        {
            NSString *_unityAdsGameId = [_integrationKey valueForKey:@"UnityGameId"];
            _unityAdsInterstitialPlacementId = [_integrationKey valueForKey:@"UnityPlacementId"];
            
            if([UnityAds isInitialized])
            {
                NSLog(@"UnityAds isInitialized true");
                [UnityAds load:_unityAdsInterstitialPlacementId loadDelegate:self];
            }
            else{
                NSLog(@"UnityAds try initialize");
                [UnityAds initialize:_unityAdsGameId testMode:isTestMode initializationDelegate:self];
            }
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
    NSLog(@"UnityAdsAdapter %@ : showAd", self);
    if (_adType == SSPRewardVideoAdType)
    {
        [UnityAds show:self.viewController placementId:_unityAdsRewardPlacementId showDelegate:self];
    }
    else if(_adType == SSPInterstitialVideoAdType)
    {
        [UnityAds show:self.viewController placementId:_unityAdsInterstitialPlacementId showDelegate:self];
    }
}

- (void)closeAd
{
    NSLog(@"UnityAdsAdapter closeAd");
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
        NSLog(@"UnityAds rv load timeout");
        if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdLoadFailError:adapter:)])
        {
            [_delegate AdPopcornSSPAdapterRewardVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
        }
    }
    else if(_adType == SSPInterstitialVideoAdType)
    {
        NSLog(@"UnityAds iv load timeout");
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

// Implement initialization callbacks to handle success or failure:
#pragma mark : UnityAdsInitializationDelegate
- (void)initializationComplete {
    NSLog(@" - UnityAdsInitializationDelegate initializationComplete" );
    // Pre-load an ad when initialization succeeds, so it is ready to show:
    if(_adType == SSPRewardVideoAdType)
    {
        [UnityAds load:_unityAdsRewardPlacementId loadDelegate:self];
    }
    else if(_adType == SSPInterstitialVideoAdType)
    {
        [UnityAds load:_unityAdsInterstitialPlacementId loadDelegate:self];
    }
}

- (void)initializationFailed:(UnityAdsInitializationError)error withMessage:(NSString *)message {
    NSLog(@" - UnityAdsInitializationDelegate initializationFailed with message: %@", message );
    [self invalidateNetworkTimer];
    if (_adType == SSPRewardVideoAdType)
    {
        if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdLoadFailError:adapter:)])
        {
            [_delegate AdPopcornSSPAdapterRewardVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
        }
    }
    else if(_adType == SSPInterstitialVideoAdType)
    {
        if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:adapter:)])
        {
            [_delegate AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
        }
    }
}

// Implement load callbacks to handle success or failure after initialization:
#pragma mark: UnityAdsLoadDelegate
- (void)unityAdsAdLoaded:(NSString *)adUnitId {
    NSLog(@" - UnityAdsLoadDelegate unityAdsAdLoaded placementId : %@", adUnitId);
    [self invalidateNetworkTimer];
    if (_adType == SSPRewardVideoAdType)
    {
        if([adUnitId isEqualToString:_unityAdsRewardPlacementId]){
            NSLog(@"UnityAdsAdapter : RV unityAdsReady");
            if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdLoadSuccess:)])
            {
                [_delegate AdPopcornSSPAdapterRewardVideoAdLoadSuccess:self];
            }
        }
    }
    else if(_adType == SSPInterstitialVideoAdType)
    {
        if([adUnitId isEqualToString:_unityAdsInterstitialPlacementId]){
            NSLog(@"UnityAdsAdapter : IV unityAdsReady");
            if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdLoadSuccess:)])
            {
                [_delegate AdPopcornSSPAdapterInterstitialVideoAdLoadSuccess:self];
            }
        }
    }
}

- (void)unityAdsAdFailedToLoad:(NSString *)adUnitId
                     withError:(UnityAdsLoadError)error
                   withMessage:(NSString *)message {
    NSLog(@" - UnityAdsLoadDelegate unityAdsAdFailedToLoad placementId : %@, message : %@", adUnitId, message);
    [self invalidateNetworkTimer];
    if (_adType == SSPRewardVideoAdType)
    {
        if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdLoadFailError:adapter:)])
        {
            [_delegate AdPopcornSSPAdapterRewardVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
        }
    }
    else if(_adType == SSPInterstitialVideoAdType)
    {
        if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:adapter:)])
        {
            [_delegate AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
        }
    }
}
// Implement callbacks for events related to the show method:
#pragma mark: UnityAdsShowDelegate
- (void)unityAdsShowComplete:(NSString *)adUnitId withFinishState:(UnityAdsShowCompletionState)state {
    NSLog(@" - UnityAdsShowDelegate unityAdsShowComplete placementId : %@, state : %ld", adUnitId, state);
    if(_adType == SSPRewardVideoAdType)
    {
        if (state == kUnityShowCompletionStateCompleted)
        {
            if ([_delegate respondsToSelector:@selector(onCompleteTrackingEvent:isCompleted:)])
            {
                [_delegate onCompleteTrackingEvent:adNetworkNo isCompleted:YES];
            }
        }
        else if(state == kUnityShowCompletionStateSkipped)
        {
            if ([_delegate respondsToSelector:@selector(onCompleteTrackingEvent:isCompleted:)])
            {
                [_delegate onCompleteTrackingEvent:adNetworkNo isCompleted:NO];
            }
        }
        
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdClose:)])
        {
            [_delegate AdPopcornSSPAdapterRewardVideoAdClose:self];
        }
    }
    else if(_adType == SSPInterstitialVideoAdType)
    {
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdClose:)])
        {
            [_delegate AdPopcornSSPAdapterInterstitialVideoAdClose:self];
        }
    }
    _isCurrentRunningAdapter = NO;
}

- (void)unityAdsShowFailed:(NSString *)adUnitId withError:(UnityAdsShowError)error withMessage:(NSString *)message {
    NSLog(@" - UnityAdsShowDelegate unityAdsShowFailed placementId : %@, message : %@", adUnitId, message);
    if (_adType == SSPRewardVideoAdType)
    {
        if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdShowFailError:adapter:)])
        {
            [_delegate AdPopcornSSPAdapterRewardVideoAdShowFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPNoRewardVideoAdLoaded userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPNoRewardVideoAdLoaded)}] adapter:self];
        }
    }
    else if(_adType == SSPInterstitialVideoAdType)
    {
        if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdShowFailError:adapter:)])
        {
            [_delegate AdPopcornSSPAdapterInterstitialVideoAdShowFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPNoInterstitialVideoAdLoaded userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPNoInterstitialVideoAdLoaded)}] adapter:self];
        }
    }
}

- (void)unityAdsShowStart:(NSString *)adUnitId {
    NSLog(@" - UnityAdsShowDelegate unityAdsShowStart placementId : %@", adUnitId);
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

- (void)unityAdsShowClick:(NSString *)adUnitId {
    NSLog(@" - UnityAdsShowDelegate unityAdsShowClick placementId : %@", adUnitId);
}
@end
