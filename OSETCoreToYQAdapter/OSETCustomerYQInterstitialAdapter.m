//
//  OSETCustomerYQInterstitialAdapter.m
//  MSaasAdapter
//
//  Created by YJoo on 2025/8/5.
//

#import "OSETCustomerYQInterstitialAdapter.h"

@implementation OSETCustomerYQInterstitialAdapter

- (void)loadADWithModel:(SFAdSourcesModel *)model{
    NSString *jsonStr = model.ext;
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if (dic && !err) {
        if(![OSETManager checkConfigure]){
            [OSETManager configure:dic[@"appId"]];
        }
        self.interstitialAd = [[OSETInterstitialAd alloc] initWithSlotId:dic[@"posId"]];
        self.interstitialAd.delegate = self;
        [self.interstitialAd loadInterstitialAdData];
    } else {
        NSLog(@"自定义json字符串解析有误 error = %@",err);
        self.baseModel.type = 2;
        self.baseModel.error = [NSError errorWithDomain:@"自定义json字符串解析有误" code:409 userInfo:nil];
        if (self.successBlock) {
            self.successBlock(self.baseModel);
        }
    }
}


- (void)interstitialDidReceiveSuccess:(nonnull id)interstitialAd slotId:(nonnull NSString *)slotId {
    if (self.baseModel.adType == SFSDKBidAD) {
        self.baseModel.bidfloor = self.interstitialAd.eCPM;
    }
    self.baseModel.type = 1;
    if (self.successBlock) {
        self.successBlock(self.baseModel);
    }
}

- (void)interstitialLoadToFailed:(nonnull id)interstitialAd error:(nonnull NSError *)error {
    self.baseModel.type = 2;
    self.baseModel.error = [NSError errorWithDomain:@"自定义json字符串解析有误" code:409 userInfo:nil];
    if (self.successBlock) {
        self.successBlock(self.baseModel);
    }
}

- (void)interstitialDidClick:(nonnull id)interstitialAd {
    self.baseModel.type = 3;
    if (self.successBlock) {
        self.successBlock(self.baseModel);
    }
}

- (void)interstitialDidClose:(nonnull id)interstitialAd {
    self.baseModel.type = 5;
    if (self.successBlock) {
        self.successBlock(self.baseModel);
    }
}
- (void)interstitialExposured:(id)interstitialAd{
    self.baseModel.type = 6;
    if (self.successBlock) {
        self.successBlock(self.baseModel);
    }
}
/**
 * 插屏广告展示
 */
-(void)showInterstitialAd
{
//    if (self.baseModel.adType == SFSDKBidAD) {
//        [self.WMad sendWinNotificationWithInfo:nil];
//    }
//    
    [self.interstitialAd showInterstitialFromRootViewController:self.showAdController];

}

@end
