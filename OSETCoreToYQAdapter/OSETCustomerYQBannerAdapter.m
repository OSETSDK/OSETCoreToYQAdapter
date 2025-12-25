//
//  OSETCustomerYQBannerAdapter.m
//  MSaasAdapter
//
//  Created by Lurich on 2023/5/16.
//

#import "OSETCustomerYQBannerAdapter.h"

@interface OSETCustomerYQBannerAdapter ()

@property (nonatomic, strong) UIView *parentView;

@end

@implementation OSETCustomerYQBannerAdapter

- (void)loadADWithModel:(SFAdSourcesModel *)model{
    NSString *jsonStr = model.ext;
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if (dic && !err) {
        
        if(![OSETManager checkConfigure]){
            [OSETManager configure:dic[@"appId"]];
        }
        
        CGRect rect = {CGPointZero, self.size};
        self.parentView = [UIView new];
        self.parentView.frame = rect;
        self.bannerAd = [[OSETBannerAd alloc] initWithSlotId:dic[@"posId"] rootViewController:self.showAdController  rect:rect];
        self.bannerAd.delegate = self;
        [self.bannerAd loadAdData];
    } else {
        NSLog(@"自定义json字符串解析有误 error = %@",err);
        self.baseModel.type = 2;
        self.baseModel.error = [NSError errorWithDomain:@"自定义json字符串解析有误" code:409 userInfo:nil];
        if (self.successBlock) {
            self.successBlock(self.baseModel);
        }
    }
    
}

/// 发起请求
- (void)bannerOnAdRequest{
    NSLog(@"自定义转接器-奇点广告回调：%s",__func__);
}

/// 展现
-(void)bannerOnExposure{
    NSLog(@"自定义转接器-奇点广告回调：%s",__func__);

}

/// 点击
-(void)bannerOnClick{

}

/// 关闭
-(void)bannerOnAdClose{

}

- (void)bannerDidReceiveSuccess:(id)bannerView slotId:(NSString *)slotId{
    //返回的banner高度可能会与初始化传入的高度 不完全一样 所以可以动态获取一下高度比较安全
    if([bannerView isKindOfClass:[UIView class]]){
        UIView * banner = bannerView;
        banner.frame = CGRectMake(0,0, banner.frame.size.width, banner.frame.size.height);
    }
    NSLog(@"自定义转接器-奇点广告回调：%s",__func__);
    if([bannerView isKindOfClass:[OSETBaseView class]]){
        OSETBaseView * bv = bannerView;
        NSLog(@"eCPM = %zd",[bv eCPM]);
        if (self.baseModel.adType == SFSDKBidAD) {
            self.baseModel.bidfloor = bv.eCPM;
        }
    }
    self.baseModel.type = 1;
    if (self.successBlock) {
        self.successBlock(self.baseModel);
    }
}
/// banner加载失败
- (void)bannerLoadToFailed:(id)bannerView error:(NSError *)error{
    NSLog(@"自定义转接器-奇点广告回调：%s \n error = %@",__func__, error);
    self.baseModel.type = 2;
    self.baseModel.error = error;
    if (self.successBlock) {
        self.successBlock(self.baseModel);
    }
}
-(void)bannerDidClick:(id)bannerView{
    NSLog(@"自定义转接器-奇点广告回调：%s",__func__);
    self.baseModel.type = 3;
    if (self.successBlock) {
        self.successBlock(self.baseModel);
    }
}
-(void)bannerDidClose:(id)bannerView{
    
    self.baseModel.type = 5;
    if (self.successBlock) {
        self.successBlock(self.baseModel);
    }
    if([bannerView isKindOfClass:[UIView class]]){
        UIView *view = (UIView *)bannerView;
        [view removeFromSuperview];
    }
}
/**
 * 广告展示
 */
- (void)showBannerAdWithView:(UIView *)view{
    if (self.baseModel.adType == SFSDKBidAD) {
//        [self.WMad sendWinNotificationWithInfo:nil];
    }
    self.parentView.frame = view.bounds;
    [view addSubview:self.parentView];
//    self.baseModel.type = 6;
//    if (self.successBlock) {
//        self.successBlock(self.baseModel);
//    }
}

@end
