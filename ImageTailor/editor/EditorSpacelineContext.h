//
//  EditorSpacelineContext.h
//  ImageTailor
//
//  Created by dl on 2018/5/22.
//  Copyright © 2018年 dl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EditorSpacelineContext : NSObject

@property (nonatomic, weak) UIView *imageContainerView;
@property (nonatomic, assign) NSInteger imagesCnt;
@property (nonatomic, assign) TailorTileDirection tileDirection;

@property (nonatomic, assign, readonly) EditorToolBarSpacelineType spacelineType;
@property (nonatomic, strong, readonly) NSArray<UIView *> *spacelineViews;
@property (nonatomic, strong, readonly) NSArray<UIView *> *boundslineViews;

- (void) setup;
- (void) didChangeAllImageViewsRect:(CGRect)allImageViewsRect
                         imageRects:(NSArray *)imageRects;

- (void) showSpacelineWithType:(EditorToolBarSpacelineType)spacelineType;
- (void) hide;

- (NSArray<UIView *> *) allLineViews;

@end
