//
//  ScrawlBottomToolBarControl.h
//  ImageTailor
//
//  Created by dl on 2018/5/6.
//  Copyright © 2018年 dl. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ScrawlToolBarItemType){
    ScrawlToolBarItemTypeUnknown = 0,
    ScrawlToolBarItemTypePixellate,
    ScrawlToolBarItemTypeWatermark,
    ScrawlToolBarItemTypeGuideLine,
    ScrawlToolBarItemTypePhoneBounds
};

typedef NS_ENUM(NSInteger, ScrawlToolBarPixellateType){
    ScrawlToolBarPixellateTypeNone = 0,
    ScrawlToolBarPixellateTypeSmall,
    ScrawlToolBarPixellateTypeMiddle,
    ScrawlToolBarPixellateTypeLarge
};

@class ScrawlBottomToolBarControl;
@class ScrawlBottomToolBarFLoatView;

@protocol ScrawlBottomToolBarControlDelegate<NSObject>

- (void) toolBarControl:(ScrawlBottomToolBarControl *)toolBarControl
            didSelected:(BOOL)selected
            toolBarItem:(ScrawlToolBarItemType)itemType;
@end

@protocol ScrawlBottomToolBarFLoatViewDelegate<NSObject>
- (void) floatView:(ScrawlBottomToolBarFLoatView *)floatView
       toolBarItem:(ScrawlToolBarItemType)itemType
       didSelected:(BOOL)selected
           atIndex:(NSInteger)index;
@end

@interface ScrawlBottomToolBarFLoatView : UIView

@property (nonatomic, assign) BOOL showVerticalLine;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, weak) id<ScrawlBottomToolBarFLoatViewDelegate> delegate;
@property (nonatomic, assign, readonly) ScrawlToolBarItemType itemType;

- (void) refreshWithSelectedImages:(NSArray *)selectedImages
                  unselectedImages:(NSArray *)unselectedImages
                            titles:(NSArray *)titles
                          itemType:(ScrawlToolBarItemType)itemType;
@end

@interface ScrawlBottomToolBarControl : UIControl

@property (nonatomic, weak) id<ScrawlBottomToolBarControlDelegate> delegate;

@end
