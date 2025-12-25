//
//  CustomOSETNativeManager.h
//  MSaasAdapter
//
//  Created by YJoo on 2025/8/5.
//

#import <MSaas/MSaas.h>
#import <OSETSDK/OSETSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface OSETCustomerYQNativeAdapter : SFBaseManager<OSETNativeDataAdDelegate,OSETNativeAdDelegate>

@property (nonatomic, strong) OSETNativeDataAd *naticeDataAd;
@property(nonatomic,strong) OSETNativeAd *nativeAd;

@end

NS_ASSUME_NONNULL_END
