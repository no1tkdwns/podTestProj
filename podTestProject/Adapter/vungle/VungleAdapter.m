//
//  VungleAdapter.m
//  AdPopcornSSP
//
//  Created by mick on 2019. 3. 19..
//  Copyright (c) 2019년 igaworks All rights reserved.
//

// compatible with Vungle v6.12.0
#import "VungleAdapter.h"

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
        case AdPopcornSSPMediationInvalidIntegrationKey:
            return @"Invalid Integration Key";
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

@interface VungleAdapter () <VungleSDKDelegate, VungleSDKHBDelegate>
{
    BOOL _isCurrentRunningAdapter;
    NSString *vungleAppId, *vungleBannerPlacementId, *vungleRVPlacementId, *vungleIVPlacementId;
    NSTimer *networkScheduleTimer;
    NSInteger adNetworkNo;
    BOOL _isMute;
    NSMutableArray *_impTrackersListArray, *_clickTrackersListArray;
    NSString *_biddingData;
    BOOL _isInAppBidding;
}

@end

@implementation VungleAdapter

@synthesize delegate = _delegate;
@synthesize integrationKey = _integrationKey;
@synthesize viewController = _viewController;
@synthesize bannerView = _bannerView;

- (instancetype)init
{
    self = [super init];
    if (self){}
    adNetworkNo = 14;
    _isInAppBidding = NO;
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

- (void)setBiddingData:(NSString *)biddingData impressionList:(NSMutableArray *)impTrackersListArray clickList: (NSMutableArray *)clickTrackersListArray
{
    _biddingData = biddingData;
    _impTrackersListArray = impTrackersListArray;
    _clickTrackersListArray =  clickTrackersListArray;
}

- (void)setMute:(bool)mute
{
    _isMute = mute;
}

- (void)setInAppBiddingMode:(bool)isInAppBiddingMode
{
    _isInAppBidding = isInAppBiddingMode;
    NSLog(@"VungleAdapter setInAppBiddingMode : %d", _isInAppBidding);
}

- (void)loadAd
{
    if(_adType == SSPAdBannerType)
    {
        NSLog(@"VungleAdapter %@ : SSPAdBannerType loadAd : %d", self, _isInAppBidding);
        if (_integrationKey != nil)
        {
            if((_size.width == 300.0f && _size.height == 250.0f)
               || (_size.width == 320.0f && _size.height == 100.0f))
            {
                NSLog(@"%@ : Vungle can not load 300x250 or 320x100", self);
                if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterBannerViewLoadFailError:adapter:)])
                {
                    [_delegate AdPopcornSSPAdapterBannerViewLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
                }
                
                [self closeAd];
                return;
            }
            
            if(_isInAppBidding)
            {
                vungleAppId = @"";
                vungleBannerPlacementId = [_integrationKey valueForKey:@"vungle_placement_id"];
            }
            else
            {
                vungleAppId = [_integrationKey valueForKey:@"VungleAppId"];
                vungleBannerPlacementId = [_integrationKey valueForKey:@"VunglePlacementId"];
            }
            
            NSError* error;
            [VungleSDK sharedSDK].delegate = self;
            if(_isInAppBidding)
                [VungleSDK sharedSDK].sdkHBDelegate = self;
            if([[VungleSDK sharedSDK] isInitialized])
            {
                NSLog(@"VungleAdapter banner already initialized : %@", vungleBannerPlacementId);
                if(_isInAppBidding)
                {
                    if([[VungleSDK sharedSDK] isAdCachedForPlacementID:vungleBannerPlacementId adMarkup:_biddingData withSize:VungleAdSizeBanner])
                    {
                        NSLog(@"VungleAdapter banner already ready");
                        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterBannerViewLoadSuccess:)])
                        {
                            [_delegate AdPopcornSSPAdapterBannerViewLoadSuccess:self];
                        }
                    }
                    else
                    {
                        NSLog(@"VungleAdapter banner loadPlacementWithID");
                        if (![[VungleSDK sharedSDK] loadPlacementWithID:vungleBannerPlacementId adMarkup:_biddingData withSize:VungleAdSizeBanner error:&error]) {
                            NSLog(@"VungleAdapter banner inappBidding loadPlacementWithID error : %@", error);
                            if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterBannerViewLoadFailError:adapter:)])
                            {
                                [_delegate AdPopcornSSPAdapterBannerViewLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
                            }
                            [self closeAd];
                        }
                    }
                }
                else
                {
                    if([[VungleSDK sharedSDK] isAdCachedForPlacementID:vungleBannerPlacementId withSize:VungleAdSizeBanner])
                    {
                        NSLog(@"VungleAdapter banner already ready");
                        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterBannerViewLoadSuccess:)])
                        {
                            [_delegate AdPopcornSSPAdapterBannerViewLoadSuccess:self];
                        }
                    }
                    else
                    {
                        NSLog(@"VungleAdapter banner loadPlacementWithID");
                        if (![[VungleSDK sharedSDK] loadPlacementWithID:vungleBannerPlacementId withSize:VungleAdSizeBanner error:&error])
                        {
                            NSLog(@"VungleAdapter banner loadPlacementWithID error : %@", error);
                            if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterBannerViewLoadFailError:adapter:)])
                            {
                                [_delegate AdPopcornSSPAdapterBannerViewLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
                            }
                            [self closeAd];
                        }
                    }
                }
            }
            else
            {
                NSLog(@"VungleAdapter banner startWithAppId");
                [[VungleSDK sharedSDK] startWithAppId:vungleAppId error:&error];
            }
        }
        else
        {
            NSLog(@"VungleAdapter banner no integrationKey");
            if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterBannerViewLoadFailError:adapter:)])
            {
                [_delegate AdPopcornSSPAdapterBannerViewLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPMediationInvalidIntegrationKey userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPMediationInvalidIntegrationKey)}] adapter:self];
            }
            [self invalidateNetworkTimer];
        }
    }
    else if (_adType == SSPRewardVideoAdType)
    {
        NSLog(@"VungleAdapter %@ : SSPRewardVideoAdType loadAd : %d", self, _isInAppBidding);
        if(networkScheduleTimer == nil)
        {
            networkScheduleTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(networkScheduleTimeoutHandler:) userInfo:nil repeats:NO];
        }
        else{
            [self invalidateNetworkTimer];
            networkScheduleTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(networkScheduleTimeoutHandler:) userInfo:nil repeats:NO];
        }
        
        _isCurrentRunningAdapter = YES;
        if (_integrationKey != nil)
        {
            if(_isInAppBidding)
            {
                vungleAppId = @"";
                vungleRVPlacementId = [_integrationKey valueForKey:@"vungle_placement_id"];
            }
            else
            {
                vungleAppId = [_integrationKey valueForKey:@"VungleAppId"];
                vungleRVPlacementId = [_integrationKey valueForKey:@"VunglePlacementId"];
            }
                
            NSError* error;
            [VungleSDK sharedSDK].delegate = self;
            
            if(_isInAppBidding)
                [VungleSDK sharedSDK].sdkHBDelegate = self;
            if([[VungleSDK sharedSDK] isInitialized])
            {
                NSLog(@"VungleAdapter rv already initialized : %@", vungleRVPlacementId);
                if(_isInAppBidding)
                {
                    if([[VungleSDK sharedSDK] isAdCachedForPlacementID:vungleRVPlacementId adMarkup:_biddingData])
                    {
                        NSLog(@"VungleAdapter rv already ready");
                        if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdLoadSuccess:)])
                        {
                            [_delegate AdPopcornSSPAdapterRewardVideoAdLoadSuccess:self];
                        }
                        [self invalidateNetworkTimer];
                    }
                    else
                    {
                        NSLog(@"VungleAdapter rv loadPlacementWithID");
                        if(![[VungleSDK sharedSDK] loadPlacementWithID:vungleRVPlacementId adMarkup:_biddingData error:&error])
                        {
                            NSLog(@"VungleAdapter rv inAppBidding loadPlacementWithID error : %@", error);
                            if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdLoadFailError:adapter:)])
                            {
                                [_delegate AdPopcornSSPAdapterRewardVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
                            }
                            [self invalidateNetworkTimer];
                        }
                    }
                }
                else
                {
                    if([[VungleSDK sharedSDK] isAdCachedForPlacementID:vungleRVPlacementId])
                    {
                        NSLog(@"VungleAdapter rv already ready");
                        if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdLoadSuccess:)])
                        {
                            [_delegate AdPopcornSSPAdapterRewardVideoAdLoadSuccess:self];
                        }
                        [self invalidateNetworkTimer];
                    }
                    else
                    {
                        NSLog(@"VungleAdapter rv loadPlacementWithID");
                        if(![[VungleSDK sharedSDK] loadPlacementWithID:vungleRVPlacementId error:&error])
                        {
                            NSLog(@"VungleAdapter rv loadPlacementWithID error : %@", error);
                            if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdLoadFailError:adapter:)])
                            {
                                [_delegate AdPopcornSSPAdapterRewardVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
                            }
                            [self invalidateNetworkTimer];
                        }
                    }
                }
            }
            else
            {
                NSLog(@"VungleAdapter rv startWithAppId");
                [[VungleSDK sharedSDK] startWithAppId:vungleAppId error:&error];
            }
        }
        else
        {
            NSLog(@"VungleAdapter rv no integrationKey");
            if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdLoadFailError:adapter:)])
            {
                [_delegate AdPopcornSSPAdapterRewardVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPMediationInvalidIntegrationKey userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPMediationInvalidIntegrationKey)}] adapter:self];
            }
            [self invalidateNetworkTimer];
        }
    }
    else if(_adType == SSPInterstitialVideoAdType)
    {
        NSLog(@"VungleAdapter %@ : SSPInterstitialVideoAdType loadAd", self);
        if(networkScheduleTimer == nil)
        {
            networkScheduleTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(networkScheduleTimeoutHandler:) userInfo:nil repeats:NO];
        }
        else{
            [self invalidateNetworkTimer];
            networkScheduleTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(networkScheduleTimeoutHandler:) userInfo:nil repeats:NO];
        }
        _isCurrentRunningAdapter = YES;
        if (_integrationKey != nil)
        {
            if(_isInAppBidding)
            {
                vungleAppId = @"";
                vungleIVPlacementId = [_integrationKey valueForKey:@"vungle_placement_id"];
            }
            else
            {
                vungleAppId = [_integrationKey valueForKey:@"VungleAppId"];
                vungleIVPlacementId = [_integrationKey valueForKey:@"VunglePlacementId"];
            }
            
            NSError* error;
            [VungleSDK sharedSDK].delegate = self;
            if(_isInAppBidding)
                [VungleSDK sharedSDK].sdkHBDelegate = self;
            if([[VungleSDK sharedSDK] isInitialized])
            {
                NSLog(@"VungleAdapter iv already initialized : %@", vungleIVPlacementId);
                if(_isInAppBidding)
                {
                    if([[VungleSDK sharedSDK] isAdCachedForPlacementID:vungleIVPlacementId adMarkup:_biddingData])
                    {
                        NSLog(@"VungleAdapter iv already ready");
                        if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdLoadSuccess:)])
                        {
                            [_delegate AdPopcornSSPAdapterInterstitialVideoAdLoadSuccess:self];
                        }
                        [self invalidateNetworkTimer];
                    }
                    else
                    {
                        NSLog(@"VungleAdapter iv loadPlacementWithID");
                        if(![[VungleSDK sharedSDK] loadPlacementWithID:vungleIVPlacementId adMarkup:_biddingData error:&error])
                        {
                            NSLog(@"VungleAdapter iv inAppBidding loadPlacementWithID error : %@", error);
                            if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:adapter:)])
                            {
                                [_delegate AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
                            }
                            [self invalidateNetworkTimer];
                        }
                    }
                }
                else
                {
                    if([[VungleSDK sharedSDK] isAdCachedForPlacementID:vungleIVPlacementId])
                    {
                        NSLog(@"VungleAdapter iv already ready");
                        if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdLoadSuccess:)])
                        {
                            [_delegate AdPopcornSSPAdapterInterstitialVideoAdLoadSuccess:self];
                        }
                        [self invalidateNetworkTimer];
                    }
                    else
                    {
                        NSLog(@"VungleAdapter iv loadPlacementWithID");
                        if(![[VungleSDK sharedSDK] loadPlacementWithID:vungleIVPlacementId error:&error])
                        {
                            NSLog(@"VungleAdapter iv loadPlacementWithID error : %@", error);
                            if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:adapter:)])
                            {
                                [_delegate AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
                            }
                            [self invalidateNetworkTimer];
                        }
                    }
                }
            }
            else
            {
                NSLog(@"VungleAdapter iv startWithAppId");
                [[VungleSDK sharedSDK] startWithAppId:vungleAppId error:&error];
            }
        }
        else
        {
            NSLog(@"VungleAdapter iv no integrationKey");
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
    NSLog(@"VungleAdapter : showAd : %d", _adType);
    [VungleSDK sharedSDK].delegate = self;
    NSError *error;
    if (_adType == SSPRewardVideoAdType)
    {
        if(_isInAppBidding)
        {
            if([[VungleSDK sharedSDK] isAdCachedForPlacementID:vungleRVPlacementId adMarkup:_biddingData])
            {
                NSLog(@"VungleAdapter RV playAd : %@", vungleRVPlacementId);
                NSDictionary *options = nil;
                if(_isMute)
                    options = @{VunglePlayAdOptionKeyStartMuted:@(1)};
                else
                    options = @{VunglePlayAdOptionKeyStartMuted:@(0)};
                [[VungleSDK sharedSDK] playAd:_viewController options:options placementID:vungleRVPlacementId adMarkup:_biddingData error:&error];
                if (error)
                {
                    NSLog(@"VungleAdapter RV Error encountered playing ad: %@", error);
                    if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdShowFailError:adapter:)])
                    {
                        [_delegate AdPopcornSSPAdapterRewardVideoAdShowFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPNoRewardVideoAdLoaded userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPNoRewardVideoAdLoaded)}] adapter:self];
                    }
                }
                else
                {
                    if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdShowSuccess:)])
                    {
                        [_delegate AdPopcornSSPAdapterRewardVideoAdShowSuccess:self];
                    }
                }
            }
            else
            {
                NSLog(@"VungleAdapter RV play fail");
                if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdShowFailError:adapter:)])
                {
                    [_delegate AdPopcornSSPAdapterRewardVideoAdShowFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPNoRewardVideoAdLoaded userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPNoRewardVideoAdLoaded)}] adapter:self];
                }
            }
        }
        else
        {
            if([[VungleSDK sharedSDK] isAdCachedForPlacementID:vungleRVPlacementId])
            {
                NSLog(@"VungleAdapter RV playAd : %@", vungleRVPlacementId);
                NSDictionary *options = nil;
                if(_isMute)
                    options = @{VunglePlayAdOptionKeyStartMuted:@(1)};
                else
                    options = @{VunglePlayAdOptionKeyStartMuted:@(0)};
                [[VungleSDK sharedSDK] playAd:_viewController options:options placementID:vungleRVPlacementId error:&error];
                
                if (error)
                {
                    NSLog(@"VungleAdapter RV Error encountered playing ad: %@", error);
                    if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdShowFailError:adapter:)])
                    {
                        [_delegate AdPopcornSSPAdapterRewardVideoAdShowFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPNoRewardVideoAdLoaded userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPNoRewardVideoAdLoaded)}] adapter:self];
                    }
                }
                else
                {
                    if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdShowSuccess:)])
                    {
                        [_delegate AdPopcornSSPAdapterRewardVideoAdShowSuccess:self];
                    }
                }
            }
            else
            {
                NSLog(@"VungleAdapter RV play fail");
                if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdShowFailError:adapter:)])
                {
                    [_delegate AdPopcornSSPAdapterRewardVideoAdShowFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPNoRewardVideoAdLoaded userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPNoRewardVideoAdLoaded)}] adapter:self];
                }
            }
        }
    }
    else if(_adType == SSPInterstitialVideoAdType)
    {
        if(_isInAppBidding)
        {
            if([[VungleSDK sharedSDK] isAdCachedForPlacementID:vungleIVPlacementId adMarkup:_biddingData])
            {
                NSLog(@"VungleAdapter IV playAd : %@", vungleIVPlacementId);
                NSDictionary *options = nil;
                if(_isMute)
                    options = @{VunglePlayAdOptionKeyStartMuted:@(1)};
                else
                    options = @{VunglePlayAdOptionKeyStartMuted:@(0)};
                [[VungleSDK sharedSDK] playAd:_viewController options:options placementID:vungleIVPlacementId adMarkup:_biddingData error:&error];
                if (error) {
                    NSLog(@"VungleAdapter IV Error encountered playing ad: %@", error);
                    if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdShowFailError:adapter:)])
                    {
                        [_delegate AdPopcornSSPAdapterInterstitialVideoAdShowFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPNoInterstitialVideoAdLoaded userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPNoInterstitialVideoAdLoaded)}] adapter:self];
                    }
                }
                else
                {
                    if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdShowSuccess:)])
                    {
                        [_delegate AdPopcornSSPAdapterInterstitialVideoAdShowSuccess:self];
                    }
                }
            }
            else
            {
                NSLog(@"VungleAdapter IV play fail");
                if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdShowFailError:adapter:)])
                {
                    [_delegate AdPopcornSSPAdapterInterstitialVideoAdShowFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPNoInterstitialVideoAdLoaded userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPNoInterstitialVideoAdLoaded)}] adapter:self];
                }
            }
        }
        else
        {
            if([[VungleSDK sharedSDK] isAdCachedForPlacementID:vungleIVPlacementId])
            {
                NSLog(@"VungleAdapter IV playAd : %@", vungleIVPlacementId);
                NSDictionary *options = nil;
                if(_isMute)
                    options = @{VunglePlayAdOptionKeyStartMuted:@(1)};
                else
                    options = @{VunglePlayAdOptionKeyStartMuted:@(0)};
                [[VungleSDK sharedSDK] playAd:_viewController options:options placementID:vungleIVPlacementId error:&error];
                if (error) {
                    NSLog(@"VungleAdapter IV Error encountered playing ad: %@", error);
                    if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdShowFailError:adapter:)])
                    {
                        [_delegate AdPopcornSSPAdapterInterstitialVideoAdShowFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPNoInterstitialVideoAdLoaded userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPNoInterstitialVideoAdLoaded)}] adapter:self];
                    }
                }
                else
                {
                    if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdShowSuccess:)])
                    {
                        [_delegate AdPopcornSSPAdapterInterstitialVideoAdShowSuccess:self];
                    }
                }
            }
            else
            {
                NSLog(@"VungleAdapter IV play fail");
                if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdShowFailError:adapter:)])
                {
                    [_delegate AdPopcornSSPAdapterInterstitialVideoAdShowFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPNoInterstitialVideoAdLoaded userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPNoInterstitialVideoAdLoaded)}] adapter:self];
                }
            }
        }
    }
}

- (void)closeAd
{
    NSLog(@"VungleAdapter closeAd");
    if(_adType == SSPAdBannerType)
    {
        if(_isInAppBidding)
            [[VungleSDK sharedSDK] finishDisplayingAd:vungleBannerPlacementId adMarkup:_biddingData];
        else
            [[VungleSDK sharedSDK] finishDisplayingAd:vungleBannerPlacementId];
    }
    else{
        _isCurrentRunningAdapter = NO;
    }
}

- (void)loadRequest
{
    // Not used any more
}

-(void)networkScheduleTimeoutHandler:(NSTimer*) timer
{
    if(_adType == SSPRewardVideoAdType)
    {
        NSLog(@"VungleAdapter rv load timeout");
        if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdLoadFailError:adapter:)])
        {
            [_delegate AdPopcornSSPAdapterRewardVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
        }
    }
    else if(_adType == SSPInterstitialVideoAdType)
    {
        NSLog(@"VungleAdapter iv load timeout");
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

#pragma VungleSDKDelegate
- (void)vungleSDKDidInitialize {
    NSLog(@"VungleAdapter vungleSDKDidInitialize");
    NSError *error;
    if(_adType == SSPAdBannerType)
    {
        if(_isInAppBidding)
        {
            if (![[VungleSDK sharedSDK] loadPlacementWithID:vungleBannerPlacementId adMarkup:_biddingData withSize:VungleAdSizeBanner error:&error]) {
                NSLog(@"VungleAdapter banner inAppBidding loadPlacementWithID error : %@", error);
                if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterBannerViewLoadFailError:adapter:)])
                {
                    [_delegate AdPopcornSSPAdapterBannerViewLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
                }
                [self closeAd];
            }
        }
        else
        {
            if (![[VungleSDK sharedSDK] loadPlacementWithID:vungleBannerPlacementId withSize:VungleAdSizeBanner error:&error]) {
                NSLog(@"VungleAdapter banner loadPlacementWithID error : %@", error);
                if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterBannerViewLoadFailError:adapter:)])
                {
                    [_delegate AdPopcornSSPAdapterBannerViewLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
                }
                [self closeAd];
            }
        }
    }
    else if(_adType == SSPRewardVideoAdType)
    {
        if(_isInAppBidding)
        {
            if (![[VungleSDK sharedSDK] loadPlacementWithID:vungleRVPlacementId adMarkup:_biddingData error:&error]) {

                if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdLoadFailError:adapter:)])
                {
                    [_delegate AdPopcornSSPAdapterRewardVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
                }
				[self invalidateNetworkTimer];
            }
        }
        else
        {
            if (![[VungleSDK sharedSDK] loadPlacementWithID:vungleRVPlacementId error:&error]) {
                NSLog(@"VungleAdapter rv loadPlacementWithID error : %@", error);
                if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdLoadFailError:adapter:)])
                {
                    [_delegate AdPopcornSSPAdapterRewardVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
                }
				[self invalidateNetworkTimer];
            }
        }
    }
    else if(_adType == SSPInterstitialVideoAdType)
    {
        if(_isInAppBidding)
        {
            if (![[VungleSDK sharedSDK] loadPlacementWithID:vungleIVPlacementId adMarkup:_biddingData error:&error]) {
                NSLog(@"VungleAdapter iv inAppBidding loadPlacementWithID error : %@", error);
                if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:adapter:)])
                {
                    [_delegate AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
                }
                [self invalidateNetworkTimer];
            }
        }
        else
        {
            if (![[VungleSDK sharedSDK] loadPlacementWithID:vungleIVPlacementId error:&error]) {
                NSLog(@"VungleAdapter iv loadPlacementWithID error : %@", error);
                if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:adapter:)])
                {
                    [_delegate AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
                }
                [self invalidateNetworkTimer];
            }
        }
    }
}

- (void)vungleAdPlayabilityUpdate:(BOOL)isAdPlayable placementID:(NSString *)placementID error:(NSError *)error {
    if(_adType == SSPAdBannerType)
    {
        NSLog(@"VungleAdapter Banner vungleAdPlayabilityUpdate : %d", isAdPlayable);
        NSError *error;
        if (![[VungleSDK sharedSDK] addAdViewToView:_bannerView withOptions:nil placementID:vungleBannerPlacementId error:&error]) {
            NSLog(@"VungleAdapter Banner addAdViewToView error : %@", error);
            if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterBannerViewLoadFailError:adapter:)])
            {
              [_delegate AdPopcornSSPAdapterBannerViewLoadFailError:[AdPopcornSSPError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPNoAd userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPNoAd)}] adapter:self];
            }
            
            [self closeAd];
        }
        else
        {
            if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterBannerViewLoadSuccess:)])
            {
                [_delegate AdPopcornSSPAdapterBannerViewLoadSuccess:self];
            }
        }
    }
    else if(_adType == SSPRewardVideoAdType)
    {
        [self invalidateNetworkTimer];
        NSLog(@"VungleAdapter RV vungleAdPlayabilityUpdate : %d", isAdPlayable);
        if (isAdPlayable)
        {
            if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdLoadSuccess:)])
            {
                [_delegate AdPopcornSSPAdapterRewardVideoAdLoadSuccess:self];
            }
        }
        else
        {
            if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdLoadFailError:adapter:)])
            {
                [_delegate AdPopcornSSPAdapterRewardVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
            }
        }
    }
    else if(_adType == SSPInterstitialVideoAdType)
    {
        [self invalidateNetworkTimer];
        NSLog(@"VungleAdapter IV vungleAdPlayabilityUpdate : %d", isAdPlayable);
        if (isAdPlayable)
        {
            if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdLoadSuccess:)])
            {
                [_delegate AdPopcornSSPAdapterInterstitialVideoAdLoadSuccess:self];
            }
        }
        else
        {
            if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:adapter:)])
            {
                [_delegate AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
            }
        }
    }
}

- (void)vungleDidCloseAdForPlacementID:(nonnull NSString *)placementID
{
    NSLog(@"VungleAdapter vungleDidCloseAdForPlacementID");
    if(_adType == SSPRewardVideoAdType)
    {
        
        if ([_delegate respondsToSelector:@selector(onCompleteTrackingEvent:isCompleted:)])
        {
            [_delegate onCompleteTrackingEvent:adNetworkNo isCompleted:YES];
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

- (void)vungleRewardUserForPlacementID:(nullable NSString *)placementID
{
    NSLog(@"VungleAdapter vungleRewardUserForPlacementID : %@", placementID);
}

#pragma VungleSDKHBDelegate
/**
 * If implemented, this will get called when the SDK has an ad ready to be displayed. Also it will
 * get called with an argument `NO` for `isAdPlayable` when for some reason, there is
 * no ad available, for instance there is a corrupt ad or the OS wiped the cache.
 * Please note that receiving a `NO` here does not mean that you can't play an Ad: if you haven't
 * opted-out of our Exchange, you might be able to get a streaming ad if you call `play`.
 * @param isAdPlayable A boolean indicating if an ad is currently in a playable state
 * @param placementID The ID of a placement which is ready to be played
 * @param adMarkup The ad markup of an adUnit which is ready to be played.
 * @param error The error that was encountered.  This is only sent when the placementID is nil.
 */
- (void)vungleAdPlayabilityUpdate:(BOOL)isAdPlayable placementID:(nullable NSString *)placementID adMarkup:(nullable NSString *)adMarkup error:(nullable NSError *)error
{
    if(_adType == SSPAdBannerType)
    {
        NSLog(@"VungleAdapter HB Banner vungleAdPlayabilityUpdate : %d", isAdPlayable);
        NSError *error;
        if (![[VungleSDK sharedSDK] addAdViewToView:_bannerView withOptions:nil placementID:vungleBannerPlacementId adMarkup:_biddingData error:&error]) {
            NSLog(@"VungleAdapter HB Banner addAdViewToView error : %@", error);
            if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterBannerViewLoadFailError:adapter:)])
            {
              [_delegate AdPopcornSSPAdapterBannerViewLoadFailError:[AdPopcornSSPError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPNoAd userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPNoAd)}] adapter:self];
            }
            
            [self closeAd];
        }
        else{
            if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterBannerViewLoadSuccess:)])
            {
                [_delegate AdPopcornSSPAdapterBannerViewLoadSuccess:self];
            }
        }
    }
    else if(_adType == SSPRewardVideoAdType)
    {
        [self invalidateNetworkTimer];
        NSLog(@"VungleAdapter HB RV vungleAdPlayabilityUpdate : %d", isAdPlayable);
        if (isAdPlayable)
        {
            if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdLoadSuccess:)])
            {
                [_delegate AdPopcornSSPAdapterRewardVideoAdLoadSuccess:self];
            }
        }
        else
        {
            if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdLoadFailError:adapter:)])
            {
                [_delegate AdPopcornSSPAdapterRewardVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
            }
        }
    }
    else if(_adType == SSPInterstitialVideoAdType)
    {
        [self invalidateNetworkTimer];
        NSLog(@"VungleAdapter HB IV vungleAdPlayabilityUpdate : %d", isAdPlayable);
        if (isAdPlayable)
        {
            if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdLoadSuccess:)])
            {
                [_delegate AdPopcornSSPAdapterInterstitialVideoAdLoadSuccess:self];
            }
        }
        else
        {
            if (_isCurrentRunningAdapter && [_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:adapter:)])
            {
                [_delegate AdPopcornSSPAdapterInterstitialVideoAdLoadFailError:[NSError errorWithDomain:kAdPopcornSSPErrorDomain code:AdPopcornSSPLoadAdFailed userInfo:@{NSLocalizedDescriptionKey: SSPErrorString(AdPopcornSSPLoadAdFailed)}] adapter:self];
            }
        }
    }
}

/**
 * If implemented, this will be called when the ad is first rendered for the specified placement.
 * @NOTE: Please use this callback to track views.
 * @param placementID The placement ID of the advertisement shown
 * @param adMarkup The ad markup of the advertisement shown.
 */
- (void)vungleAdViewedForPlacementID:(nullable NSString *)placementID adMarkup:(nullable NSString *)adMarkup
{
    NSLog(@"VungleAdapter HB vungleAdViewedForPlacementID");
    for(NSString *url in _impTrackersListArray)
    {
        if ([_delegate respondsToSelector:@selector(impClickTracking:)])
        {
            [_delegate impClickTracking:url];
        }
    }
}

/**
 * If implemented, this method gets called when a Vungle Ad Unit has been completely dismissed.
 * At this point, you can load another ad for non-auto-cached placement if necessary.
 * @param placementID The placement ID of the advertisement that has been closed.
 * @param adMarkup The ad markup of the advertisement that has been closed.
 */
- (void)vungleDidCloseAdForPlacementID:(nullable NSString *)placementID adMarkup:(nullable NSString *)adMarkup
{
    if(_adType == SSPRewardVideoAdType)
    {
        NSLog(@"VungleAdapter HB RV vungleDidCloseAdForPlacementID");

        if ([_delegate respondsToSelector:@selector(onCompleteTrackingEvent:isCompleted:)])
        {
            [_delegate onCompleteTrackingEvent:adNetworkNo isCompleted:YES];
        }
        
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterRewardVideoAdClose:)])
        {
            [_delegate AdPopcornSSPAdapterRewardVideoAdClose:self];
        }
    }
    else if(_adType == SSPInterstitialVideoAdType)
    {
        NSLog(@"VungleAdapter HB IV vungleDidCloseAdForPlacementID");
        if ([_delegate respondsToSelector:@selector(AdPopcornSSPAdapterInterstitialVideoAdClose:)])
        {
            [_delegate AdPopcornSSPAdapterInterstitialVideoAdClose:self];
        }
    }
    _isCurrentRunningAdapter = NO;
}

/**
 * If implemented, this method gets called when user clicks the Vungle Ad.
 * At this point, it's recommended to track the click event.
 * @param placementID The placement ID of the advertisement shown.
 * @param adMarkup The ad markup of the advertisement shown
 */
- (void)vungleTrackClickForPlacementID:(nullable NSString *)placementID adMarkup:(nullable NSString *)adMarkup
{
    NSLog(@"VungleAdapter HB vungleTrackClickForPlacementID");
    for(NSString *url in _clickTrackersListArray)
    {
        if ([_delegate respondsToSelector:@selector(impClickTracking:)])
        {
            [_delegate impClickTracking:url];
        }
    }
}

/**
 * If implemented, this method gets called when user taps the Vungle Ad
 * which will cause them to leave the current application(e.g. the ad action
 * opens the iTunes store, Mobile Safari, etc).
 * @param placementID The placement ID of the advertisement about to leave the current application.
 * @param adMarkup The ad markup of the advertisement about to leave the current application.
 */
- (void)vungleWillLeaveApplicationForPlacementID:(nullable NSString *)placementID adMarkup:(nullable NSString *)adMarkup
{
    NSLog(@"VungleAdapter HB vungleWillLeaveApplicationForPlacementID");
}

/**
 * This method is called when the user should be rewarded for watching a Rewarded Video Ad.
 * At this point, it's recommended to reward the user.
 * @param placementID The placement ID of the advertisement shown.
 * @param adMarkup The ad markup of the advertisement shown.
 */
- (void)vungleRewardUserForPlacementID:(nullable NSString *)placementID adMarkup:(nullable NSString *)adMarkup
{
    NSLog(@"VungleAdapter HB vungleRewardUserForPlacementID");
}

- (NSString *)getBiddingToken
{
    return [[VungleSDK sharedSDK] currentSuperTokenForPlacementID:nil forSize:0];
}

@end
