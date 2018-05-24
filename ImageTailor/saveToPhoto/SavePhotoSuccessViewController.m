//
//  SavePhotoSuccessViewController.m
//  ImageTailor
//
//  Created by dl on 2018/5/24.
//  Copyright © 2018年 dl. All rights reserved.
//

#import "SavePhotoSuccessViewController.h"
#import <BlocksKit/UIAlertView+BlocksKit.h>
#import "PreviewLargeImageViewController.h"

@interface SavePhotoSuccessViewController ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *bottomBtn;
@property (nonatomic, strong) UIView *extraBottomView;

@property (nonatomic, strong) UIView *bottomShareView;
@property (nonatomic, strong) UILabel *shareTitleLabel;
@property (nonatomic, strong) NSArray<UIButton *> *shareItemBtns;
@end

@implementation SavePhotoSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fd_interactivePopDisabled = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_navbar_back_n"]
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(navBack)];
    
    self.navigationItem.leftBarButtonItem = leftItem;
    self.title = @"以保存";
    
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.bottomBtn];
    [self.view addSubview:self.extraBottomView];
    
    [self.view addSubview:self.bottomShareView];
    [self.bottomShareView addSubview:self.shareTitleLabel];
    [self.shareItemBtns enumerateObjectsUsingBlock:^(UIButton * _Nonnull shareBtn, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.bottomShareView addSubview:shareBtn];
    }];
    
    [self loadImage];
}

- (void) loadImage {
    CGSize originImageSize = CGSizeMake(self.asset.pixelWidth, self.asset.pixelHeight);
    CGFloat smallSize = MIN(originImageSize.width, originImageSize.height);
    CGFloat largeSize = MAX(originImageSize.width, originImageSize.height);
    
    CGRect normalizedCropRect = CGRectZero;
    CGSize targetSize = CGSizeZero;
    if (originImageSize.width > originImageSize.height) {
        normalizedCropRect.origin.x = (largeSize - 2.f * smallSize) / largeSize / 2.f;
        normalizedCropRect.size.width = 2.f * smallSize / largeSize;
        normalizedCropRect.size.height = 1.f;
        targetSize = CGSizeMake(self.view.width * [UIScreen mainScreen].scale * 2.f, self.view.width * [UIScreen mainScreen].scale);
    } else {
        normalizedCropRect.origin.y = (largeSize - 2.f * smallSize) / largeSize / 2.f;
        normalizedCropRect.size.height = 2.f * smallSize / largeSize;
        normalizedCropRect.size.width = 1.f;
        targetSize = CGSizeMake(self.view.width * [UIScreen mainScreen].scale, self.view.width * [UIScreen mainScreen].scale * 2.f);
    }
    
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    options.normalizedCropRect = normalizedCropRect;
    
    [[PHCachingImageManager sharedInstance] requestImageForAsset:self.asset targetSize:targetSize contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        self.imageView.image = result;
    }];
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.imageView.frame = CGRectMake(20.f,
                                      self.mergedSafeAreaInsets.top + 12.f,
                                      self.view.width - 40.f,
                                      350.f / 335.f * (self.view.width - 40.f));
    self.extraBottomView.frame = CGRectMake(0.f, self.view.height - self.mergedSafeAreaInsets.bottom, self.view.width, self.mergedSafeAreaInsets.bottom);
    self.bottomBtn.frame = CGRectMake(0.f, self.extraBottomView.top - 50.f, self.view.width, 50.f);
    
    CGFloat shareViewTop = (self.imageView.bottom + self.bottomBtn.top) / 2.f - 48.f;
    self.bottomShareView.frame = CGRectMake(14.f, shareViewTop, self.view.width - 28.f, 96.f);
    self.shareTitleLabel.frame = CGRectMake(0.f, 0.f, self.view.width, 16.f);
    
    CGFloat shareBtnWidth = (self.view.width - 28.f) / 5.f;
    [self.shareItemBtns enumerateObjectsUsingBlock:^(UIButton *shareBtn, NSUInteger idx, BOOL * _Nonnull stop) {
        shareBtn.frame = CGRectMake(14.f + shareBtnWidth * idx, 16.f + (80.f - shareBtnWidth) / 2.f, shareBtnWidth, shareBtnWidth);
    }];
}

- (void) navBack {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - getters
LazyPropertyWithInit(UIImageView, imageView, {
    _imageView.backgroundColor = [UIColor hex_colorWithHex:0xE5F1F7];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.userInteractionEnabled = YES;
    @weakify(self)
    [_imageView bk_whenTapped:^{
        @strongify(self)
        PreviewLargeImageViewController *vc = [[PreviewLargeImageViewController alloc] init];
        vc.asset = self.asset;
        [self.navigationController presentViewController:vc animated:NO completion:nil];
    }];
})
LazyPropertyWithInit(UIButton, bottomBtn, {
    _bottomBtn.backgroundColor = [UIColor hex_colorWithHex:0x0036FF];
    [_bottomBtn setTitle:@"完成" forState:UIControlStateNormal];
    @weakify(self)
    [_bottomBtn bk_addEventHandler:^(id sender) {
        @strongify(self)
        [self navBack];
    } forControlEvents:UIControlEventTouchUpInside];
})
LazyPropertyWithInit(UIView, extraBottomView, {
    _extraBottomView.backgroundColor = self.bottomBtn.backgroundColor;
})
LazyPropertyWithInit(UIView, bottomShareView, {})
LazyPropertyWithInit(UILabel, shareTitleLabel, {
    _shareTitleLabel.text = @"分享到";
    _shareTitleLabel.textAlignment = NSTextAlignmentCenter;
    _shareTitleLabel.font = [UIFont systemFontOfSize:12];
    _shareTitleLabel.textColor = [UIColor hex_colorWithHex:0x98A2A6];
})
- (NSArray<UIButton *> *) shareItemBtns {
    if (!_shareItemBtns) {
        NSArray *shareItems = @[
                                @{@"icon": @"btn_share_wechat_n", @"url": @"wechat://"},
                                @{@"icon": @"btn_share_moments_n", @"url": @"wechat://"},
                                @{@"icon": @"btn_share_qq_n", @"url": @"mqq://"},
                                @{@"icon": @"btn_share_qqspace_n", @"url": @"mqq://"},
                                @{@"icon": @"btn_share_weibo_n", @"url": @"sinaweibo://"}
                                ];
        _shareItemBtns = [shareItems bk_map:^id(NSDictionary *shareItem) {
            UIButton *btn = [[UIButton alloc] init];
            [btn setImage:[UIImage imageNamed:shareItem[@"icon"]] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:shareItem[@"icon"]] forState:UIControlStateHighlighted];
            [btn bk_addEventHandler:^(id sender) {
                NSURL * url = [NSURL URLWithString:shareItem[@"url"]];
                BOOL canOpen = [[UIApplication sharedApplication] canOpenURL:url];
                if (canOpen) {
                    [[UIApplication sharedApplication] openURL:url];
                } else {
                    [UIAlertView bk_showAlertViewWithTitle:@"提示" message:@"请安装该应用" cancelButtonTitle:nil otherButtonTitles:@[@"确定"] handler:nil];
                }
            } forControlEvents:UIControlEventTouchUpInside];
            return btn;
        }];
    }
    return _shareItemBtns;
}
@end
