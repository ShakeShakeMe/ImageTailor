//
//  EditorZoomingScrollView.m
//  ImageTailor
//
//  Created by dl on 2018/5/19.
//  Copyright © 2018年 dl. All rights reserved.
//

#import "EditorZoomingScrollView.h"
#import "TailorZoomingFloatEditBtnView.h"
#import "EditorClipContext.h"
#import "EditorPixellateContext.h"

@interface EditorZoomingScrollView()<UIScrollViewDelegate, TailorZoomingFloatEditBtnViewDelegate>
@property (nonatomic, assign, readwrite) TailorTileDirection tileDirection;
@property (nonatomic, strong, readwrite) NSArray<TailorAssetModel *> *assetModels;

// views
@property (nonatomic, strong) UIView *imageViewsContainer;
@property (nonatomic, strong, readwrite) NSArray<TailorReserveInsetsClipedImageView *> *imageViews;

@property (nonatomic, strong) EditorClipContext *clipContext;
@property (nonatomic, strong) EditorPixellateContext *pixellateContext;
@end

@implementation EditorZoomingScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.imageViewsContainer];
        self.delegate = self;
        self.minimumZoomScale = TailorMinZoomingScale;
        self.maximumZoomScale = TailorMaxZoomingScale;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        
        self.clipContext = [[EditorClipContext alloc] init];
        self.clipContext.floatEditBtnViewDelegate = self;
        self.clipContext.imageContainerView = self.imageViewsContainer;
        
        self.pixellateContext = [[EditorPixellateContext alloc] init];
        self.pixellateContext.imageContainerView = self.imageViewsContainer;
    }
    return self;
}

#pragma mark - public methods
- (void) refreshWithAssetModels:(NSArray<TailorAssetModel *> *)assetModels
                  tileDirection:(TailorTileDirection)tileDirection {
    self.tileDirection = tileDirection;
    self.assetModels = [assetModels copy];
    
    [self clearAllSubViews];
    
    // generate all images
    self.imageViews = [assetModels bk_map:^id(TailorAssetModel *model) {
        TailorReserveInsetsClipedImageView *imgView = [[TailorReserveInsetsClipedImageView alloc] init];
        [imgView bindAssetModel:model];
        [self.imageViewsContainer addSubview:imgView];
        return imgView;
    }];
    
    // clip btn views
    self.clipContext.tileDirection = tileDirection;
    self.clipContext.imagesCnt = self.imageViews.count;
    [self.clipContext setup];
    
    // pixellate
    self.pixellateContext.tileDirection = tileDirection;
    
    // others
    if (tileDirection == TailorTileDirectionVertically) {
        self.alwaysBounceVertical = YES;
        self.alwaysBounceHorizontal = NO;
    } else {
        self.alwaysBounceVertical = NO;
        self.alwaysBounceHorizontal = YES;
    }
    
    [self zoomToReset];
    [self setNeedsLayout];
}

- (void) clipWithState:(TailorToolActionClipState)clipState {
    if (clipState == TailorToolActionClipStateBounds) {
        [self.clipContext beginClipBounds];
    } else if(clipState == TailorToolActionClipStateNormal) {
        [self.clipContext beginClipNormal];
    } else {
        [self.clipContext endClip];
    }
    [self clearEditStateWithEditing:NO];
    [self setNeedsLayout];
}

- (void) pixellateWithType:(ScrawlToolBarPixellateType)pixellateType {
    if (pixellateType == ScrawlToolBarPixellateTypeNone) {
        [self.pixellateContext endDoPixellate];
    } else {
        [self.pixellateContext beginDoPixellateWithType:pixellateType assetModels:self.assetModels];
    }
}

- (void)zoomToReset {
    [self setZoomScale:(self.tileDirection == TailorTileDirectionVertically ?
                        TailorDefaultZoomingSacleVertically : TailorDefaultZoomingSacleHorizontally)
              animated:NO];
}

#pragma mark - layout subviews
- (void) layoutSubviews {
    [super layoutSubviews];
    
    BOOL isVertically = self.tileDirection == TailorTileDirectionVertically;
    CGFloat imageFixedTiledValue = isVertically ? self.width : self.height;
    __block UIView *preView = nil;
    __block CGFloat growingTileSum = 0.f;
    
    NSMutableArray *allImageRects = [@[] mutableCopy];
    [self.imageViews enumerateObjectsUsingBlock:^(TailorReserveInsetsClipedImageView * _Nonnull imgView, NSUInteger idx, BOOL * _Nonnull stop) {
        TailorAssetModel *model = self.assetModels[idx];
        
        CGFloat width = isVertically ? imageFixedTiledValue : imageFixedTiledValue * model.scaledImageSize.width / model.scaledImageSize.height;
        CGFloat height = isVertically ? imageFixedTiledValue * model.scaledImageSize.height / model.scaledImageSize.width : imageFixedTiledValue;
        CGFloat x = isVertically ? (self.width - width) : (preView ? preView.right : 0.f);
        CGFloat y = isVertically ? (preView ? preView.bottom : 0.f) : (self.height - height);
        
        width -= model.reverseInsets.left + model.reverseInsets.right;
        height -= model.reverseInsets.top + model.reverseInsets.bottom;
        
        // 消除剪切时的体验不好问题
        if ([self.clipContext isEditingLinkageBounds]) {
            x += isVertically ? self.clipContext.extraTopOrLeftDistance : 0.f;
            y += isVertically ? 0.f : self.clipContext.extraTopOrLeftDistance;
        } else if (![self.clipContext isEditingLinkageBounds] && idx == 0) {
            x += isVertically ? 0.f : self.clipContext.extraTopOrLeftDistance;
            y += isVertically ? self.clipContext.extraTopOrLeftDistance : 0.f;
        }
        
        UIEdgeInsets extraInsets = self.clipContext.isEditing ? self.clipContext.preBoundsLinkageClipInsets : model.reverseInsets;
        if (isVertically) {
            x += (extraInsets.left + extraInsets.right) / 2.f;
        } else {
            y += (extraInsets.top + extraInsets.bottom) / 2.f;
        }
        
        imgView.frame = CGRectMake(x, y, width, height);
        [allImageRects addObject:[NSValue valueWithCGRect:imgView.frame]];
        
        growingTileSum += isVertically ? height : width;
        preView = imgView;
    }];
    
    // container view position
    CGFloat contentSizeWidth = (isVertically ? self.width : growingTileSum) * self.zoomScale;
    CGFloat contentSizeHeight = (isVertically ? growingTileSum : self.height)  * self.zoomScale;
    CGSize containerViewSize = CGSizeMake(contentSizeWidth, contentSizeHeight);
    if (!self.clipContext.isEditing) {
        self.contentSize = containerViewSize;
        
        CGSize boundsSize = self.bounds.size;
        CGRect frameToCenter = (CGRect){CGPointZero, containerViewSize};
        // Horizontally
        frameToCenter.origin.x = 0;
        if (frameToCenter.size.width < boundsSize.width) {
            frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
        }
        // Vertically
        frameToCenter.origin.y = 0;
        if (frameToCenter.size.height < boundsSize.height) {
            frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2.0);
        }
        self.imageViewsContainer.frame = frameToCenter;
    }
    
    // 计算屏幕中container view的可视区域
    CGRect visableRect = [self.superview convertRect:((CGRect){CGPointZero, self.size}) toView:self.imageViewsContainer];
    CGFloat scaledBtnSizeVector= 1.f / self.zoomScale * 20.f;
    [self.clipContext didChangeVisableRect:visableRect imageRects:allImageRects scaledBtnSizeVector:scaledBtnSizeVector];
}

#pragma mark - touch event
- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.scrollEnabled || touches.count > 1) {
        return ;
    }
    
    BOOL isHorizontally = self.tileDirection == TailorTileDirectionHorizontally;
    self.clipContext.currentEditingTouch = touches.anyObject;
    CGPoint touchPoint = [self.clipContext.currentEditingTouch locationInView:self.imageViewsContainer];
    self.clipContext.preMovedTouchPoint = touchPoint;
    CGFloat minusToEditingBtnView = isHorizontally ? touchPoint.x - self.clipContext.currentEditingBtnView.centerX : touchPoint.y - self.clipContext.currentEditingBtnView.centerY;
    
    TailorCilpedImageViewEditingSide editingSide = TailorCilpedImageViewEditingSideNone;
    self.clipContext.editingSide = editingSide;
    if (self.clipContext.clipState == TailorToolActionClipStateBounds) {
        if (self.tileDirection == TailorTileDirectionVertically) {
            if (self.clipContext.currentEditingBtnView.alignment == TailorZoomingFloatEditAlignLeft
                || self.clipContext.currentEditingBtnView.alignment == TailorZoomingFloatEditAlignRight) {
                editingSide = self.clipContext.currentEditingBtnView.alignment == TailorZoomingFloatEditAlignLeft ? TailorCilpedImageViewEditingSideLeft : TailorCilpedImageViewEditingSideRight;
            }
        } else if (self.tileDirection == TailorTileDirectionHorizontally) {
            if (self.clipContext.currentEditingBtnView.alignment == TailorZoomingFloatEditAlignTop
                || self.clipContext.currentEditingBtnView.alignment == TailorZoomingFloatEditAlignBottom) {
                editingSide = self.clipContext.currentEditingBtnView.alignment == TailorZoomingFloatEditAlignTop ? TailorCilpedImageViewEditingSideTop : TailorCilpedImageViewEditingSideBottom;
            }
        }
        [self.clipContext beginEditingWithSide:editingSide];
    }
    
    // 如果不是bounds clip，则就是normal clip
    if (![self.clipContext isEditingLinkageBounds]) {
        // 下侧的或者右侧的 image
        if (minusToEditingBtnView > 0) {
            self.clipContext.currentEditingImageview = [self.imageViews bk_select:^BOOL(TailorReserveInsetsClipedImageView *imageView) {
                return isHorizontally ? imageView.centerX > self.clipContext.currentEditingBtnView.centerX
                : imageView.centerY > self.clipContext.currentEditingBtnView.centerY;
            }].firstObject;
            editingSide = isHorizontally ? TailorCilpedImageViewEditingSideLeft : TailorCilpedImageViewEditingSideTop;
        } else {
            self.clipContext.currentEditingImageview = [self.imageViews bk_select:^BOOL(TailorReserveInsetsClipedImageView *imageView) {
                return isHorizontally ? imageView.centerX < self.clipContext.currentEditingBtnView.centerX
                : imageView.centerY < self.clipContext.currentEditingBtnView.centerY;
            }].lastObject;
            editingSide = isHorizontally ? TailorCilpedImageViewEditingSideRight : TailorCilpedImageViewEditingSideBottom;
        }
        [self.clipContext beginEditingWithSide:editingSide];
    }
}

- (void) touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!self.clipContext.isEditing || touches.anyObject != self.clipContext.currentEditingTouch) {
        return ;
    }
    BOOL isHorizontally = self.tileDirection == TailorTileDirectionHorizontally;
    CGPoint touchPoint = [touches.anyObject locationInView:self.imageViewsContainer];
    
    if ([self.clipContext isEditingLinkageBounds]) {
        CGFloat minusToPreTouch = isHorizontally ? touchPoint.y - self.clipContext.preMovedTouchPoint.y
        : touchPoint.x - self.clipContext.preMovedTouchPoint.x;
        
        TailorReserveInsetsClipedImageView *firstImageView = [self.imageViews firstObject];
        if ([firstImageView makeTranslateWithLength:minusToPreTouch editingSide:self.clipContext.editingSide]) {
            [self.imageViews bk_each:^(TailorReserveInsetsClipedImageView *imageView) {
                if (imageView != firstImageView) {
                    [imageView makeTranslateWithLength:minusToPreTouch editingSide:self.clipContext.editingSide];
                }
            }];
            if (self.clipContext.editingSide == TailorCilpedImageViewEditingSideRight
                || self.clipContext.editingSide == TailorCilpedImageViewEditingSideBottom) {
                self.clipContext.extraTopOrLeftDistance += minusToPreTouch;
            }
        }
    } else {
        CGFloat minusToPreTouch = isHorizontally ? touchPoint.x - self.clipContext.preMovedTouchPoint.x
        : touchPoint.y - self.clipContext.preMovedTouchPoint.y;
        if ([self.clipContext.currentEditingImageview makeTranslateWithLength:minusToPreTouch editingSide:self.clipContext.editingSide]) {
            if (self.clipContext.editingSide == TailorCilpedImageViewEditingSideRight
                || self.clipContext.editingSide == TailorCilpedImageViewEditingSideBottom) {
                self.clipContext.extraTopOrLeftDistance += minusToPreTouch;
            }
        }
    }
    self.clipContext.preMovedTouchPoint = touchPoint;
    
    [self setNeedsLayout];
}

- (void) touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // 先针对bounds linkage bounds做值保存
    BOOL isVertically = self.tileDirection == TailorTileDirectionVertically;
    BOOL isEditingLinkageBounds = [self.clipContext isEditingLinkageBounds];
    if (isEditingLinkageBounds) {
        TailorReserveInsetsClipedImageView *firstImageView = self.imageViews.firstObject;
        UIEdgeInsets reverseInsets = firstImageView.assetModel.reverseInsets;
        if (isVertically) {
            self.clipContext.preBoundsLinkageClipInsets = UIEdgeInsetsMake(0.f, reverseInsets.left, 0.f, reverseInsets.right);
        } else {
            self.clipContext.preBoundsLinkageClipInsets = UIEdgeInsetsMake(reverseInsets.top, 0.f, reverseInsets.bottom, 0.f);
        }
    }
    
    self.clipContext.editingSide = TailorCilpedImageViewEditingSideNone;
    self.clipContext.preMovedTouchPoint = CGPointZero;
    self.clipContext.currentEditingImageview = nil;
    self.clipContext.currentEditingTouch = nil;
    
    CGPoint preContentOffset = self.contentOffset;
    CGFloat extraTopOrLeftDistanceTmp = self.clipContext.extraTopOrLeftDistance;
    self.clipContext.extraTopOrLeftDistance = 0.f;
    [UIView animateWithDuration:0.2f animations:^{
        [self setNeedsLayout];
        [self layoutIfNeeded];
        
        CGPoint contentOffset = CGPointMake(preContentOffset.x - (isVertically ? 0.f : extraTopOrLeftDistanceTmp * self.zoomScale),
                                            preContentOffset.y - (isVertically ? extraTopOrLeftDistanceTmp * self.zoomScale : 0.f));
        if (isEditingLinkageBounds) {
            contentOffset = CGPointMake(preContentOffset.x - (isVertically ? extraTopOrLeftDistanceTmp * self.zoomScale : 0.f),
                                        preContentOffset.y - (isVertically ? 0.f : extraTopOrLeftDistanceTmp * self.zoomScale));
        }
        
        self.contentOffset = CGPointMake(isVertically ? 0.f :MAX(MIN(contentOffset.x, self.contentSize.width - self.width), 0.f),
                                         isVertically ? MAX(MIN(contentOffset.y, self.contentSize.height - self.height), 0.f) : 0.f);
    }];
}

- (void) touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageViewsContainer;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    self.scrollEnabled = YES; // reset
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    self.scrollEnabled = scrollView.zoomScale != 1.f;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark - TailorZoomingFloatEditBtnViewDelegate
- (void) floatEditBtnView:(TailorZoomingFloatEditBtnView *)floatEditBtnView isEditing:(BOOL)isEditing {
    [self clearEditStateWithEditing:isEditing];
    if (isEditing) {
        [floatEditBtnView beginEditing];
        self.scrollEnabled = NO;
    }
    
    self.clipContext.currentEditingBtnView = isEditing ? floatEditBtnView : nil;
}

#pragma mark - other methods, clear state
- (void) clearAllSubViews {
    [self.imageViews bk_each:^(TailorReserveInsetsClipedImageView *img) {
        [img removeFromSuperview];
    }];
}

- (void) clearEditStateWithEditing:(BOOL)isEditing {
    self.scrollEnabled = YES;
    self.clipContext.preMovedTouchPoint = CGPointZero;
    self.clipContext.currentEditingBtnView = nil;
    self.clipContext.currentEditingImageview = nil;
    self.clipContext.extraTopOrLeftDistance = 0.f;
    
    void(^eachBtnViewBlock)(TailorZoomingFloatEditBtnView *) = ^(TailorZoomingFloatEditBtnView *btn) {
        [btn reset];
        btn.alpha = isEditing ? 0.f : 1.f;
    };
    [self.clipContext.normalEditBtnViews bk_each:eachBtnViewBlock];
    [self.clipContext.boundsEditBtnViews bk_each:eachBtnViewBlock];
    
    [self setNeedsLayout];
}

#pragma mark - getters
LazyPropertyWithInit(UIView, imageViewsContainer, {})

@end
