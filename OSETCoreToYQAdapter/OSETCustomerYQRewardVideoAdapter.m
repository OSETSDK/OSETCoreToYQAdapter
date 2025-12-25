//
//  OSETCustomerYQRewardVideoAdapter.m
//  MSaasAdapter
//
//  Created by YJoo on 2025/8/5.
//

#import "OSETCustomerYQRewardVideoAdapter.h"

@implementation OSETCustomerYQRewardVideoAdapter

- (void)loadADWithModel:(SFAdSourcesModel *)model{
    NSString *jsonStr = model.ext;
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if (dic && !err) {
        if(![OSETManager checkConfigure]){
            [OSETManager configure:dic[@"appId"]];
        }
        self.rewardVideoAd = [[OSETRewardVideoAd alloc] initWithSlotId:dic[@"posId"] withUserId:@"userId"];
        self.rewardVideoAd.delegate = self;
        [self.rewardVideoAd loadRewardAdData];
        
    } else {
        NSLog(@"自定义json字符串解析有误 error = %@",err);
        self.baseModel.type = 2;
        self.baseModel.error = [NSError errorWithDomain:@"自定义json字符串解析有误" code:409 userInfo:nil];
        if (self.successBlock) {
            self.successBlock(self.baseModel);
        }
    }
}
/**
 发起请求
 */
- (void)rewardVideoOnAdRequest{
}
- (void)rewardVideoDidReceiveSuccess:(nonnull id)rewardVideoAd slotId:(nonnull NSString *)slotId {
    NSLog(@"自定义转接器-奇点广告回调：%s",__func__);
    NSLog(@"eCPM = %zd",[self.rewardVideoAd eCPM]);
    if (self.baseModel.adType == SFSDKBidAD) {
        self.baseModel.bidfloor = self.rewardVideoAd.eCPM;
    }
    self.baseModel.type = 1;
    if (self.successBlock) {
        self.successBlock(self.baseModel);
    }

}
- (void)rewardVideoDidExposured:(id)rewardVideoAd{
    self.baseModel.type = 6;
    if (self.successBlock) {
        self.successBlock(self.baseModel);
    }
}
- (void)rewardVideoLoadToFailed:(nonnull id)rewardVideoAd error:(nonnull NSError *)error {
    NSLog(@"自定义转接器-奇点广告回调：%s \n error = %@",__func__, error);
    self.baseModel.type = 2;
    self.baseModel.error = [NSError errorWithDomain:@"自定义json字符串解析有误" code:409 userInfo:nil];
    if (self.successBlock) {
        self.successBlock(self.baseModel);
    }
}

- (void)rewardVideoDidClick:(nonnull id)rewardVideoAd {
    self.baseModel.type = 3;
    if (self.successBlock) {
        self.successBlock(self.baseModel);
    }
}
/// 激励视频关闭
- (void)rewardVideoDidClose:(id)rewardVideoAd checkString:(NSString *)checkString{
    self.baseModel.type = 5;
    if (self.successBlock) {
        self.successBlock(self.baseModel);
    }
}
//激励视频播放结束
- (void)rewardVideoPlayEnd:(id)rewardVideoAd  checkString:(NSString *)checkString{
    self.baseModel.type = 9;
    self.baseModel.status = SFMediaPlayerStatusStoped;
    if (self.successBlock) {
        self.successBlock(self.baseModel);
    }

}
- (void)rewardVideoPlayError:(id)rewardVideoAd error:(NSError *)error{
    self.baseModel.type = 9;
    self.baseModel.status = SFMediaPlayerStatusError;
    if (self.successBlock) {
        self.successBlock(self.baseModel);
    }
}
//激励视频开始播放
- (void)rewardVideoPlayStart:(id)rewardVideoAd checkString:(nonnull NSString *)checkString{
}
//激励视频奖励 //checkString 将在OSETRewardVideoAd对象 loadAdData 后失效
- (void)rewardVideoOnReward:(id)rewardVideoAd checkString:(NSString *)checkString{
    self.baseModel.type = 7;
    if (self.successBlock) {
        self.successBlock(self.baseModel);
    }
}
-(void)showRewardVideoAD
{
    if (self.baseModel.adType == SFSDKBidAD) {
//        [self.rewardVideoAd sendWinNotificationWithInfo:nil];
    }
    [self.rewardVideoAd showRewardFromRootViewController:self.showAdController];
}

@end
