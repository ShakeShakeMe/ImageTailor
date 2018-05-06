//
//  TailorAssetModel.h
//  ImageTailor
//
//  Created by dl on 2018/4/30.
//  Copyright © 2018年 dl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TailorAssetModel : NSObject

- (instancetype) initWithAsset:(PHAsset *)asset;

@property (nonatomic, strong, readonly) PHAsset *asset;
// 对原图做压缩，压缩的大小跟屏幕分辨率有关
@property (nonatomic, strong, readonly) UIImage *image;
@property (nonatomic, assign, readonly) CGSize scaledImageSize;

@property (nonatomic, assign, readonly) UIEdgeInsets reverseInsets;

- (void) loadScaledImageWithCompletion:(void(^)(UIImage *image))completion;
- (void) clipWithReverseInsets:(UIEdgeInsets)reverseInsets;

@end
