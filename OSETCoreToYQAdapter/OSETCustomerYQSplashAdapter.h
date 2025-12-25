//
//  CustomGdtSplashManager.h
//  AdDemo
//
//  Created by lurich on 2021/9/14.
//


#import <MSaas/MSaas.h>
#import <OSETSDK/OSETSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface OSETCustomerYQSplashAdapter : SFBaseManager <OSETSplashAdDelegate>

@property (nonatomic, strong) OSETSplashAd * _Nullable splashAd;

@end

NS_ASSUME_NONNULL_END


