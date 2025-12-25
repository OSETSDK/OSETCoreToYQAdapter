//
//  CustomOSETNativeManager.m
//  MSaasAdapter
//
//  Created by YJoo on 2025/8/5.
//

#import "OSETCustomerYQNativeAdapter.h"

#define kScreen_width [UIScreen mainScreen].bounds.size.width
#define kScreen_height [UIScreen mainScreen].bounds.size.height


@interface OSETCustomerYQNativeAdapter()<OSETNativeAdRendererDelegate>

@property(nonatomic,strong) OSETNativeAdRenderer *adRenderer;
@property (nonatomic, strong) NSMutableArray *viewsArray;

@end

@implementation OSETCustomerYQNativeAdapter

- (void)loadADWithModel:(SFAdSourcesModel *)model{
    NSString *jsonStr = model.ext;
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if (dic && !err) {
        if(![OSETManager checkConfigure]){
            [OSETManager configure:dic[@"appId"]];
        }
        if([dic[@"isExpressAd"] boolValue] == YES){
            CGSize adSize = CGSizeMake(kScreen_width, kScreen_width/16*9);
            self.nativeAd = [[OSETNativeAd alloc] initWithSlotId:dic[@"posId"] size:adSize rootViewController:self.showAdController];
            self.nativeAd.delegate = self;
            [self.nativeAd loadAdData];
        }else{
            self.naticeDataAd = [[OSETNativeDataAd alloc] initWithSlotId:dic[@"posId"] size:CGSizeZero rootViewController:self.showAdController];
            self.naticeDataAd.delegate = self;
            [self.naticeDataAd loadAdData];
        }
        
    } else {
        NSLog(@"自定义json字符串解析有误 error = %@",err);
        self.baseModel.type = 2;
        self.baseModel.error = [NSError errorWithDomain:@"自定义json字符串解析有误" code:409 userInfo:nil];
        if (self.successBlock) {
            self.successBlock(self.baseModel);
        }
    }
}

//广告发起请求回调
- (void)nativeAdOnRequest
{
    M_Log(@"奇点广告回调：%s",__func__);
}

/// 信息流加载成功
- (void)nativeDataAdLoadSuccessWithNative:(id)nativeDataAd nativeExpressViews:(NSArray<OSETNativeDataAdObject *> * _Nullable)nativeDataObjects{
    NSMutableArray *tmpArray = [NSMutableArray array];
    for (OSETNativeDataAdObject * adData in nativeDataObjects) {
        if (adData != nil) {
            self.adRenderer = [[OSETNativeAdRenderer alloc] init];
            self.adRenderer.dataObject= adData;
            self.adRenderer.viewController = self.showAdController;
            self.adRenderer.delegate = self;
            SFFeedAdData *feedData = [SFFeedAdData new];
            feedData.adContent = adData.desc;
            feedData.adTitle =  adData.title;
            feedData.adID = adData.hash;
//            [self loadImageFromURL:adData.adIconUrl completion:^(UIImage *image, NSError *error) {
//                if(image ){
//                    feedData.adLogoIcon = image;
//                }
//            }];
//            feedData.adLogoIcon = [self downloadImageSyncWithURL:adData.adIconUrl error:nil];
            feedData.logoUrl =adData.adIconUrl;
            if (adData.imageList.count > 0) {
                NSString *imageUrl = adData.imageList.firstObject[@"url"];
                if (imageUrl.length > 0) {
                    feedData.imageUrl =  imageUrl;
                }
            }
            feedData.data = adData;
            if (adData.isVideoAd) {
                feedData.isVideoAd = YES;
                feedData.mediaView = self.adRenderer.mediaView;
            }else{
                feedData.isVideoAd = NO;
            }
            feedData.iconUrl = adData.appIconUrl;
            feedData.adType = self.baseModel.adv_id;
            if(adData.buttonText &&  adData.buttonText.length > 0){
                feedData.buttonText = adData.buttonText;
            }
            [tmpArray addObject:feedData];
        }
    }
    if (tmpArray.count > 0) {
        OSETNativeDataAdObject * adData = nativeDataObjects.firstObject;
        self.baseModel.views = tmpArray;
        [self isValidBidECPMWithPrice:[adData eCPM]];
    } else {
        self.baseModel.type = 2;
        self.baseModel.error = [NSError errorWithDomain:@"没有广告填充" code:107 userInfo:nil];
        if (self.successBlock) {
            self.successBlock(self.baseModel);
        }
    }
}
/// 加载失败
/// @param nativeDataAd 信息流实例
/// @param error 错误信息
- (void)nativeDataAdFailedToLoad:(id)nativeDataAd error:(NSError *)error{
    self.baseModel.type = 2;
    self.baseModel.error = error;
    if (self.successBlock) {
        self.successBlock(self.baseModel);
    }
}
/**
 广告曝光回调
 */
- (void)OSETNativeAdRendererWillExpose:(OSETNativeAdRenderer *)renderer{

    self.baseModel.type = 6;
    if (self.successBlock) {
        self.successBlock(self.baseModel);
    }
}

/**
 广告点击回调
 */
- (void)OSETNativeAdRendererDidClick:(OSETNativeAdRenderer *)renderer{
    self.baseModel.type = 3;
    if (self.successBlock) {
        self.successBlock(self.baseModel);
    }
}

/**
 广告关闭回调
 */
- (void)OSETNativeAdRendererDidClose:(OSETNativeAdRenderer *)renderer{
    self.baseModel.type = 5;
    if (self.successBlock) {
        self.successBlock(self.baseModel);
    }
}

/**
 广告详情页关闭回调
 */
- (void)OSETNativeAdRendererDetailViewClosed:(OSETNativeAdRenderer *)renderer{
    
}
/**
 广告曝光回调

 */
- (void)OSETNativeDataAdViewWillExpose:(OSETNativeDataAdView *)nativeDataAdView{
    self.baseModel.type = 6;
    if (self.successBlock) {
        self.successBlock(self.baseModel);
    }
}
/**
 广告点击回调

 */
- (void)OSETNativeDataAdViewDidClick:(OSETNativeDataAdView *)nativeDataAdView{
    self.baseModel.type = 3;
    if (self.successBlock) {
        self.successBlock(self.baseModel);
    }
}

/**
 广告关闭回调

 */
- (void)OSETNativeDataAdViewDidClose:(OSETNativeDataAdView *)nativeDataAdView{
    self.baseModel.type =5;
    if (self.successBlock) {
        self.successBlock(self.baseModel);
    }
}

/**
 广告详情页关闭回调
 */
- (void)OSETNativeDataAdDetailViewClosed:(OSETNativeDataAdView *)nativeDataAdView{
    
}
/// 原生广告绑定视图和注册
- (void)registerAdViewForBindImage:(UIImageView *)view adData:(SFFeedAdData *)adData clickableViews:(NSArray *)views{
    [self.adRenderer registerContainerView:view withDataObject:adData.data];
    [self.adRenderer registerClickableViews:views];
}

/// 新版注册视图，必须子类去实现
- (void)registerAdForView:(UIView<SFNativeAdRenderProtocol> *)view adData:(SFFeedAdData *)adData{
    [self.adRenderer registerContainerView:view withDataObject:adData.data];
    [self.adRenderer registerClickableViews:view.clickViewArray];
}
- (void)changeAdViewController:(UIViewController *)adViewController Data:(SFFeedAdData *)adData{
    self.nativeAd.viewController = adViewController;
    if(self.adRenderer){
        if(self.adRenderer.dataObject == adData.data){
            self.adRenderer.viewController = adViewController;
        }
    }
}
- (void)registerAdView:(SFBannerView *)view adData:(SFFeedAdData *)adData {
//    NSLog(@"registerAdView:adData:");
}

- (void)registerAdView:(SFBannerView *)view adData:(SFFeedAdData *)adData clickableViews:(NSArray *)views{
  
}

- (void)deallocAllProperty{
    [super deallocAllProperty];
    [self.adRenderer unregisterDataObject];
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
    M_Log(@"奇点广告回调：%s",__func__);
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
    NSLog(@"自定义转接器-奇点广告回调：%s \n error = %@",__func__, error);
    self.baseModel.type = 2;
    self.baseModel.error = error;
    if (self.successBlock) {
        self.successBlock(self.baseModel);
    }
}
- (void)nativeExpressAdFailedToRender:(nonnull id)nativeExpressView {
    NSLog(@"1=渲染失败");
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
