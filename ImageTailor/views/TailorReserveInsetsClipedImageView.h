//
//  TailorReserveInsetsClipedImageView.h
//  ImageTailor
//
//  Created by dl on 2018/4/30.
//  Copyright © 2018年 dl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TailorAssetModel.h"

@interface TailorReserveInsetsClipedImageView : UIView

@property (nonatomic, strong, readonly) TailorAssetModel *assetModel;

- (void) bindAssetModel:(TailorAssetModel *)assetModel;

- (BOOL) makeTranslateWithLength:(CGFloat)length
                     editingSide:(TailorCilpedImageViewEditingSide)editingSide;

+ (UIEdgeInsets) tryMakeTranslateWithLength:(CGFloat)length
                               originInsets:(UIEdgeInsets)originInsets
                                editingSide:(TailorCilpedImageViewEditingSide)editingSide
                                   itemSize:(CGSize)size;

- (UIImage *) clipedImage;

@end
