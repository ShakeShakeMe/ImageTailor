//
//  EditorZoomingScrollView.h
//  ImageTailor
//
//  Created by dl on 2018/5/19.
//  Copyright © 2018年 dl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TailorAssetModel.h"
#import "TailorReserveInsetsClipedImageView.h"

@interface EditorZoomingScrollView : UIScrollView

@property (nonatomic, assign, readonly) TailorTileDirection tileDirection;
@property (nonatomic, strong, readonly) NSArray<TailorReserveInsetsClipedImageView *> *imageViews;
@property (nonatomic, strong, readonly) NSArray<TailorAssetModel *> *assetModels;

- (void) refreshWithAssetModels:(NSArray<TailorAssetModel *> *)assetModels
                  tileDirection:(TailorTileDirection)tileDirection;

- (void) clipWithState:(TailorToolActionClipState)clipState;

- (void) pixellateWithType:(ScrawlToolBarPixellateType)pixellateType;
- (void) pixellateWithdraw;

// 水印
- (void) showWatermarkWithType:(EditorToolBarWatermarkType)watermarkType text:(NSString *)text;
- (void) hideWatermark;

@end
