//
//  SaveToPhotoViewController.h
//  ImageTailor
//
//  Created by dl on 2018/5/20.
//  Copyright © 2018年 dl. All rights reserved.
//

#import "BaseViewController.h"
#import "TailorAssetModel.h"

@interface SaveToPhotoViewController : BaseViewController

@property (nonatomic, assign) TailorTileDirection tileDirection;
@property (nonatomic, strong) NSArray<TailorAssetModel *> *assetModels;
@property (nonatomic, strong) NSArray<UIImageView *> *pixellateImageViews;
@property (nonatomic, strong) UILabel *watermarkLabel;
@property (nonatomic, assign) CGRect imageViewsUnionRect;

@end
