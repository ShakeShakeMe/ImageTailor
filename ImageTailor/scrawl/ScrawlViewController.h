//
//  ScrawlViewController.h
//  ImageTailor
//
//  Created by dl on 2018/5/5.
//  Copyright © 2018年 dl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "TailorAssetModel.h"

@interface ScrawlViewController : BaseViewController

//@property (nonatomic, strong) UIImage *snapshot;
//@property (nonatomic, strong) NSArray<NSValue *> *rects;
//@property (nonatomic, strong) NSArray<UIImage *> *images;

@property (nonatomic, strong) NSArray<TailorAssetModel *> *assetModels;

@property (nonatomic, assign) TailorTileDirection tileDirection;
@property (nonatomic, assign) CGFloat zoomScale;
@property (nonatomic, assign) CGPoint conentOffset;

@end
