//
//  TailorViewController.h
//  ImageTailor
//
//  Created by dl on 2018/4/30.
//  Copyright © 2018年 dl. All rights reserved.
//

#import "BaseViewController.h"
#import "TailorAssetModel.h"
#import "TailorZoomingScrollView.h"
//#import "TailorImageCanvasZoomingView.h"

@interface TailorViewController : BaseViewController

@property (nonatomic, strong) NSArray<TailorAssetModel *> *assetModels;
@property (nonatomic, assign) TailorTileDirection tileDirection;

@end
