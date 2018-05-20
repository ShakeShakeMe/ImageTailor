//
//  EditorPixellateContext.m
//  ImageTailor
//
//  Created by dl on 2018/5/19.
//  Copyright © 2018年 dl. All rights reserved.
//

#import "EditorPixellateContext.h"

static void *kPixellateLayerImageKey = &kPixellateLayerImageKey;
static CIWarpKernel *customKernel = nil;

@interface EditorPixellateContext()
@property (nonatomic, assign, readwrite) ScrawlToolBarPixellateType pixellateType;

@property (nonatomic, strong) CALayer *smallRadiusPixellateImageLayer;
@property (nonatomic, strong) CALayer *middleRadiusPixellateImageLayer;
@property (nonatomic, strong) CALayer *largeRadiusPixellateImageLayer;
@property (nonatomic, strong) CAShapeLayer *pixellateDrawLayer;
@property (nonatomic, strong, readwrite) NSMutableArray<UIImageView *> *pixellateImageViews;
@property (nonatomic, strong) UITouch *startTouch;
@property (nonatomic, assign) CGPoint startTouchPoint;
@property (nonatomic, assign) CGRect movingPixellateRect;

@property (nonatomic, assign) CGMutablePathRef path;
@property (nonatomic, assign) CGFloat zoomScale;

@property (nonatomic, strong) UIImage *snapshotImage;
@property (nonatomic, strong) UIImageView *testView;
@end

@implementation EditorPixellateContext

- (instancetype)init {
    self = [super init];
    if (self) {
        self.pixellateImageViews = [@[] mutableCopy];
    }
    return self;
}

- (void) beginDoPixellateWithType:(ScrawlToolBarPixellateType)pixellateType
                      assetModels:(NSArray<TailorAssetModel *> *)assetModels {
    self.pixellateType = pixellateType;
    
    @weakify(self)
    [self generateSnapshotWithAssetModels:assetModels completion:^(UIImage *snapshot) {
        @strongify(self)
        [self generatePixellateImageWithType:pixellateType];
//        self.panGestureRecognizer.minimumNumberOfTouches = 2;
        
        self.pixellateDrawLayer.path = NULL;
        [self.smallRadiusPixellateImageLayer removeFromSuperlayer];
        [self.middleRadiusPixellateImageLayer removeFromSuperlayer];
        [self.largeRadiusPixellateImageLayer removeFromSuperlayer];
        
        UIImage *pixellateImage = nil;
        if (pixellateType == ScrawlToolBarPixellateTypeSmall) {
            [self.imageContainerView.layer addSublayer:self.smallRadiusPixellateImageLayer];
            self.smallRadiusPixellateImageLayer.mask = self.pixellateDrawLayer;
            pixellateImage = [self.smallRadiusPixellateImageLayer bk_associatedValueForKey:kPixellateLayerImageKey];
        } else if (pixellateType == ScrawlToolBarPixellateTypeMiddle) {
            [self.imageContainerView.layer addSublayer:self.middleRadiusPixellateImageLayer];
            self.middleRadiusPixellateImageLayer.mask = self.pixellateDrawLayer;
            pixellateImage = [self.middleRadiusPixellateImageLayer bk_associatedValueForKey:kPixellateLayerImageKey];
        } else {
            [self.imageContainerView.layer addSublayer:self.largeRadiusPixellateImageLayer];
            self.largeRadiusPixellateImageLayer.mask = self.pixellateDrawLayer;
            pixellateImage = [self.largeRadiusPixellateImageLayer bk_associatedValueForKey:kPixellateLayerImageKey];
        }
        
//        self.testView.image = pixellateImage;
//        self.testView.frame = self.imageViewsUnionRect;
//        [self.imageContainerView addSubview:self.testView];
    }];
}

- (void) endDoPixellate {
    self.pixellateType = ScrawlToolBarPixellateTypeNone;
}

- (void) pixellateWithdraw {
    UIImageView *lastPixellateImageView = self.pixellateImageViews.lastObject;
    [lastPixellateImageView removeFromSuperview];
    [self.pixellateImageViews removeObject:lastPixellateImageView];
}

- (void) clearCache {
    self.snapshotImage = nil;
}

- (void) clear {
    [self endDoPixellate];
    [self clearCache];
    [self.pixellateImageViews bk_each:^(UIView *v) {
        [v removeFromSuperview];
    }];
    [self.pixellateImageViews removeAllObjects];
}

#pragma mark - touch event
- (void) touchBeginWithTouch:(UITouch *)touch zoomScale:(CGFloat)zoomScale {
    self.startTouch = touch;
    self.zoomScale = zoomScale;
    CGPoint touchPoint = [self.startTouch locationInView:self.imageContainerView];
    self.startTouchPoint = [self transformedTouchPoint:touchPoint];
}

- (void) touchMovedWithTouch:(UITouch *)touch {
    CGPoint touchPoint = [touch locationInView:self.imageContainerView];
    touchPoint = [self transformedTouchPoint:touchPoint];
    CGRect currentPixellateRect = CGRectMake(MIN(touchPoint.x, self.startTouchPoint.x) - CGRectGetMinX(self.imageViewsUnionRect),
                                             MIN(touchPoint.y, self.startTouchPoint.y) - CGRectGetMinY(self.imageViewsUnionRect),
                                             fabs(touchPoint.x - self.startTouchPoint.x),
                                             fabs(touchPoint.y - self.startTouchPoint.y));
    NSLog(@"moved rect: %@", NSStringFromCGRect(currentPixellateRect));
    
    self.movingPixellateRect = currentPixellateRect;
    self.pixellateDrawLayer.path = [UIBezierPath bezierPathWithRect:currentPixellateRect].CGPath;
}

- (void) touchEndedWithTouch:(UITouch *)touch {
//    CGPoint touchPoint = self.movingTouchPoint;
//    CGRect currentPixellateRect = CGRectMake(MIN(touchPoint.x, self.startTouchPoint.x),
//                                             MIN(touchPoint.y, self.startTouchPoint.y),
//                                             fabs(touchPoint.x - self.startTouchPoint.x),
//                                             fabs(touchPoint.y - self.startTouchPoint.y));
//    CGFloat width = MIN(CGRectGetWidth(currentPixellateRect), self.imageContainerView.width / self.zoomScale - CGRectGetMinX(currentPixellateRect));
//    CGFloat height = MIN(CGRectGetHeight(currentPixellateRect), self.imageContainerView.height / self.zoomScale - CGRectGetMinY(currentPixellateRect));
//    currentPixellateRect.size = CGSizeMake(width, height);
    
    NSLog(@"currentPixellateRect: %@, unionRect: %@",
          NSStringFromCGRect(self.movingPixellateRect),
          NSStringFromCGRect(self.imageViewsUnionRect));
    [self pastePixellateImageViewWithRect:self.movingPixellateRect];
    self.startTouch = nil;
    self.startTouchPoint = CGPointZero;
    self.movingPixellateRect = CGRectZero;
    self.pixellateDrawLayer.path = NULL;
}

#pragma mark - private methods
- (void) generateSnapshotWithAssetModels:(NSArray<TailorAssetModel *> *)assetModels completion:(void(^)(UIImage *snapshot))completion {
    if (self.snapshotImage) {
        !completion ?: completion(self.snapshotImage);
    }
    
    BOOL isVertically = self.tileDirection == TailorTileDirectionVertically;
    NSMutableArray *images = [@[] mutableCopy];
    dispatch_group_t requestGroup = dispatch_group_create();
    [assetModels enumerateObjectsUsingBlock:^(TailorAssetModel * _Nonnull assetModel, NSUInteger idx, BOOL * _Nonnull stop) {
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
    } inputImage:inputImage arguments:@[@(radius)]];
    CIContext *context = [CIContext contextWithOptions:nil];
    return [UIImage imageWithCGImage:[context createCGImage:outputImage fromRect:outputImage.extent]];
}

- (void) generatePixellateImageWithType:(ScrawlToolBarPixellateType)pixellateType {
    self.pixellateDrawLayer.frame = self.imageContainerView.bounds;
    self.pixellateDrawLayer.fillColor = [UIColor whiteColor].CGColor;
    self.pixellateDrawLayer.path = NULL;
    
    if (pixellateType == ScrawlToolBarPixellateTypeSmall) {
        UIImage *image = [self generatePixellateImageWithRadius:2];
        self.smallRadiusPixellateImageLayer.frame = self.imageViewsUnionRect;
        self.smallRadiusPixellateImageLayer.contents = (id) image.CGImage;
        [self.smallRadiusPixellateImageLayer bk_associateValue:image withKey:kPixellateLayerImageKey];
    }
    if (pixellateType == ScrawlToolBarPixellateTypeMiddle) {
        UIImage *image = [self generatePixellateImageWithRadius:4];
        self.middleRadiusPixellateImageLayer.frame = self.imageViewsUnionRect;
        self.middleRadiusPixellateImageLayer.contents = (id) image.CGImage;
        [self.middleRadiusPixellateImageLayer bk_associateValue:image withKey:kPixellateLayerImageKey];
    }
    if (pixellateType == ScrawlToolBarPixellateTypeLarge) {
        UIImage *image = [self generatePixellateImageWithRadius:6];
        self.largeRadiusPixellateImageLayer.frame = self.imageViewsUnionRect;
        self.largeRadiusPixellateImageLayer.contents = (id) image.CGImage;
        [self.largeRadiusPixellateImageLayer bk_associateValue:image withKey:kPixellateLayerImageKey];
    }
}

- (CGPoint) transformedTouchPoint:(CGPoint)touchPoint {
    return CGPointMake(MIN(MAX(CGRectGetMinX(self.imageViewsUnionRect), touchPoint.x), CGRectGetMaxX(self.imageViewsUnionRect)),
                       MIN(MAX(CGRectGetMinY(self.imageViewsUnionRect), touchPoint.y), CGRectGetMaxY(self.imageViewsUnionRect)));
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
    CGFloat enlargeScale = pixellateImage.size.width * pixellateImage.scale / CGRectGetWidth(self.imageViewsUnionRect);
    CGRect pixellateRect = CGRectMake(CGRectGetMinX(rect) * enlargeScale,
                                      CGRectGetMinY(rect) * enlargeScale,
                                      CGRectGetWidth(rect) * enlargeScale,
                                      CGRectGetHeight(rect) * enlargeScale);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(pixellateImage.CGImage, pixellateRect);
    UIImage *pixellateRectImage = [UIImage imageWithCGImage:imageRef scale:pixellateImage.scale orientation:pixellateImage.imageOrientation];
    CGImageRelease(imageRef);
    
    UIImageView *pixellateRectImageView = [[UIImageView alloc] initWithImage:pixellateRectImage];
    pixellateRectImageView.frame = CGRectMake(CGRectGetMinX(rect) + CGRectGetMinX(self.imageViewsUnionRect),
                                              CGRectGetMinY(rect) + CGRectGetMinY(self.imageViewsUnionRect),
                                              CGRectGetWidth(rect),
                                              CGRectGetHeight(rect));
    [self.pixellateImageViews addObject:pixellateRectImageView];
    [self.imageContainerView addSubview:pixellateRectImageView];
}

#pragma mark - getters
LazyProperty(CALayer, smallRadiusPixellateImageLayer)
LazyProperty(CALayer, middleRadiusPixellateImageLayer)
LazyProperty(CALayer, largeRadiusPixellateImageLayer)
LazyProperty(CAShapeLayer, pixellateDrawLayer)
LazyProperty(UIImageView, testView)
@end
