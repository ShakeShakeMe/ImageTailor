//
//  ScrawlZoomingScollView.m
//  ImageTailor
//
//  Created by dl on 2018/5/5.
//  Copyright © 2018年 dl. All rights reserved.
//

#import "ScrawlZoomingScollView.h"

static void *kPixellateLayerImageKey = &kPixellateLayerImageKey;
static CIWarpKernel *customKernel = nil;

@interface ScrawlZoomingScollView()<UIScrollViewDelegate>
@property (nonatomic, strong) UIView *imageContainerView;
@property (nonatomic, strong) NSArray<UIImageView *> *imageViews;

@property (nonatomic, assign, readwrite) TailorTileDirection tileDirection;
@property (nonatomic, strong, readwrite) NSArray<TailorAssetModel *> *assetModels;

@property (nonatomic, assign) CGPoint defaultContentOffset;

// pixellate
@property (nonatomic, strong) UIImage *snapshotImage;
@property (nonatomic, assign) ScrawlToolBarPixellateType pixellateType;
@property (nonatomic, strong) CALayer *smallRadiusPixellateImageLayer;
@property (nonatomic, strong) CALayer *middleRadiusPixellateImageLayer;
@property (nonatomic, strong) CALayer *largeRadiusPixellateImageLayer;
@property (nonatomic, strong) CAShapeLayer *pixellateDrawLayer;
@property (nonatomic, strong) NSMutableArray<UIImageView *> *pixellateImageViews;
@property (nonatomic, strong) UITouch *startTouch;
@property (nonatomic, assign) CGPoint startTouchPoint;

@property (nonatomic, assign) CGMutablePathRef path;
@property (nonatomic, assign) CGRect imageViewsUnionRect;

// water mark < © >
@property (nonatomic, strong) UILabel *watermarkLabel;
@end

@implementation ScrawlZoomingScollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.imageContainerView];
        self.pixellateImageViews = [@[] mutableCopy];
        
        self.scrollsToTop = NO;
        self.delegate = self;
        self.minimumZoomScale = TailorMinZoomingScale;
        self.maximumZoomScale = TailorMaxZoomingScale;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;

        [self.imageContainerView addSubview:self.watermarkLabel];
    }
    return self;
}

- (void) viewDidAppear {
    self.defaultContentOffset = CGPointZero;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    BOOL isVertically = self.tileDirection == TailorTileDirectionVertically;
    CGFloat imageFixedTiledValue = isVertically ? self.width : self.height;
    __block UIView *preView = nil;
    __block CGFloat growingTileSum = 0.f;
    
    __block CGRect imageViewsUnionRect = CGRectZero;
    [self.imageViews enumerateObjectsUsingBlock:^(UIImageView * _Nonnull imageView, NSUInteger idx, BOOL * _Nonnull stop) {
        TailorAssetModel *model = self.assetModels[idx];
        CGFloat width = isVertically ? imageFixedTiledValue : imageFixedTiledValue * model.scaledImageSize.width / model.scaledImageSize.height;
        CGFloat height = isVertically ? imageFixedTiledValue * model.scaledImageSize.height / model.scaledImageSize.width : imageFixedTiledValue;
        CGFloat x = isVertically ? (imageFixedTiledValue - width) : (preView ? preView.right : 0.f);
        CGFloat y = isVertically ? (preView ? preView.bottom : 0.f) : (imageFixedTiledValue - height);
        
        if (isVertically) {
            x += (1.f - model.normalizedCropRect.size.width) / 2.f * width;
        } else {
            y += (1.f - model.normalizedCropRect.size.height) / 2.f * height;
        }
        
        width *= model.normalizedCropRect.size.width;
        height *= model.normalizedCropRect.size.height;
        
        imageView.frame = CGRectMake(x, y, width, height);
        imageViewsUnionRect = CGRectUnion(imageViewsUnionRect, imageView.frame);
        
        growingTileSum += isVertically ? height : width;
        preView = imageView;
    }];
    self.imageViewsUnionRect = imageViewsUnionRect;
    
    CGFloat contentSizeWidth = (isVertically ? self.width : growingTileSum) * self.zoomScale;
    CGFloat contentSizeHeight = (isVertically ? growingTileSum : self.height)  * self.zoomScale;
    CGSize containerViewSize = CGSizeMake(contentSizeWidth, contentSizeHeight);
    self.contentSize = containerViewSize;
    if (!CGPointEqualToPoint(self.defaultContentOffset, CGPointZero)) {
        self.contentOffset = self.defaultContentOffset;
    }
    
    // Center the container view as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = (CGRect){CGPointZero, containerViewSize};
    // Horizontally
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
    } else {
        frameToCenter.origin.x = 0;
    }
    
    // Vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2.0);
    } else {
        frameToCenter.origin.y = 0;
    }
    self.imageContainerView.frame = frameToCenter;
    
    self.watermarkLabel.frame = CGRectMake(0.f, CGRectGetHeight(imageViewsUnionRect) - 40.f, self.watermarkLabel.width, 40.f);
    if (self.watermarkLabel.textAlignment == NSTextAlignmentLeft) {
        self.watermarkLabel.left = 0.f;
    } else if(self.watermarkLabel.textAlignment == NSTextAlignmentRight) {
        self.watermarkLabel.right = CGRectGetWidth(imageViewsUnionRect);
    } else {
        self.watermarkLabel.centerX = CGRectGetMidX(imageViewsUnionRect);
    }
    
    NSLog(@"layoutsubvies");
}

#pragma mark - refresh
- (void) refreshWithAssetModels:(NSArray<TailorAssetModel *> *)assetModels
                  tileDirection:(TailorTileDirection)tileDirection
               defaultZoomScale:(CGFloat) zoomScale
           defaultContentOffset:(CGPoint)contentOffset {
    self.tileDirection = tileDirection;
    self.assetModels = [assetModels copy];
    
    // remove from super view
    [self.imageViews bk_each:^(UIImageView *imageView) {
        [imageView removeFromSuperview];
    }];
    self.imageViews = [assetModels bk_map:^id(TailorAssetModel *model) {
        UIImageView *imageView = [[UIImageView alloc] init];
        [model loadImageCliped:YES completion:^(UIImage *image) {
            imageView.image = image;
        }];
        imageView.backgroundColor = [UIColor hex_randomColorWithAlpha:0.5f];
        [self.imageContainerView addSubview:imageView];
        return imageView;
    }];
    
    // others
    if (tileDirection == TailorTileDirectionVertically) {
        self.alwaysBounceVertical = YES;
        self.alwaysBounceHorizontal = NO;
    } else {
        self.alwaysBounceVertical = NO;
        self.alwaysBounceHorizontal = YES;
    }
    
    self.zoomScale = zoomScale;
    self.defaultContentOffset = contentOffset;
    
    [self.imageContainerView bringSubviewToFront:self.watermarkLabel];
    [self setNeedsLayout];
}

#pragma mark - pixellate
- (void) beginDoPixellateWithType:(ScrawlToolBarPixellateType)pixellateType {
    @weakify(self)
    [self generateSnapshotWithCompletion:^(UIImage *snapshot) {
        @strongify(self)
        self.pixellateType = pixellateType;
        [self generatePixellateImage];
        self.panGestureRecognizer.minimumNumberOfTouches = 2;
        
        if (pixellateType == ScrawlToolBarPixellateTypeSmall) {
            [self.imageContainerView.layer addSublayer:self.smallRadiusPixellateImageLayer];
            self.smallRadiusPixellateImageLayer.mask = self.pixellateDrawLayer;
        } else if (pixellateType == ScrawlToolBarPixellateTypeMiddle) {
            [self.imageContainerView.layer addSublayer:self.middleRadiusPixellateImageLayer];
            self.middleRadiusPixellateImageLayer.mask = self.pixellateDrawLayer;
        } else {
            [self.imageContainerView.layer addSublayer:self.largeRadiusPixellateImageLayer];
            self.largeRadiusPixellateImageLayer.mask = self.pixellateDrawLayer;
        }
    }];
}

- (void) endDoPixllate {
    self.pixellateType = ScrawlToolBarPixellateTypeNone;
    self.panGestureRecognizer.minimumNumberOfTouches = 1;
    
    [self.smallRadiusPixellateImageLayer removeFromSuperlayer];
    [self.middleRadiusPixellateImageLayer removeFromSuperlayer];
    [self.largeRadiusPixellateImageLayer removeFromSuperlayer];
    self.pixellateDrawLayer.path = NULL;
}

- (void) pixellateWithdraw {
    UIImageView *lastPixellateImageView = self.pixellateImageViews.lastObject;
    [lastPixellateImageView removeFromSuperview];
    [self.pixellateImageViews removeObject:lastPixellateImageView];
    [self setNeedsLayout];
}

#pragma mark - weater mark
- (void) showWatermarkWithAlignment:(NSTextAlignment)alignment text:(NSString *)text {
    self.watermarkLabel.textAlignment = alignment;
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor blackColor];
    shadow.shadowOffset = CGSizeMake(6.f, 6.f);
    shadow.shadowBlurRadius = 6.f;
    self.watermarkLabel.attributedText = [[NSAttributedString alloc] initWithString:(text ?: @"")
                                                                         attributes:@{NSShadowAttributeName: shadow}];
    self.watermarkLabel.hidden = text.length == 0;
    [self.watermarkLabel sizeToFit];
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    if (!self.watermarkLabel.hidden) {
        CGRect visableWaterLabelRect = [self.imageContainerView convertRect:self.watermarkLabel.frame toView:self];
        visableWaterLabelRect = CGRectMake(MIN(CGRectGetMinX(visableWaterLabelRect), MAX(self.contentSize.width, 0.f)),
                                           MIN(CGRectGetMinY(visableWaterLabelRect), MAX(self.contentSize.height, 0.f)),
                                           CGRectGetWidth(visableWaterLabelRect),
                                           CGRectGetHeight(visableWaterLabelRect));
        NSLog(@"visableWaterLabelRect: %@, contentSize: %@", NSStringFromCGRect(visableWaterLabelRect), NSStringFromCGSize(self.contentSize));
        [self scrollRectToVisible:visableWaterLabelRect animated:YES];
    }
}

- (void) hideWatermark {
    self.watermarkLabel.hidden = YES;
}

#pragma mark - save to photo
- (void) saveToPhoto {
    BOOL isVertically = self.tileDirection == TailorTileDirectionVertically;
    NSMutableArray *images = [@[] mutableCopy];
    dispatch_group_t requestGroup = dispatch_group_create();
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
        
        // 绘制所有的原图
        [images enumerateObjectsUsingBlock:^(UIImage *image, NSUInteger idx, BOOL * _Nonnull stop) {
            [image drawInRect:[imageRects[idx] CGRectValue]];
        }];
        
        CGFloat enlargeScale = (isVertically ? maxImageVector : imageVerticalVectorSum) / CGRectGetWidth(self.imageViewsUnionRect);
        
        // 绘制所有的马赛克图片
        [self.pixellateImageViews enumerateObjectsUsingBlock:^(UIImageView *pixellateImageView, NSUInteger idx, BOOL * _Nonnull stop) {
            UIImage *pixellateImage = pixellateImageView.image;
            CGRect frame = pixellateImageView.frame;
            CGRect pixellateRect = CGRectMake(frame.origin.x * enlargeScale,
                                              frame.origin.y * enlargeScale,
                                              frame.size.width * enlargeScale,
                                              frame.size.height * enlargeScale);
            [pixellateImage drawInRect:pixellateRect];
        }];
        
        // 绘制水印
        CGRect watermarkDrawRect = CGRectMake(self.watermarkLabel.left * enlargeScale,
                                              self.watermarkLabel.top * enlargeScale,
                                              self.watermarkLabel.width * enlargeScale,
                                              self.watermarkLabel.height * enlargeScale);
        [self.watermarkLabel drawViewHierarchyInRect:watermarkDrawRect afterScreenUpdates:YES];
        
        UIImage *mergedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [self saveImage:mergedImage];
    });
}

#pragma mark - touches
- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.pixellateType == ScrawlToolBarPixellateTypeNone || touches.count > 1) {
        return ;
    }
    
    self.startTouch = touches.anyObject;
    CGPoint touchPoint = [self.startTouch locationInView:self.imageContainerView];
    self.startTouchPoint = [self transformedTouchPoint:touchPoint];
}

- (void) touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (touches.anyObject != self.startTouch || touches.count > 1) {
        return ;
    }
    CGPoint touchPoint = [touches.anyObject locationInView:self.imageContainerView];
    touchPoint = [self transformedTouchPoint:touchPoint];
    CGRect currentPixellateRect = CGRectMake(MIN(touchPoint.x, self.startTouchPoint.x),
                                             MIN(touchPoint.y, self.startTouchPoint.y),
                                             fabs(touchPoint.x - self.startTouchPoint.x),
                                             fabs(touchPoint.y - self.startTouchPoint.y));
    
    self.pixellateDrawLayer.path = [UIBezierPath bezierPathWithRect:currentPixellateRect].CGPath;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (touches.anyObject != self.startTouch || touches.count > 1) {
        return ;
    }
    
    CGPoint touchPoint = [touches.anyObject locationInView:self.imageContainerView];
    touchPoint = [self transformedTouchPoint:touchPoint];
    CGRect currentPixellateRect = CGRectMake(MIN(touchPoint.x, self.startTouchPoint.x),
                                             MIN(touchPoint.y, self.startTouchPoint.y),
                                             fabs(touchPoint.x - self.startTouchPoint.x),
                                             fabs(touchPoint.y - self.startTouchPoint.y));
    CGFloat width = MIN(CGRectGetWidth(currentPixellateRect), self.imageContainerView.width / self.zoomScale - CGRectGetMinX(currentPixellateRect));
    CGFloat height = MIN(CGRectGetHeight(currentPixellateRect), self.imageContainerView.height / self.zoomScale - CGRectGetMinY(currentPixellateRect));
    currentPixellateRect.size = CGSizeMake(width, height);
    
    NSLog(@"currentPixellateRect: %@", NSStringFromCGRect(currentPixellateRect));
    [self pastePixellateImageViewWithRect:currentPixellateRect];
    self.startTouch = nil;
    self.startTouchPoint = CGPointZero;
    self.pixellateDrawLayer.mask = NULL;
}

- (void) touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}

#pragma mark - private methods

- (CGPoint) transformedTouchPoint:(CGPoint)touchPoint {
    return CGPointMake(MIN(MAX(CGRectGetMinX(self.imageViewsUnionRect), touchPoint.x), CGRectGetMaxX(self.imageViewsUnionRect)),
                       MIN(MAX(CGRectGetMinY(self.imageViewsUnionRect), touchPoint.y), CGRectGetMaxY(self.imageViewsUnionRect)));
}

#pragma mark - others snapshot
- (void) generateSnapshotWithCompletion:(void(^)(UIImage *snapshot))completion {
    if (self.snapshotImage) {
        !completion ?: completion(self.snapshotImage);
    }
    
    BOOL isVertically = self.tileDirection == TailorTileDirectionVertically;
    NSMutableArray *images = [@[] mutableCopy];
    dispatch_group_t requestGroup = dispatch_group_create();
    [self.assetModels enumerateObjectsUsingBlock:^(TailorAssetModel * _Nonnull assetModel, NSUInteger idx, BOOL * _Nonnull stop) {
        dispatch_group_enter(requestGroup);
        [images addObject:@(idx)];
        
        PHImageRequestOptions *options = [PHImageRequestOptions new];
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.resizeMode = PHImageRequestOptionsResizeModeExact;
        options.normalizedCropRect = assetModel.normalizedCropRect;
        
        CGSize size = CGSizeMake([UIScreen mainScreen].bounds.size.width,
                                 [UIScreen mainScreen].bounds.size.width * assetModel.asset.pixelHeight / assetModel.asset.pixelWidth);
        
        [[PHCachingImageManager sharedInstance]
         requestImageForAsset:assetModel.asset
         targetSize:size
         contentMode:PHImageContentModeDefault
         options:options
         resultHandler:^(UIImage *result, NSDictionary *info) {
             images[idx] = result;
             dispatch_group_leave(requestGroup);
         }];
    }];
    dispatch_group_notify(requestGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block CGFloat maxImageVector = 0.f;
        [images enumerateObjectsUsingBlock:^(UIImage *image, NSUInteger idx, BOOL * _Nonnull stop) {
            CGFloat imageVector = (isVertically ? image.size.width : image.size.height) * image.scale;
            maxImageVector = MAX(maxImageVector, imageVector);
        }];
        __block CGFloat imageVerticalVectorSum = 0.f;
        __block CGRect preImageRect = CGRectZero;
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
        [images enumerateObjectsUsingBlock:^(UIImage *image, NSUInteger idx, BOOL * _Nonnull stop) {
            [image drawInRect:[imageRects[idx] CGRectValue]];
        }];
        self.snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        dispatch_sync(dispatch_get_main_queue(), ^{
            !completion ?: completion(self.snapshotImage);
        });
    });
}

#pragma mark - others pixellate
- (UIImage *) generatePixellateImageWithRadius:(CGFloat)radius {
    if (!customKernel) {
        NSBundle *bundle = [NSBundle bundleForClass: [self class]];
        NSURL *kernelURL = [bundle URLForResource:@"Pixellate" withExtension:@"cikernel"];
        
        NSError *error;
        NSString *kernelCode = [NSString stringWithContentsOfURL:kernelURL
                                                        encoding:NSUTF8StringEncoding error:&error];
        if (kernelCode == nil) {
            NSLog(@"Error loading kernel code string in %@\n%@",
                  NSStringFromSelector(_cmd),
                  [error localizedDescription]);
            abort();
        }
        
        NSArray *kernels = [CIWarpKernel kernelsWithString:kernelCode];
        customKernel = [kernels objectAtIndex:0];
    }
    CIImage *inputImage = [[CIImage alloc] initWithImage:self.snapshotImage];
    CGRect dod = inputImage.extent;
    CIImage *outputImage = [customKernel applyWithExtent:dod roiCallback:^CGRect(int index, CGRect destRect) {
        return destRect;
    } inputImage:inputImage arguments:@[@5]];
    CIContext *context = [CIContext contextWithOptions:nil];
    return [UIImage imageWithCGImage:[context createCGImage:outputImage fromRect:outputImage.extent]];
}

- (void) generatePixellateImage {
    self.pixellateDrawLayer.frame = self.imageContainerView.bounds;
    self.pixellateDrawLayer.fillColor = [UIColor lightGrayColor].CGColor;
    
    if (self.pixellateType == ScrawlToolBarPixellateTypeSmall) {
        UIImage *image = [self generatePixellateImageWithRadius:4];
        self.smallRadiusPixellateImageLayer.frame = self.imageContainerView.bounds;
        self.smallRadiusPixellateImageLayer.contents = (id) image.CGImage;
        [self.imageContainerView.layer addSublayer:self.smallRadiusPixellateImageLayer];
        [self.smallRadiusPixellateImageLayer bk_associateValue:image withKey:kPixellateLayerImageKey];
    }
    if (self.pixellateType == ScrawlToolBarPixellateTypeMiddle) {
        UIImage *image = [self generatePixellateImageWithRadius:10];
        self.middleRadiusPixellateImageLayer.frame = self.imageContainerView.bounds;
        self.middleRadiusPixellateImageLayer.contents = (id) image.CGImage;
        [self.middleRadiusPixellateImageLayer bk_associateValue:image withKey:kPixellateLayerImageKey];
    }
    if (self.pixellateType == ScrawlToolBarPixellateTypeLarge) {
        UIImage *image = [self generatePixellateImageWithRadius:18];
        self.largeRadiusPixellateImageLayer.frame = self.imageContainerView.bounds;
        self.largeRadiusPixellateImageLayer.contents = (id) image.CGImage;
        [self.largeRadiusPixellateImageLayer bk_associateValue:image withKey:kPixellateLayerImageKey];
    }
}

- (void) pastePixellateImageViewWithRect:(CGRect)rect {
    UIImage *pixellateImage = nil;
    if (self.pixellateType == ScrawlToolBarPixellateTypeSmall) {
        pixellateImage = [self.smallRadiusPixellateImageLayer bk_associatedValueForKey:kPixellateLayerImageKey];
    } else if (self.pixellateType == ScrawlToolBarPixellateTypeMiddle) {
        pixellateImage = [self.middleRadiusPixellateImageLayer bk_associatedValueForKey:kPixellateLayerImageKey];
    } else {
        pixellateImage = [self.largeRadiusPixellateImageLayer bk_associatedValueForKey:kPixellateLayerImageKey];
    }
    CGFloat enlargeScale = pixellateImage.size.width * pixellateImage.scale / (self.imageContainerView.width / self.zoomScale);
    CGRect pixellateRect = CGRectMake(CGRectGetMinX(rect) * enlargeScale,
                                      CGRectGetMinY(rect) * enlargeScale,
                                      CGRectGetWidth(rect) * enlargeScale,
                                      CGRectGetHeight(rect) * enlargeScale);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(pixellateImage.CGImage, pixellateRect);
    UIImage *pixellateRectImage = [UIImage imageWithCGImage:imageRef scale:pixellateImage.scale orientation:pixellateImage.imageOrientation];
    CGImageRelease(imageRef);
    
    UIImageView *pixellateRectImageView = [[UIImageView alloc] initWithImage:pixellateRectImage];
    pixellateRectImageView.frame = rect;
    [self.pixellateImageViews addObject:pixellateRectImageView];
    [self.imageContainerView addSubview:pixellateRectImageView];
    
    [self setNeedsLayout];
}

#pragma mark - others save image to photo
- (void) saveImage:(UIImage *)image {
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
}

- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSString *message = @"保存图片失败";
    if (!error) {
        message = @"成功保存到相册";
    }
    NSLog(@"saved msg: %@", message);
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageContainerView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self setNeedsLayout];
}

#pragma mark - getters
LazyPropertyWithInit(UIView, imageContainerView, {})
LazyProperty(CALayer, smallRadiusPixellateImageLayer)
LazyProperty(CALayer, middleRadiusPixellateImageLayer)
LazyProperty(CALayer, largeRadiusPixellateImageLayer)
LazyProperty(CAShapeLayer, pixellateDrawLayer)
LazyPropertyWithInit(UILabel, watermarkLabel, {
    _watermarkLabel.font = [UIFont systemFontOfSize:10];
    _watermarkLabel.textColor = [UIColor whiteColor];
    _watermarkLabel.hidden = YES;
})
@end
