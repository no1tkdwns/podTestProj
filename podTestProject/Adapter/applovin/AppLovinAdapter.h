//
//  AppLovinAdapter.h
//  IgaworksDevApp
//
//  Created by 김민석 on 2022/03/31.
//  Copyright © 2022 AdPopcorn. All rights reserved.
//

#import <AppLovinSDK/AppLovinSDK.h>

// Using pod install / unity
#import <AdPopcornSSP/AdPopcornSSPAdapter.h>
// else
//#import "AdPopcornSSPAdapter.h"

@interface AppLovinAdapter : AdPopcornSSPAdapter
{
    ALAdView *appLovinBannerAdView;
    ALAd *interstitialAd, *interstitialVideoAd;
    ALIncentivizedInterstitialAd *rewardVideoAd;
}

@end
