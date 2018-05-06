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

static CGFloat TailorMinZoomingScale = 0.5f;
static CGFloat TailorMaxZoomingScale = 2.f;

static CGFloat TailorDefaultZoomingSacleHorizontally = .5f;
static CGFloat TailorDefaultZoomingSacleVertically = 1.f;

#endif /* ImageTailorConstants_h */
