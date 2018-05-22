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
#import "EditorClipContext.h"
#import "EditorPixellateContext.h"
#import "EditorWatermarkContext.h"
#import "PhoneBoundsContext.h"
#import "EditorSpacelineContext.h"

@interface EditorZoomingScrollView : UIScrollView

@property (nonatomic, assign, readonly) TailorTileDirection tileDirection;
@property (nonatomic, strong, readonly) NSArray<TailorReserveInsetsClipedImageView *> *imageViews;
@property (nonatomic, strong, readonly) NSArray<TailorAssetModel *> *assetModels;

@property (nonatomic, strong, readonly) EditorClipContext *clipContext;
@property (nonatomic, strong, readonly) EditorPixellateContext *pixellateContext;
@property (nonatomic, strong, readonly) EditorWatermarkContext *watermarkContext;
@property (nonatomic, strong, readonly) EditorSpacelineContext *spacelineContext;
@property (nonatomic, strong, readonly) PhoneBoundsContext *phoneBoundsContext;
@property (nonatomic, assign, readonly) CGRect imageViewsUnionRect;

- (void) refreshWithAssetModels:(NSArray<TailorAssetModel *> *)assetModels
                  tileDirection:(TailorTileDirection)tileDirection;

- (void) clipWithState:(TailorToolActionClipState)clipState;

- (void) pixellateWithType:(ScrawlToolBarPixellateType)pixellateType;
- (void) pixellateWithdraw;
- (void) pixellateEnd;
- (void) pixellateClear;

// 水印
- (void) showWatermarkWithType:(EditorToolBarWatermarkType)watermarkType text:(NSString *)text;
- (void) hideWatermark;

// 辅助线
- (void) showSpacelineWithType:(EditorToolBarSpacelineType)spacelineType;
- (void) hideSpaceline;

// 边框
- (void) showPhoneBoundsWithType:(EditorToolBarPhoneBoundsType)phoneBoundsType;
- (void) hidePhoneBounds;

- (BOOL) hasChanged;
- (void) abandonAllTailorChanges;

@end
