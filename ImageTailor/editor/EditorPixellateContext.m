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
@property (nonatomic, strong, readwrite) NSArray<TailorAssetModel *> *assetModels;
@property (nonatomic, assign, readwrite) ScrawlToolBarPixellateType pixellateType;

@property (nonatomic, strong) CALayer *smallRadiusPixellateImageLayer;
@property (nonatomic, strong) CALayer *middleRadiusPixellateImageLayer;
@property (nonatomic, strong) CALayer *largeRadiusPixellateImageLayer;
@property (nonatomic, strong) CAShapeLayer *pixellateDrawLayer;
@property (nonatomic, strong) NSMutableArray<UIImageView *> *pixellateImageViews;
@property (nonatomic, strong) UITouch *startTouch;
@property (nonatomic, assign) CGPoint startTouchPoint;

@property (nonatomic, assign) CGMutablePathRef path;
@property (nonatomic, assign) CGRect imageViewsUnionRect;

@property (nonatomic, strong) UIImage *snapshotImage;
@end

@implementation EditorPixellateContext

- (void) beginDoPixellateWithType:(ScrawlToolBarPixellateType)pixellateType
                      assetModels:(NSArray<TailorAssetModel *> *)assetModels {
    @weakify(self)
    [self generateSnapshotWithCompletion:^(UIImage *snapshot) {
        @strongify(self)
        self.pixellateType = pixellateType;
        [self generatePixellateImage];
//        self.panGestureRecognizer.minimumNumberOfTouches = 2;
        
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

- (void) endDoPixellate {
    
}

- (void) pixellateWithdraw {
    
}

- (void) clearCache {
    self.snapshotImage = nil;
}

#pragma mark - touch event
- (void) touchBeginAtPoint:(CGPoint)touchPoint {
    
}

- (void) touchMoveToPoint:(CGPoint)touchPoint {
    
}

- (void) touchEndAtPoint:(CGPoint)touchPoint {
    
}

#pragma mark - private methods
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

#pragma mark - getters
LazyProperty(CALayer, smallRadiusPixellateImageLayer)
LazyProperty(CALayer, middleRadiusPixellateImageLayer)
LazyProperty(CALayer, largeRadiusPixellateImageLayer)
LazyProperty(CAShapeLayer, pixellateDrawLayer)
@end
