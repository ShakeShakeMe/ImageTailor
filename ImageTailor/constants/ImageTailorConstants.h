//
//  ImageTailorConstants.h
//  ImageTailor
//
//  Created by dl on 2018/5/5.
//  Copyright © 2018年 dl. All rights reserved.
//

#ifndef ImageTailorConstants_h
#define ImageTailorConstants_h

typedef NS_ENUM(NSInteger, TailorTileDirection){
    TailorTileDirectionVertically = 0,
    TailorTileDirectionHorizontally
};

typedef NS_ENUM(NSInteger, TailorToolActionClipState){
    TailorToolActionClipStateNone = 0,
    TailorToolActionClipStateNormal,
    TailorToolActionClipStateBounds
};

typedef NS_ENUM(NSInteger, TailorCilpedImageViewEditingSide){
    TailorCilpedImageViewEditingSideNone = 0,
    TailorCilpedImageViewEditingSideTop,
    TailorCilpedImageViewEditingSideLeft,
    TailorCilpedImageViewEditingSideBottom,
    TailorCilpedImageViewEditingSideRight
};

typedef NS_ENUM(NSInteger, TailorZommingFloatEditAlignment) {
    TailorZoomingFloatEditAlignVertically       = 0,
    TailorZoomingFloatEditAlignHorizontally     ,
    TailorZoomingFloatEditAlignTop              ,
    TailorZoomingFloatEditAlignLeft             ,
    TailorZoomingFloatEditAlignBottom           ,
    TailorZoomingFloatEditAlignRight
};

typedef NS_ENUM(NSInteger, ScrawlToolBarPixellateType){
    ScrawlToolBarPixellateTypeNone = 0,
    ScrawlToolBarPixellateTypeSmall,
    ScrawlToolBarPixellateTypeMiddle,
    ScrawlToolBarPixellateTypeLarge
};

typedef NS_ENUM(NSInteger, EditorToolBarSpacelineType){
    EditorToolBarSpacelineTypeNone = 0,
    EditorToolBarSpacelineTypeAllBounds,
    EditorToolBarSpacelineTypeSpace
};

typedef NS_ENUM(NSInteger, EditorToolBarWatermarkType){
    EditorToolBarWatermarkTypeNone = 0,
    EditorToolBarWatermarkTypeCenter,
    EditorToolBarWatermarkTypeLeft,
    EditorToolBarWatermarkTypeRight
};

typedef NS_ENUM(NSInteger, EditorWatermarkPrefixType){
    EditorWatermarkPrefixTypeNone = 0,
    EditorWatermarkPrefixTypeNormal,
    EditorWatermarkPrefixTypeOther
};

typedef NS_ENUM(NSInteger, EditorToolBarPhoneBoundsType){
    EditorToolBarPhoneBoundsTypeNone = 0,
    EditorToolBarPhoneBoundsTypeSilvery,
    EditorToolBarPhoneBoundsTypeGold,
    EditorToolBarPhoneBoundsTypeBlack,
    EditorToolBarPhoneBoundsTypeIPhoneX
};

static CGFloat TailorMinZoomingScale = 0.5f;
static CGFloat TailorMaxZoomingScale = 2.f;

static CGFloat TailorDefaultZoomingSacleHorizontally = .5f;
static CGFloat TailorDefaultZoomingSacleVertically = 0.8f;

#endif /* ImageTailorConstants_h */
