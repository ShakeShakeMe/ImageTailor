//
//  TailorZoomingScrollView.h
//  ImageTailor
//
//  Created by dl on 2018/4/30.
//  Copyright © 2018年 dl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TailorAssetModel.h"
#import "TailorReserveInsetsClipedImageView.h"
#import "TailorBottomToolBarControl.h"

@interface TailorZoomingScrollView : UIScrollView <TailorBottomToolBarControlDelegate>

@property (nonatomic, assign, readonly) TailorTileDirection tileDirection;
@property (nonatomic, strong, readonly) NSArray<TailorReserveInsetsClipedImageView *> *imageViews;
@property (nonatomic, strong, readonly) NSArray<TailorAssetModel *> *assetModels;

// edit
@property (nonatomic, assign, readonly) TailorToolActionClipState clipState;

- (void) refreshWithAssetModels:(NSArray<TailorAssetModel *> *)assetModels
                  tileDirection:(TailorTileDirection)tileDirection;
- (void)zoomToReset;

- (NSArray<UIImage *> *) allClipedImages;

- (UIImage *) tailoredImagesSnapshot;

@property (nonatomic, strong, readonly) NSArray<NSValue *> *imageRectsOnSnapshot;

@end
