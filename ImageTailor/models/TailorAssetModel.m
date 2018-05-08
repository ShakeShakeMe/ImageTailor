//
//  TailorAssetModel.m
//  ImageTailor
//
//  Created by dl on 2018/4/30.
//  Copyright © 2018年 dl. All rights reserved.
//

#import "TailorAssetModel.h"

@interface TailorAssetModel()
@property (nonatomic, strong, readwrite) PHAsset *asset;
@property (nonatomic, assign, readwrite) CGSize scaledImageSize;

@property (nonatomic, assign, readwrite) UIEdgeInsets reverseInsets;
@property (nonatomic, assign, readwrite) CGRect normalizedCropRect;
@end

@implementation TailorAssetModel

- (instancetype) initWithAsset:(PHAsset *)asset {
    self = [super init];
    if (self) {
        self.asset = asset;
        CGFloat zoomScale = [UIScreen mainScreen].bounds.size.width * [UIScreen mainScreen].scale / asset.pixelWidth;
        CGSize targetSize = CGSizeMake(asset.pixelWidth * zoomScale, asset.pixelHeight * zoomScale);
        self.scaledImageSize = targetSize;
        self.normalizedCropRect = CGRectMake(0.f, 0.f, 1.f, 1.f);
    }
    return self;
}

- (void) loadImageCompletion:(void(^)(UIImage *image))completion {
    [self loadImageCliped:NO completion:completion];
}

- (void) loadImageCliped:(BOOL)cliped completion:(void(^)(UIImage *image))completion {
    [self loadImageCliped:cliped original:NO completion:completion];
}

- (void) loadImageCliped:(BOOL)cliped original:(BOOL)original completion:(void(^)(UIImage *image))completion {
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    if (!original && cliped) {
//        options.normalizedCropRect = CGRectMake(0.2, 0.2, 0.6, 0.6);
        options.normalizedCropRect = self.normalizedCropRect;
    }
    
    [[PHCachingImageManager sharedInstance]
     requestImageForAsset:self.asset
     targetSize:(original ? PHImageManagerMaximumSize : self.scaledImageSize)
     contentMode:PHImageContentModeDefault
     options:options
     resultHandler:^(UIImage *result, NSDictionary *info) {
         !completion ?: completion(result);
     }];
}

- (void) clipWithReverseInsets:(UIEdgeInsets)reverseInsets {
    self.reverseInsets = reverseInsets;
}

- (void) clipWithCropRect:(CGRect)normalizedCropRect {
    self.normalizedCropRect = normalizedCropRect;
}

@end
