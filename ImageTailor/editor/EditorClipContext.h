//
//  EditorClipContext.h
//  ImageTailor
//
//  Created by dl on 2018/5/19.
//  Copyright © 2018年 dl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TailorZoomingFloatEditBtnView.h"
#import "TailorReserveInsetsClipedImageView.h"

@interface EditorClipContext : NSObject

@property (nonatomic, weak) id<TailorZoomingFloatEditBtnViewDelegate> floatEditBtnViewDelegate;
@property (nonatomic, weak) UIView *imageContainerView;
@property (nonatomic, assign) NSInteger imagesCnt;
@property (nonatomic, assign) TailorTileDirection tileDirection;

@property (nonatomic, assign, getter=isEditing, readonly) BOOL editing;
@property (nonatomic, assign, readonly) TailorToolActionClipState clipState;
@property (nonatomic, strong, readonly) NSArray<TailorZoomingFloatEditBtnView *> *normalEditBtnViews;
@property (nonatomic, strong, readonly) NSArray<TailorZoomingFloatEditBtnView *> *boundsEditBtnViews;

@property (nonatomic, weak) TailorZoomingFloatEditBtnView *currentEditingBtnView;
@property (nonatomic, assign) CGPoint preMovedTouchPoint;
@property (nonatomic, weak) TailorReserveInsetsClipedImageView *currentEditingImageview;
@property (nonatomic, assign) TailorCilpedImageViewEditingSide editingSide;
@property (nonatomic, strong) UITouch *currentEditingTouch;

// 仅仅是为了防止剪切滑动时有错觉
@property (nonatomic, assign) CGFloat extraTopOrLeftDistance;
@property (nonatomic, assign) UIEdgeInsets preBoundsLinkageClipInsets;

- (void) setup;
- (void) didChangeVisableRect:(CGRect)visableRect
                   imageRects:(NSArray *)imageRects
          scaledBtnSizeVector:(CGFloat)scaledBtnSizeVector;

- (void) beginClipNormal;
- (void) beginClipBounds;
- (void) endClip;

- (void) beginEditingWithSide:(TailorCilpedImageViewEditingSide)editingSide;
- (void) endEditing;
- (BOOL) isEditingLinkageBounds;

@end
