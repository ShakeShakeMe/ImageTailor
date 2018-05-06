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
@property (nonatomic, strong, readwrite) UIImage *image;
@property (nonatomic, assign, readwrite) CGSize scaledImageSize;

@property (nonatomic, assign, readwrite) UIEdgeInsets reverseInsets;
@end

@implementation TailorAssetModel

- (instancetype) initWithAsset:(PHAsset *)asset {
    self = [super init];
    if (self) {
        self.asset = asset;
        CGFloat zoomScale = [UIScreen mainScreen].bounds.size.width * [UIScreen mainScreen].scale / asset.pixelWidth;
        CGSize targetSize = CGSizeMake(asset.pixelWidth * zoomScale, asset.pixelHeight * zoomScale);
        self.scaledImageSize = targetSize;
    }
    return self;
}

- (void) loadScaledImageWithCompletion:(void(^)(UIImage *image))completion {
    if (self.image) {
        !completion ?: completion(self.image);
        return ;
    }
    @weakify(self)
    [[PHCachingImageManager sharedInstance]
     requestImageForAsset:self.asset
     targetSize:self.scaledImageSize
     contentMode:PHImageContentModeAspectFit
     options:nil
     resultHandler:^(UIImage *result, NSDictionary *info) {
         @strongify(self)
         self.image = result;
         !completion ?: completion(result);
     }];
}

- (void) clipWithReverseInsets:(UIEdgeInsets)reverseInsets {
    self.reverseInsets = reverseInsets;
}

@end
