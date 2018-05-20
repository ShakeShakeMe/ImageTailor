//
//  EditorViewController.h
//  ImageTailor
//
//  Created by dl on 2018/5/19.
//  Copyright © 2018年 dl. All rights reserved.
//

#import "ViewController.h"
#import "BaseViewController.h"
#import "TailorAssetModel.h"

@interface EditorViewController : BaseViewController

@property (nonatomic, strong) NSArray<TailorAssetModel *> *assetModels;
@property (nonatomic, assign) TailorTileDirection tileDirection;

@end
