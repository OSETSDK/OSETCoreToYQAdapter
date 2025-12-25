//
//  OSETCustomerYQTemplateAdapter.m
//  MSaasAdapter
//
//  Created by YJoo on 2025/8/5.
//

#define kScreen_width [UIScreen mainScreen].bounds.size.width
#define kScreen_height [UIScreen mainScreen].bounds.size.height

#import "OSETCustomerYQTemplateAdapter.h"

@implementation OSETCustomerYQTemplateAdapter

- (void)loadADWithModel:(SFAdSourcesModel *)model{
    NSString *jsonStr = model.ext;
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    CGSize adSize = CGSizeMake(kScreen_width, kScreen_width/16*9);
    if (dic && !err) {
        if(![OSETManager checkConfigure]){
            [OSETManager configure:dic[@"appId"]];
        }
        self.nativeAd = [[OSETNativeAd alloc] initWithSlotId:dic[@"posId"] size:adSize rootViewController:self.showAdController];
        self.nativeAd.delegate = self;
        [self.nativeAd loadAdData];
    } else {
        self.baseModel.type = 2;
        self.baseModel.error = [NSError errorWithDomain:@"自定义json字符串解析有误" code:409 userInfo:nil];
        if (self.successBlock) {
            self.successBlock(self.baseModel);
        }
    }
}
- (void)renderViewWithViewArray:(NSArray *)viewArray{
    self.baseModel.type = 8;
    self.baseModel.views = viewArray;
    if (self.successBlock) {
        self.successBlock(self.baseModel);
    }
}

-(void)nativeExpressOnExposure:(NSString *)adTag
{
    self.baseModel.type = 6;
    if (self.successBlock) {
        self.successBlock(self.baseModel);
    }
}

/**
 * 原生模板广告点击回调
 */
- (void)nativeExpressOnClick:(NSString *)adTag
{

}
/**
 * 原生模板广告被关闭
 */
- (void)nativeExpressOnAdClose:(NSString *)adTag
{

//    if (self.WMad) {
////        [self.WMad removeFromSuperview];
//    }
    
}

- (void)nativeExpressAdLoadSuccessWithNative:(id)native nativeExpressViews:(NSArray *)nativeExpressViews{
//    NSLog(@"nativeExpressAdLoadSuccessWithNative====%@",nativeExpressViews);
//    [self.dataSource addObjectsFromArray:nativeExpressViews];
//    [self.collectionView reloadData];
    if(nativeExpressViews && nativeExpressViews.count > 0 && [nativeExpressViews.firstObject isKindOfClass:[OSETBaseView class]]){
        OSETBaseView * bv = nativeExpressViews.firstObject;
        self.baseModel.views = nativeExpressViews;
        if (self.baseModel.adType == SFSDKBidAD) {
            self.baseModel.bidfloor = bv.eCPM;
        }
        self.baseModel.type = 1;
        if (self.successBlock) {
            self.successBlock(self.baseModel);
        }
    }else{
        self.baseModel.type = 2;
        if (self.successBlock) {
            self.successBlock(self.baseModel);
        }
    }
 
    
}

- (void)nativeExpressAdRenderSuccess:(id)nativeExpressView{
//    NSLog(@"nativeExpressView====%@",nativeExpressView);
//    if (nativeExpressView){
//        [self.collectionView reloadData];
//    }else{
//        //要不就是nativeView为空 ,要不就是高度为0,不显示到tableView
//    }
}
- (void)nativeExpressAdFailedToLoad:(nonnull id)nativeExpressAd error:(nonnull NSError *)error {
    self.baseModel.type = 2;
    self.baseModel.error = error;
    if (self.successBlock) {
        self.successBlock(self.baseModel);
    }
}
- (void)nativeExpressAdFailedToRender:(nonnull id)nativeExpressView {
}
- (void)nativeExpressAdDidClick:(nonnull id)nativeExpressView {
    self.baseModel.type = 3;
    if (self.successBlock) {
        self.successBlock(self.baseModel);
    }
}
- (void)nativeExpressAdDidClose:(nonnull id)nativeExpressView {
    self.baseModel.type = 5;
    if (self.successBlock) {
        self.successBlock(self.baseModel);
    }
    if([nativeExpressView isKindOfClass:[UIView class]]){
        UIView * view = (UIView *)nativeExpressView;
        [view removeFromSuperview];
    }
}
@end
