//
//  OSETCustomerYQBannerAdapter.h
//  MSaasAdapter
//
//  Created by Lurich on 2023/5/16.
//

#import <MSaas/MSaas.h>
#import <OSETSDK/OSETSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface OSETCustomerYQBannerAdapter : SFBaseManager <OSETBannerAdDelegate>

@property (nonatomic, strong) OSETBannerAd *bannerAd;

@end

NS_ASSUME_NONNULL_END
