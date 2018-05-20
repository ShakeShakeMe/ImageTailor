//
//  EditorClipContext.m
//  ImageTailor
//
//  Created by dl on 2018/5/19.
//  Copyright © 2018年 dl. All rights reserved.
//

#import "EditorClipContext.h"

@interface EditorClipContext()
@property (nonatomic, strong, readwrite) NSArray<TailorZoomingFloatEditBtnView *> *normalEditBtnViews;
@property (nonatomic, strong, readwrite) NSArray<TailorZoomingFloatEditBtnView *> *boundsEditBtnViews;

@property (nonatomic, assign, readwrite) TailorToolActionClipState clipState;
@end

@implementation EditorClipContext

- (void) setup {
    // 上下左右
    // bounds btn views
    NSMutableArray *boundsEditBtnViews = [@[] mutableCopy];
    [@[@(TailorZoomingFloatEditAlignTop),
       @(TailorZoomingFloatEditAlignLeft),
       @(TailorZoomingFloatEditAlignBottom),
       @(TailorZoomingFloatEditAlignRight)] bk_each:^(NSNumber *alignment) {
           [boundsEditBtnViews addObject:[[TailorZoomingFloatEditBtnView alloc] initWithAlignment:alignment.integerValue]];
       }];
    self.boundsEditBtnViews = [boundsEditBtnViews copy];
    [self.boundsEditBtnViews bk_each:^(TailorZoomingFloatEditBtnView * btnView) {
        btnView.delegate = self.floatEditBtnViewDelegate;
        [self.imageContainerView addSubview:btnView];
    }];
    
    // normal btn views
    NSMutableArray *normalEditBtnViews = [@[] mutableCopy];
    for (int i=0; i<self.imagesCnt-1; i++) {
        TailorZommingFloatEditAlignment alignment = self.tileDirection == TailorTileDirectionVertically ? TailorZoomingFloatEditAlignHorizontally : TailorZoomingFloatEditAlignVertically;
        [normalEditBtnViews addObject:[[TailorZoomingFloatEditBtnView alloc] initWithAlignment:alignment]];
    }
    
    self.normalEditBtnViews = [normalEditBtnViews copy];
    [self.normalEditBtnViews bk_each:^(TailorZoomingFloatEditBtnView * btnView) {
        btnView.delegate = self.floatEditBtnViewDelegate;
        [self.imageContainerView addSubview:btnView];
    }];
}

- (void) didChangeVisableRect:(CGRect)visableRect
                   imageRects:(NSArray *)imageRects
          scaledBtnSizeVector:(CGFloat)scaledBtnSizeVector {
    __block CGRect allImagesUnionRect = CGRectZero;
    [imageRects enumerateObjectsUsingBlock:^(NSValue *rectValue, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == 0) {
            allImagesUnionRect = [rectValue CGRectValue];
        } else {
            allImagesUnionRect = CGRectUnion([rectValue CGRectValue], allImagesUnionRect);
        }
    }];
    CGRect visableLayoutRect = CGRectIntersection(allImagesUnionRect, visableRect);
    
    // bounds btn views frame
    BOOL isVertically = self.tileDirection == TailorTileDirectionVertically;
    [self.boundsEditBtnViews enumerateObjectsUsingBlock:^(TailorZoomingFloatEditBtnView * btnView, NSUInteger idx, BOOL * _Nonnull stop) {
        CGRect btnFrame = CGRectZero;
        BOOL isClipStateNormal = self.clipState == TailorToolActionClipStateNormal;
        BOOL btnViewHidden = NO;
        CGRect firstRect = [imageRects.firstObject CGRectValue];
        CGRect lastRect = [imageRects.lastObject CGRectValue];
        
        if (btnView.alignment == TailorZoomingFloatEditAlignTop) {
            btnFrame = CGRectMake(CGRectGetMinX(visableLayoutRect),
                                  CGRectGetMinY(firstRect),
                                  CGRectGetWidth(visableLayoutRect),
                                  scaledBtnSizeVector);
            btnViewHidden = isClipStateNormal && !isVertically;
        } else if (btnView.alignment == TailorZoomingFloatEditAlignLeft) {
            btnFrame = CGRectMake(CGRectGetMinX(firstRect),
                                  CGRectGetMinY(visableLayoutRect),
                                  scaledBtnSizeVector,
                                  CGRectGetHeight(visableLayoutRect));
            btnViewHidden = isClipStateNormal && isVertically;
        } else if (btnView.alignment == TailorZoomingFloatEditAlignBottom) {
            btnFrame = CGRectMake(CGRectGetMinX(visableLayoutRect),
                                  CGRectGetMaxY(lastRect) - scaledBtnSizeVector,
                                  CGRectGetWidth(visableLayoutRect),
                                  scaledBtnSizeVector);
            btnViewHidden = isClipStateNormal && !isVertically;
        } else {
            btnFrame = CGRectMake(CGRectGetMaxX(lastRect) - scaledBtnSizeVector,
                                  CGRectGetMinY(visableLayoutRect),
                                  scaledBtnSizeVector,
                                  CGRectGetHeight(visableLayoutRect));
            btnViewHidden = isClipStateNormal && isVertically;
        }
        btnView.frame = btnFrame;
        if (self.clipState == TailorToolActionClipStateNone) {
            btnViewHidden = YES;
        }
        btnView.hidden = btnViewHidden;
    }];
    
    // normal btn views frame
    [self.normalEditBtnViews enumerateObjectsUsingBlock:^(TailorZoomingFloatEditBtnView * btnView, NSUInteger idx, BOOL * _Nonnull stop) {
        CGRect imgViewFrame = [imageRects[idx] CGRectValue];
        CGRect btnFrame = CGRectZero;
        if (btnView.alignment == TailorZoomingFloatEditAlignVertically) {
            btnFrame = CGRectMake(CGRectGetMaxX(imgViewFrame) - scaledBtnSizeVector / 2.f,
                                  CGRectGetMinY(visableLayoutRect),
                                  scaledBtnSizeVector,
                                  CGRectGetHeight(visableLayoutRect));
        } else {
            btnFrame = CGRectMake(CGRectGetMinX(visableLayoutRect),
                                  CGRectGetMaxY(imgViewFrame) - scaledBtnSizeVector / 2.f,
                                  CGRectGetWidth(visableLayoutRect),
                                  scaledBtnSizeVector);
        }
        
        btnView.frame = btnFrame;
        btnView.hidden = self.clipState != TailorToolActionClipStateNormal;
    }];
}

- (void) beginClipNormal {
    self.clipState = TailorToolActionClipStateNormal;
}

- (void) beginClipBounds {
    self.clipState = TailorToolActionClipStateBounds;
}

- (void) endClip {
    self.clipState = TailorToolActionClipStateNone;
}

- (void) beginEditingWithSide:(TailorCilpedImageViewEditingSide)editingSide {
    self.editingSide = editingSide;
}
- (void) endEditing {
    self.editingSide = TailorCilpedImageViewEditingSideNone;
}

- (BOOL) isEditing {
    return self.editingSide != TailorCilpedImageViewEditingSideNone;
}

- (BOOL) isEditingLinkageBounds {
    if (self.isEditing && self.clipState == TailorToolActionClipStateBounds) {
        if (self.tileDirection == TailorTileDirectionVertically
            && (self.editingSide == TailorCilpedImageViewEditingSideLeft
                || self.editingSide == TailorCilpedImageViewEditingSideRight)) {
                return YES;
            } else if(self.tileDirection == TailorTileDirectionHorizontally
                      && (self.editingSide == TailorCilpedImageViewEditingSideTop
                          || self.editingSide == TailorCilpedImageViewEditingSideBottom)) {
                          return YES;
                      }
    }
    return NO;
}

@end
