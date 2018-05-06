//
//  TailorReserveInsetsClipedImageView.m
//  ImageTailor
//
//  Created by dl on 2018/4/30.
//  Copyright © 2018年 dl. All rights reserved.
//

#import "TailorReserveInsetsClipedImageView.h"

@interface TailorReserveInsetsClipedImageView()
@property (nonatomic, strong) UIImageView *innerImageView;
@property (nonatomic, strong, readwrite) TailorAssetModel *assetModel;
@end

@implementation TailorReserveInsetsClipedImageView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        [self addSubview:self.innerImageView];
    }
    return self;
}

- (void) bindAssetModel:(TailorAssetModel *)assetModel {
    self.assetModel = assetModel;
    
    @weakify(self)
    [assetModel loadScaledImageWithCompletion:^(UIImage *image) {
        @strongify(self)
        self.innerImageView.image = image;
    }];
    
    [self setNeedsLayout];
}

- (UIImage *) clipedImage {
    UIImage *originImage = self.assetModel.image;
    UIEdgeInsets reverseInsets = self.assetModel.reverseInsets;
    CGFloat enlargeScale = originImage.size.width * originImage.scale / (self.width + reverseInsets.left + reverseInsets.right);
    UIEdgeInsets enlargeInsets = UIEdgeInsetsMake(reverseInsets.top * enlargeScale,
                                                  reverseInsets.left * enlargeScale,
                                                  reverseInsets.bottom * enlargeScale,
                                                  reverseInsets.right * enlargeScale);
    CGRect clipedImageRect = CGRectMake(enlargeInsets.left,
                                        enlargeInsets.top,
                                        originImage.size.width * originImage.scale - enlargeInsets.left - enlargeInsets.right,
                                        originImage.size.height * originImage.scale - enlargeInsets.top - enlargeInsets.bottom);
    CGImageRef imageRef = CGImageCreateWithImageInRect(originImage.CGImage, clipedImageRect);
    UIImage *clipedImage = [UIImage imageWithCGImage:imageRef scale:originImage.scale orientation:originImage.imageOrientation];
    CGImageRelease(imageRef);
    return clipedImage;
}

- (BOOL) makeTranslateWithLength:(CGFloat)length
                     editingSide:(TailorCilpedImageViewEditingSide)editingSide{
    UIEdgeInsets insets = [TailorReserveInsetsClipedImageView tryMakeTranslateWithLength:length
                                                                            originInsets:self.assetModel.reverseInsets
                                                                             editingSide:editingSide
                                                                                itemSize:self.size];
    BOOL success = !UIEdgeInsetsEqualToEdgeInsets(insets, self.assetModel.reverseInsets);
    [self.assetModel clipWithReverseInsets:insets];
    return success;
}

- (BOOL) shouldMakeExtraInsets:(UIEdgeInsets)extraInsets {
    return (self.width - extraInsets.left - extraInsets.right) > 40.f
            && (self.height - extraInsets.top - extraInsets.bottom) > 40.f;
}

+ (UIEdgeInsets) tryMakeTranslateWithLength:(CGFloat)length
                               originInsets:(UIEdgeInsets)originInsets
                                editingSide:(TailorCilpedImageViewEditingSide)editingSide
                                   itemSize:(CGSize)size {
    UIEdgeInsets insets = originInsets;
    CGFloat minLengthShouldBeLeft = 40.f;
    switch (editingSide) {
        case TailorCilpedImageViewEditingSideTop:
        {
            if (size.height + length > minLengthShouldBeLeft && insets.top - length > 0) {
                insets.top -= length;
            }
        }
            break;
        case TailorCilpedImageViewEditingSideBottom:
        {
            if (size.height - length > minLengthShouldBeLeft && insets.bottom + length > 0) {
                insets.bottom += length;
            }
        }
            break;
        case TailorCilpedImageViewEditingSideLeft:
        {
            if (size.width + length > minLengthShouldBeLeft && insets.left - length > 0) {
                insets.left -= length;
            }
        }
            break;
        case TailorCilpedImageViewEditingSideRight:
        {
            if (size.width - length > minLengthShouldBeLeft && insets.right + length > 0) {
                insets.right += length;
            }
        }
            break;
        default:
            break;
    }

    return insets;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    UIEdgeInsets insets = self.assetModel.reverseInsets;
    self.innerImageView.frame = CGRectMake(-insets.left,
                                           -insets.top,
                                           self.width + insets.left + insets.right,
                                           self.height + insets.top + insets.bottom);
}

LazyPropertyWithInit(UIImageView, innerImageView, {
    _innerImageView.contentMode = UIViewContentModeScaleAspectFit;
})

@end
