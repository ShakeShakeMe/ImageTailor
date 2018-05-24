//
//  SaveToPhotoViewController.h
//  ImageTailor
//
//  Created by dl on 2018/5/20.
//  Copyright © 2018年 dl. All rights reserved.
//

#import "BaseViewController.h"
#import "TailorAssetModel.h"

@protocol SaveToPhotoViewControllerDelegate<NSObject>
- (void) saveToPhoto:(BOOL)success asset:(PHAsset *)asset;
@end

@interface SaveToPhotoViewController : BaseViewController

@property (nonatomic, weak) id<SaveToPhotoViewControllerDelegate> delegate;

@property (nonatomic, assign) TailorTileDirection tileDirection;
@property (nonatomic, strong) NSArray<TailorAssetModel *> *assetModels;
@property (nonatomic, strong) NSArray<UIImageView *> *pixellateImageViews;
@property (nonatomic, strong) UILabel *watermarkLabel;
@property (nonatomic, strong) NSArray<UIView *> *lineViews;
@property (nonatomic, strong) UIImageView *phoneBoundsImageView;
@property (nonatomic, assign) CGRect imageViewsUnionRect;

@end
