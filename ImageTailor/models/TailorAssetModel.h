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
@property (nonatomic, assign, readonly) CGSize scaledImageSize;

@property (nonatomic, assign, readonly) UIEdgeInsets reverseInsets;
@property (nonatomic, assign, readonly) CGRect normalizedCropRect;

@property (nonatomic, strong) NSMutableArray *testImgs;

- (void) loadImageCompletion:(void(^)(UIImage *image))completion;
- (void) loadImageCliped:(BOOL)cliped completion:(void(^)(UIImage *image))completion;
- (void) loadImageCliped:(BOOL)cliped original:(BOOL)original completion:(void(^)(UIImage *image))completion;

- (void) clipWithReverseInsets:(UIEdgeInsets)reverseInsets;
- (void) clipWithCropRect:(CGRect)normalizedCropRect;

@end
