//
//  OSETCustomerYQRewardVideoAdapter.h
//  MSaasAdapter
//
//  Created by YJoo on 2025/8/5.
//

#import <MSaas/MSaas.h>
#import <OSETSDK/OSETSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface OSETCustomerYQRewardVideoAdapter : SFBaseManager<OSETRewardVideoAdDelegate>

@property (nonatomic, strong) OSETRewardVideoAd *rewardVideoAd;

@end

NS_ASSUME_NONNULL_END
