//
//  SaveToPhotoViewController.m
//  ImageTailor
//
//  Created by dl on 2018/5/20.
//  Copyright © 2018年 dl. All rights reserved.
//

#import "SaveToPhotoViewController.h"
#import "UIAlertView+BlocksKit.h"

@interface SaveToPhotoViewController ()
@property (nonatomic, strong) UIVisualEffectView *blurBgView;
@property (nonatomic, strong) UIButton *closeBtn;

@property (nonatomic, strong) UIAlertView *alertView;
@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, assign) CGFloat progress;
@end

@implementation SaveToPhotoViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    self.blurBgView = [[UIVisualEffectView alloc] initWithEffect:blur];
    self.blurBgView.alpha = 0.f;
    [self.view addSubview:self.blurBgView];
    
    self.closeBtn = [[UIButton alloc] init];
    [self.closeBtn setImage:[UIImage imageNamed:@"btn_save_close_n"] forState:UIControlStateNormal];
    self.closeBtn.backgroundColor = [UIColor blackColor];
    self.closeBtn.clipsToBounds = YES;
    self.closeBtn.layer.cornerRadius = 25.f;
    [self.blurBgView.contentView addSubview:self.closeBtn];
    @weakify(self)
    [self.closeBtn bk_addEventHandler:^(id sender) {
        @strongify(self)
        self.alertView = [UIAlertView bk_showAlertViewWithTitle:@"提示" message:@"确定取消保存?" cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [self dismissAnimating];
            }
        }];
    } forControlEvents:UIControlEventTouchUpInside];
    
    [self saveToPhoto];
    
    [self.view addSubview:self.progressLabel];
    [self bk_addObserverForKeyPath:@"progress" task:^(id target) {
        if (self.progress == 100) {
            NSAttributedString *successAttr =
            [[NSAttributedString alloc] initWithString:@"保存成功" attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:60]}];
            self.progressLabel.attributedText = successAttr;
            [self.alertView dismissWithClickedButtonIndex:0 animated:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.6f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self dismissAnimating];
            });
        } else {
            NSMutableString *progressText = [NSMutableString stringWithFormat:@"%d", [@(self.progress) intValue]];
            [progressText appendString:@"%"];
            NSMutableAttributedString *attr =
            [[NSMutableAttributedString alloc] initWithString:progressText
                                                   attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:60]}];
            NSAttributedString *subTitle =
            [[NSAttributedString alloc] initWithString:@"\n正在生成图片中" attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13]}];
            [attr appendAttributedString:subTitle];
            self.progressLabel.attributedText = attr;
        }
    }];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [UIView animateWithDuration:0.3f animations:^{
        self.blurBgView.alpha = 1.f;
    }];
}

- (void)dismissAnimating {
    [UIView animateWithDuration:0.3f animations:^{
        self.blurBgView.alpha = 0.f;
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.blurBgView.frame = self.view.bounds;
    
    self.closeBtn.size = CGSizeMake(50.f, 50.f);
    self.closeBtn.right = self.blurBgView.right - 7.f;
    self.closeBtn.top = self.mergedSafeAreaInsets.top + 7.f;
    
    self.progressLabel.size = CGSizeMake(self.view.width, 120.f);
    self.progressLabel.center = self.view.center;
}

- (void) saveToPhoto {
    BOOL isVertically = self.tileDirection == TailorTileDirectionVertically;
    NSMutableArray *images = [@[] mutableCopy];
    dispatch_group_t requestGroup = dispatch_group_create();
    
    CGFloat fetchOneImageRatio = 40.f / self.assetModels.count;
    [self.assetModels enumerateObjectsUsingBlock:^(TailorAssetModel * _Nonnull assetModel, NSUInteger idx, BOOL * _Nonnull stop) {
        dispatch_group_enter(requestGroup);
        [images addObject:@(idx)];
        
        PHImageRequestOptions *options = [PHImageRequestOptions new];
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.resizeMode = PHImageRequestOptionsResizeModeExact;
        options.normalizedCropRect = assetModel.normalizedCropRect;
        
        [[PHCachingImageManager sharedInstance]
         requestImageForAsset:assetModel.asset
         targetSize:CGSizeMake(assetModel.asset.pixelWidth, assetModel.asset.pixelHeight)
         contentMode:PHImageContentModeDefault
         options:options
         resultHandler:^(UIImage *result, NSDictionary *info) {
             images[idx] = result;
             self.progress += fetchOneImageRatio;
             dispatch_group_leave(requestGroup);
         }];
    }];
    
    dispatch_group_notify(requestGroup, dispatch_get_main_queue(), ^{
        
        // 计算绘制每一个原图时(每个原图大小可能不一样)，应该绘制成的大小
        __block CGFloat maxImageVector = 0.f;
        [images enumerateObjectsUsingBlock:^(UIImage *image, NSUInteger idx, BOOL * _Nonnull stop) {
            CGFloat imageVector = (isVertically ? image.size.width : image.size.height) * image.scale;
            maxImageVector = MAX(maxImageVector, imageVector);
        }];
        __block CGFloat imageVerticalVectorSum = 0.f;
        __block CGRect preImageRect = CGRectZero;
        // 计算每个原图应该占用的大小
        NSArray<NSValue *> *imageRects = [images bk_map:^id(UIImage *image) {
            CGFloat enlargeScale = maxImageVector / (image.scale * (isVertically ? image.size.width : image.size.height));
            CGSize imageSize = CGSizeMake(image.size.width * enlargeScale, image.size.height * enlargeScale);
            CGRect imageRect = CGRectMake(0.f, 0.f, imageSize.width, imageSize.height);
            if (isVertically) {
                imageRect.origin = CGPointMake(CGRectGetMinX(preImageRect), CGRectGetMaxY(preImageRect));
                imageVerticalVectorSum += imageSize.height;
            } else {
                imageRect.origin = CGPointMake(CGRectGetMaxX(preImageRect), CGRectGetMinY(preImageRect));
                imageVerticalVectorSum += imageSize.width;
            }
            preImageRect = imageRect;
            return [NSValue valueWithCGRect:imageRect];
        }];
        
        // draw on one bitmap
        UIGraphicsBeginImageContext(CGSizeMake(isVertically ? maxImageVector : imageVerticalVectorSum,
                                               isVertically ? imageVerticalVectorSum : maxImageVector));
        
        CGFloat drawOneImageRatio = 20.f / images.count;
        // 绘制所有的原图
        [images enumerateObjectsUsingBlock:^(UIImage *image, NSUInteger idx, BOOL * _Nonnull stop) {
            [image drawInRect:[imageRects[idx] CGRectValue]];
            self.progress += drawOneImageRatio;
        }];
        
        CGFloat enlargeScale = (isVertically ? maxImageVector : imageVerticalVectorSum) / CGRectGetWidth(self.imageViewsUnionRect);
        
        // 绘制所有的马赛克图片
        [self.pixellateImageViews enumerateObjectsUsingBlock:^(UIImageView *pixellateImageView, NSUInteger idx, BOOL * _Nonnull stop) {
            UIImage *pixellateImage = pixellateImageView.image;
            CGRect frame = pixellateImageView.frame;
            CGRect pixellateRect = CGRectMake((frame.origin.x - self.imageViewsUnionRect.origin.x) * enlargeScale,
                                              (frame.origin.y - self.imageViewsUnionRect.origin.y) * enlargeScale,
                                              frame.size.width * enlargeScale,
                                              frame.size.height * enlargeScale);
            [pixellateImage drawInRect:pixellateRect];
            self.progress += 5.f;
        }];
        
        // 绘制水印
        CGRect watermarkDrawRect = CGRectMake((self.watermarkLabel.left - self.imageViewsUnionRect.origin.x) * enlargeScale,
                                              (self.watermarkLabel.top - self.imageViewsUnionRect.origin.y) * enlargeScale,
                                              self.watermarkLabel.width * enlargeScale,
                                              self.watermarkLabel.height * enlargeScale);
        [self.watermarkLabel drawViewHierarchyInRect:watermarkDrawRect afterScreenUpdates:YES];
        
        UIImage *mergedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.progress += 5.f;
        
        [self saveImage:mergedImage];
    });
}

#pragma mark - others save image to photo
- (void) saveImage:(UIImage *)image {
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
}

- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSString *message = @"保存图片失败";
    if (!error) {
        message = @"成功保存到相册";
        self.progress = 100.f;
    }
    NSLog(@"saved msg: %@", message);
}

LazyPropertyWithInit(UILabel, progressLabel, {
    _progressLabel.textColor = [UIColor whiteColor];
    _progressLabel.textAlignment = NSTextAlignmentCenter;
    _progressLabel.numberOfLines = 0.f;
})
@end
