//
//  SaveToPhotoViewController.m
//  ImageTailor
//
//  Created by dl on 2018/5/20.
//  Copyright © 2018年 dl. All rights reserved.
//

#import "SaveToPhotoViewController.h"
#import "UIAlertView+BlocksKit.h"
#import <sys/sysctl.h>
#import <mach/mach.h>

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
    
    __block CGFloat maxImageVector = 0.f;
    [self.assetModels enumerateObjectsUsingBlock:^(TailorAssetModel * _Nonnull assetModel, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat originImageWidth = assetModel.asset.pixelWidth * (assetModel.normalizedCropRect.size.width);
        CGFloat originImageHeight = assetModel.asset.pixelHeight * (assetModel.normalizedCropRect.size.height);
        CGFloat imageVector = isVertically ? originImageWidth : originImageHeight;
        maxImageVector = MAX(maxImageVector, imageVector);
    }];
    __block CGFloat otherSideSum = 0.f;
    [self.assetModels enumerateObjectsUsingBlock:^(TailorAssetModel * _Nonnull assetModel, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat originImageWidth = assetModel.asset.pixelWidth * (assetModel.normalizedCropRect.size.width);
        CGFloat originImageHeight = assetModel.asset.pixelHeight * (assetModel.normalizedCropRect.size.height);
        
        CGFloat enlargeScale = isVertically ? (maxImageVector / originImageWidth) : (maxImageVector / originImageHeight);
        otherSideSum += (isVertically ? originImageHeight : originImageWidth) * enlargeScale;
    }];
    
    // 判断是否图片过大
    // 占用内存大小不能超过当前总内存大小的一半
    CGFloat memoryToUse = maxImageVector * otherSideSum * 8 / 1024 / 1024;
    CGFloat totalMemorySize = [self totalMemorySize] * 0.7;
    CGFloat usedMemory = [self usedMemory];
    CGFloat reduceScale = 1.f;
    if (totalMemorySize - usedMemory < memoryToUse) {
        reduceScale = (totalMemorySize - usedMemory) / memoryToUse;
    }
//    NSLog(@"reduceScale: %@,memoryToUse: %@,totalMemorySize: %@, availableMemory: %@, usedMemory: %@",
//          @(reduceScale),
//          @(memoryToUse),
//          @([self totalMemorySize]),
//          @([self availableMemory]),
//          @([self usedMemory]));
    
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
         targetSize:CGSizeMake(assetModel.asset.pixelWidth * reduceScale, assetModel.asset.pixelHeight * reduceScale)
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
        __block CGFloat otherSideSum = 0.f;
        [images enumerateObjectsUsingBlock:^(UIImage *image, NSUInteger idx, BOOL * _Nonnull stop) {
            CGFloat imageVector = (isVertically ? image.size.width : image.size.height) * image.scale;
            otherSideSum += (isVertically ? image.size.height : image.size.width) * image.scale;
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
        
        CGFloat enlargeScale = (isVertically ? maxImageVector : imageVerticalVectorSum) / CGRectGetWidth(self.imageViewsUnionRect);
        CGSize extraMarginSize = CGSizeZero;
        CGSize imageContextSize = CGSizeMake(isVertically ? maxImageVector : imageVerticalVectorSum,
                                             isVertically ? imageVerticalVectorSum : maxImageVector);
        CGRect phoneBoundsRect = CGRectMake(self.phoneBoundsImageView.left * enlargeScale,
                                            self.phoneBoundsImageView.top * enlargeScale,
                                            self.phoneBoundsImageView.width * enlargeScale,
                                            self.phoneBoundsImageView.height * enlargeScale);
        UIImage *phoneBoundsResizedImage = nil;
        if (self.phoneBoundsImageView.image
            && CGRectContainsRect((CGRect){CGPointZero, phoneBoundsRect.size}, (CGRect){CGPointZero, imageContextSize})) {
            imageContextSize = phoneBoundsRect.size;
            extraMarginSize = CGSizeMake(-(phoneBoundsRect.origin.x - CGRectGetMinX(self.imageViewsUnionRect) * enlargeScale),
                                         -(phoneBoundsRect.origin.y - CGRectGetMinY(self.imageViewsUnionRect) * enlargeScale));
            phoneBoundsRect.origin = CGPointZero;
            
            // get resized phone bounds image
            UIImage *image = self.phoneBoundsImageView.image;
            CGSize resizedSize = CGSizeMake(image.size.width, image.size.width / imageContextSize.width * imageContextSize.height);
            if (CGRectGetWidth(phoneBoundsRect) > CGRectGetHeight(phoneBoundsRect)) {
                resizedSize = CGSizeMake(image.size.width / imageContextSize.height * imageContextSize.width, image.size.height);
            }
            UIGraphicsBeginImageContext(resizedSize);
            [image drawInRect:(CGRect){CGPointZero, resizedSize}];
            phoneBoundsResizedImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        // draw on one bitmap
        UIGraphicsBeginImageContext(imageContextSize);
        
        CGFloat drawOneImageRatio = 20.f / images.count;
        // 绘制所有的原图
        [images enumerateObjectsUsingBlock:^(UIImage *image, NSUInteger idx, BOOL * _Nonnull stop) {
            CGRect imageRect = [imageRects[idx] CGRectValue];
            imageRect.origin = CGPointMake(CGRectGetMinX(imageRect) + extraMarginSize.width,
                                           CGRectGetMinY(imageRect) + extraMarginSize.height);
            [image drawInRect:imageRect];
            self.progress += drawOneImageRatio;
        }];
        
        // 绘制所有的马赛克图片
        [self.pixellateImageViews enumerateObjectsUsingBlock:^(UIImageView *pixellateImageView, NSUInteger idx, BOOL * _Nonnull stop) {
            UIImage *pixellateImage = pixellateImageView.image;
            CGRect frame = pixellateImageView.frame;
            CGRect pixellateRect = CGRectMake((frame.origin.x - self.imageViewsUnionRect.origin.x) * enlargeScale + extraMarginSize.width,
                                              (frame.origin.y - self.imageViewsUnionRect.origin.y) * enlargeScale + extraMarginSize.height,
                                              frame.size.width * enlargeScale,
                                              frame.size.height * enlargeScale);
            [pixellateImage drawInRect:pixellateRect];
            self.progress += 5.f;
        }];
        
        // 绘制水印
        CGRect watermarkDrawRect =
        CGRectMake((self.watermarkLabel.left - self.imageViewsUnionRect.origin.x) * enlargeScale + extraMarginSize.width,
                   (self.watermarkLabel.top - self.imageViewsUnionRect.origin.y) * enlargeScale + extraMarginSize.height,
                   self.watermarkLabel.width * enlargeScale,
                   self.watermarkLabel.height * enlargeScale);
        [self.watermarkLabel drawViewHierarchyInRect:watermarkDrawRect afterScreenUpdates:YES];
        
        // 辅助线
        [self.lineViews enumerateObjectsUsingBlock:^(UIView * line, NSUInteger idx, BOOL * _Nonnull stop) {
            CGRect lineRect = CGRectMake((line.left - self.imageViewsUnionRect.origin.x) * enlargeScale + extraMarginSize.width,
                                         (line.top - self.imageViewsUnionRect.origin.y) * enlargeScale + extraMarginSize.height,
                                         line.width * enlargeScale,
                                         line.height * enlargeScale);
            [line drawViewHierarchyInRect:lineRect afterScreenUpdates:YES];
        }];
        
        // 绘制边框
        if (phoneBoundsResizedImage) {
            [phoneBoundsResizedImage drawInRect:phoneBoundsRect];
        }
        
        UIImage *mergedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.progress += 5.f;
        
        [self saveImage:mergedImage];
    });
}


-(long long)totalMemorySize {
    return[NSProcessInfo processInfo].physicalMemory / 1024.0 / 1024.0;
}

// 获取当前设备可用内存(单位：MB）
- (double)availableMemory {
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(),
                                               HOST_VM_INFO,
                                               (host_info_t)&vmStats,
                                               &infoCount);
    if (kernReturn != KERN_SUCCESS) {
        return NSNotFound;
    }
    
    return ((vm_page_size *vmStats.free_count) / 1024.0) / 1024.0;
}

// 获取当前任务所占用的内存（单位：MB）
- (double)usedMemory {
    task_basic_info_data_t taskInfo;
    mach_msg_type_number_t infoCount = TASK_BASIC_INFO_COUNT;
    kern_return_t kernReturn = task_info(mach_task_self(),
                                         TASK_BASIC_INFO,
                                         (task_info_t)&taskInfo,
                                         &infoCount);
    if (kernReturn != KERN_SUCCESS) {
        return NSNotFound;
    }
    
    return taskInfo.resident_size / 1024.0 / 1024.0;
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
