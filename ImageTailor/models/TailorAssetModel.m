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
        
        self.testImgs = [@[] mutableCopy];
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
    
//    CGSize originSize = CGSizeMake(self.asset.pixelWidth, self.asset.pixelHeight);
//    for (int i=0; i<20; i++) {
//        [self testWithPosition:(i / 20.f) size:CGSizeMake(originSize.width, originSize.height / 20.f)];
//    }
}

//- (void) testWithPosition:(CGFloat)position size:(CGSize)size {
//    PHImageRequestOptions *options = [PHImageRequestOptions new];
//    options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
//    options.resizeMode = PHImageRequestOptionsResizeModeExact;
//    options.normalizedCropRect = CGRectMake(0, position, 1, 1.f / 20.f);
//
//    [[PHCachingImageManager sharedInstance]
//     requestImageForAsset:self.asset
//     targetSize:size
//     contentMode:PHImageContentModeDefault
//     options:options
//     resultHandler:^(UIImage *result, NSDictionary *info) {
//         [self.testImgs addObject:result];
//         NSLog(@"position: %@, image.size: %@", @(position), NSStringFromCGSize(result.size));
//     }];
//}

- (void) clipWithReverseInsets:(UIEdgeInsets)reverseInsets {
    self.reverseInsets = reverseInsets;
}

- (void) clipWithCropRect:(CGRect)normalizedCropRect {
    self.normalizedCropRect = normalizedCropRect;
}

@end
