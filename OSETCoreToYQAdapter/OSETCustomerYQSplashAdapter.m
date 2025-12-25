//
//  OSETCustomerYQSplashAdapter.m
//  AdDemo
//

#import "OSETCustomerYQSplashAdapter.h"

@implementation OSETCustomerYQSplashAdapter

- (void)loadADWithModel:(SFAdSourcesModel *)model{
    NSString *jsonStr = model.ext;
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if (dic && !err) {
        if(![OSETManager checkConfigure]){
            [OSETManager configure:dic[@"appId"]];
        }
        if (self.bottomView) {
            UIImageView *bottomView = [[UIImageView alloc] initWithFrame:self.bottomView.frame];
            bottomView.backgroundColor = [UIColor whiteColor];
            bottomView.image = [self imageFromView:self.bottomView];
            self.splashAd = [[OSETSplashAd alloc] initWithSlotId:dic[@"posId"] window:nil bottomView:bottomView];
        }else{
            self.splashAd = [[OSETSplashAd alloc] initWithSlotId:dic[@"posId"] window:nil bottomView:[UIImageView new]];
        }
        self.splashAd.delegate = self;
        [self.splashAd loadSplashAd];
    } else {
        NSLog(@"自定义json字符串解析有误 error = %@",err);
        self.baseModel.type = 2;
        self.baseModel.error = [NSError errorWithDomain:@"自定义json字符串解析有误" code:409 userInfo:nil];
        if (self.successBlock) {
            self.successBlock(self.baseModel);
        }
    }
}

///发起请求
- (void)splashOnAdRequest{
    NSLog(@"自定义转接器-奇点广告回调：%s",__func__);
}

- (void)splashDidReceiveSuccess:(id)splashAd slotId:(NSString *)slotId{
//    [self.splashAd showSplashAd];
    NSLog(@"自定义转接器-奇点广告回调：%s",__func__);
    NSLog(@"eCPM = %zd",[self.splashAd eCPM]);
    if (self.baseModel.adType == SFSDKBidAD) {
        self.baseModel.bidfloor = self.splashAd.eCPM;
    }
    self.baseModel.type = 1;
    if (self.successBlock) {
        self.successBlock(self.baseModel);
    }
}

- (void)splashLoadToFailed:(id)splashAd error:(NSError *)error{
    NSLog(@"自定义转接器-奇点广告回调：%s \n error = %@",__func__, error);
    self.baseModel.type = 2;
    self.baseModel.error = error;
    if (self.successBlock) {
        self.successBlock(self.baseModel);
    }
}
- (void)splashAdExposured:(id)splashAd{
    NSLog(@"自定义转接器-奇点广告回调：%s",__func__);
    self.baseModel.type = 6;
    if (self.successBlock) {
        self.successBlock(self.baseModel);
    }
}
-(void)splashDidClick:(id)splashAd{
    NSLog(@"自定义转接器-奇点广告回调：%s",__func__);
    self.baseModel.type = 3;
    if (self.successBlock) {
        self.successBlock(self.baseModel);
    }
}

- (void)splashDidClose:(id)splashAd{
    NSLog(@"自定义转接器-奇点广告回调：%s",__func__);
    self.baseModel.type = 5;
    if (self.successBlock) {
        self.successBlock(self.baseModel);
    }

}
-(void)splashCloseTarget:(id)splashAd{
    self.baseModel.type = 4;
    if (self.successBlock) {
        self.successBlock(self.baseModel);
    }
}
- (void)splashWillClose:(id)splashAd{
    NSLog(@"oset-splashWillClose");
}
/**
 * 开屏广告展示
 */
- (void)showSplashAdInWindow:(UIWindow *)window withBottomView:(UIView *)bottomView{
    if (self.baseModel.adType == SFSDKBidAD) {
//        [self.WMad sendWinNotificationWithInfo:nil];
    }
    if(!window){
        window = [UIApplication sharedApplication].keyWindow;
    }
    self.splashAd.window = window;
    self.splashAd.bottomView = bottomView;
    [self.splashAd showSplashAd];
}

@end

