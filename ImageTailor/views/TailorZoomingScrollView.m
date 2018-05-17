//
//  TailorZoomingScrollView.m
//  ImageTailor
//
//  Created by dl on 2018/4/30.
//  Copyright © 2018年 dl. All rights reserved.
//

#import "TailorZoomingScrollView.h"
#import "TailorZoomingFloatEditBtnView.h"

@interface TailorZoomingScrollView()<UIScrollViewDelegate, TailorZoomingFloatEditBtnViewDelegate>
@property (nonatomic, strong) UIView *imageViewsContainer;

@property (nonatomic, assign, readwrite) TailorTileDirection tileDirection;
@property (nonatomic, strong, readwrite) NSArray<TailorReserveInsetsClipedImageView *> *imageViews;

@property (nonatomic, strong) NSArray<TailorZoomingFloatEditBtnView *> *normalEditBtnViews;
@property (nonatomic, strong) NSArray<TailorZoomingFloatEditBtnView *> *boundsEditBtnViews;

@property (nonatomic, strong, readwrite) NSArray<TailorAssetModel *> *assetModels;

// edit
@property (nonatomic, assign, readwrite) TailorToolActionClipState clipState;

@property (nonatomic, assign, getter=isEditing) BOOL editing;
@property (nonatomic, weak) TailorZoomingFloatEditBtnView *currentEditingBtnView;
@property (nonatomic, assign) CGPoint preMovedTouchPoint;
@property (nonatomic, weak) TailorReserveInsetsClipedImageView *currentEditingImageview;
@property (nonatomic, assign) TailorCilpedImageViewEditingSide editingSide;
@property (nonatomic, strong) UITouch *currentEditingTouch;

// 仅仅是为了防止剪切滑动时有错觉
@property (nonatomic, assign) CGFloat extraTopOrLeftDistance;
@property (nonatomic, assign) UIEdgeInsets preBoundsLinkageClipInsets;

// snapshot
@property (nonatomic, strong, readwrite) NSArray<NSValue *> *imageRectsOnSnapshot;
@end

@implementation TailorZoomingScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.imageViewsContainer];
        self.delegate = self;
        self.minimumZoomScale = TailorMinZoomingScale;
        self.maximumZoomScale = TailorMaxZoomingScale;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
    }
    return self;
}

- (void) refreshWithAssetModels:(NSArray<TailorAssetModel *> *)assetModels
                  tileDirection:(TailorTileDirection)tileDirection {
    self.tileDirection = tileDirection;
    self.assetModels = [assetModels copy];
    
    // remove from super view
    [self.imageViews bk_each:^(TailorReserveInsetsClipedImageView *img) {
        [img removeFromSuperview];
    }];
    [self.boundsEditBtnViews bk_each:^(TailorZoomingFloatEditBtnView *btnView) {
        [btnView removeFromSuperview];
    }];
    [self.normalEditBtnViews bk_each:^(TailorZoomingFloatEditBtnView *btnView) {
        [btnView removeFromSuperview];
    }];
    
    self.imageViews = [assetModels bk_map:^id(TailorAssetModel *model) {
        TailorReserveInsetsClipedImageView *imgView = [[TailorReserveInsetsClipedImageView alloc] init];
        [imgView bindAssetModel:model];
        imgView.backgroundColor = [UIColor hex_randomColorWithAlpha:0.5f];
        [self.imageViewsContainer addSubview:imgView];
        return imgView;
    }];
    
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
        btnView.delegate = self;
        [self.imageViewsContainer addSubview:btnView];
    }];
    
    // normal btn views
    NSMutableArray *normalEditBtnViews = [@[] mutableCopy];
    [self.imageViews enumerateObjectsUsingBlock:^(TailorReserveInsetsClipedImageView * _Nonnull imgView, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx < self.imageViews.count - 1) {
            TailorZommingFloatEditAlignment alignment = self.tileDirection == TailorTileDirectionVertically ? TailorZoomingFloatEditAlignHorizontally : TailorZoomingFloatEditAlignVertically;
            [normalEditBtnViews addObject:[[TailorZoomingFloatEditBtnView alloc] initWithAlignment:alignment]];
        }
    }];
    
    self.normalEditBtnViews = [normalEditBtnViews copy];
    [self.normalEditBtnViews bk_each:^(TailorZoomingFloatEditBtnView * btnView) {
        btnView.delegate = self;
        [self.imageViewsContainer addSubview:btnView];
    }];
    
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

- (void)zoomToReset {
    [self setZoomScale:(self.tileDirection == TailorTileDirectionVertically ?
                        TailorDefaultZoomingSacleVertically : TailorDefaultZoomingSacleHorizontally)
              animated:NO];
}

- (NSArray<UIImage *> *) allClipedImages {
    return [self.imageViews bk_map:^id(TailorReserveInsetsClipedImageView *imageView) {
        return [imageView clipedImage];
    }];
}
- (UIImage *) tailoredImagesSnapshot {
    BOOL isVertically = self.tileDirection == TailorTileDirectionVertically;
    
    NSArray<UIImage *> *images = [self allClipedImages];
    __block CGFloat maxImageVector = 0.f;
    [images enumerateObjectsUsingBlock:^(UIImage *image, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat imageVector = (isVertically ? image.size.width : image.size.height) * image.scale;
        maxImageVector = MAX(maxImageVector, imageVector);
    }];
    __block CGFloat imageVerticalVectorSum = 0.f;
    __block CGRect preImageRect = CGRectZero;
    NSArray<NSValue *> *imageRects = [images bk_map:^id(UIImage *image) {
        CGFloat enlargeScale = maxImageVector / (image.scale * (isVertically ? image.size.width : image.size.height));
        CGSize imageSize = CGSizeMake(image.size.width * enlargeScale, image.size.height * enlargeScale);
        CGRect imageRect = CGRectMake(0.f, 0.f, imageSize.width, imageSize.height);
        if (isVertically) {
            imageRect.origin = CGPointMake(CGRectGetMinX(preImageRect), CGRectGetMaxY(preImageRect));
            imageVerticalVectorSum += imageSize.height;
        } else {
            imageRect.origin = CGPointMake(CGRectGetMaxX(preImageRect), CGRectGetMinY(preImageRect));
            imageVerticalVectorSum += imageSize.width;
        }
        preImageRect = imageRect;
        return [NSValue valueWithCGRect:imageRect];
    }];
    self.imageRectsOnSnapshot = imageRects;
    
    // draw on one bitmap
    UIGraphicsBeginImageContext(CGSizeMake(isVertically ? maxImageVector : imageVerticalVectorSum,
                                           isVertically ? imageVerticalVectorSum : maxImageVector));
    [images enumerateObjectsUsingBlock:^(UIImage *image, NSUInteger idx, BOOL * _Nonnull stop) {
        [image drawInRect:[imageRects[idx] CGRectValue]];
    }];
    UIImage *mergedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return mergedImage;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    BOOL isVertically = self.tileDirection == TailorTileDirectionVertically;
    CGFloat imageFixedTiledValue = isVertically ? self.width : self.height;
    __block UIView *preView = nil;
    __block CGFloat growingTileSum = 0.f;
    
    [self.imageViews enumerateObjectsUsingBlock:^(TailorReserveInsetsClipedImageView * _Nonnull imgView, NSUInteger idx, BOOL * _Nonnull stop) {
        TailorAssetModel *model = self.assetModels[idx];

        CGFloat width = isVertically ? imageFixedTiledValue : imageFixedTiledValue * model.scaledImageSize.width / model.scaledImageSize.height;
        CGFloat height = isVertically ? imageFixedTiledValue * model.scaledImageSize.height / model.scaledImageSize.width : imageFixedTiledValue;
        CGFloat x = isVertically ? (self.width - width) : (preView ? preView.right : 0.f);
        CGFloat y = isVertically ? (preView ? preView.bottom : 0.f) : (self.height - height);

        width -= model.reverseInsets.left + model.reverseInsets.right;
        height -= model.reverseInsets.top + model.reverseInsets.bottom;
        if ([self isEditingLinkageBounds]) {
            x += isVertically ? self.extraTopOrLeftDistance : 0.f;
            y += isVertically ? 0.f : self.extraTopOrLeftDistance;
        } else if (![self isEditingLinkageBounds] && idx == 0) {
            x += isVertically ? 0.f : self.extraTopOrLeftDistance;
            y += isVertically ? self.extraTopOrLeftDistance : 0.f;
        }
        
        UIEdgeInsets extraInsets = self.isEditing ? self.preBoundsLinkageClipInsets : model.reverseInsets;
        if (isVertically) {
            x += (extraInsets.left + extraInsets.right) / 2.f;
        } else {
            y += (extraInsets.top + extraInsets.bottom) / 2.f;
        }
        
        imgView.frame = CGRectMake(x, y, width, height);

        growingTileSum += isVertically ? height : width;
        preView = imgView;
    }];

    // container view position
    CGFloat contentSizeWidth = (isVertically ? self.width : growingTileSum) * self.zoomScale;
    CGFloat contentSizeHeight = (isVertically ? growingTileSum : self.height)  * self.zoomScale;
    CGSize containerViewSize = CGSizeMake(contentSizeWidth, contentSizeHeight);
    if (!self.isEditing) {
        self.contentSize = containerViewSize;
        
        // Center the container view as it becomes smaller than the size of the screen
        CGSize boundsSize = self.bounds.size;
        CGRect frameToCenter = (CGRect){CGPointZero, containerViewSize};
        // Horizontally
        if (frameToCenter.size.width < boundsSize.width) {
            frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
        } else {
            frameToCenter.origin.x = 0;
        }
        
        // Vertically
        if (frameToCenter.size.height < boundsSize.height) {
            frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2.0);
        } else {
            frameToCenter.origin.y = 0;
        }
        self.imageViewsContainer.frame = frameToCenter;
    }
    
    // 计算屏幕中container view的可视区域
    CGFloat x = MAX(self.contentOffset.x, 0.f) / MAX(self.zoomScale, 1.f);
    CGFloat y = MAX(self.contentOffset.y, 0.f) / MAX(self.zoomScale, 1.f);
    
    // width
    CGFloat width = self.width;
    if (self.contentOffset.x > 0) {
        width = MIN((self.contentSize.width - self.contentOffset.x), self.width);
    } else {
        width = MAX(self.width + self.contentOffset.x, 0.f);
    }
    width /= MAX(self.zoomScale, 1.f);
    
    // height
    CGFloat height = self.height;
    if (self.contentOffset.y > 0) {
        height = MIN((self.contentSize.height - self.contentOffset.y), self.height);
    } else {
        height = MAX(self.height + self.contentOffset.y, 0.f);
    }
    height /= MAX(self.zoomScale, 1.f);
    CGRect visableRect = CGRectMake(x, y, width, height);
    NSLog(@"visableRect: %@", NSStringFromCGRect(visableRect));
    
    // bounds btn views frame
    CGFloat btnViewSizeValue= 1.f / self.zoomScale * 15.f;
    [self.boundsEditBtnViews enumerateObjectsUsingBlock:^(TailorZoomingFloatEditBtnView * btnView, NSUInteger idx, BOOL * _Nonnull stop) {
        CGRect btnFrame = CGRectZero;
        TailorReserveInsetsClipedImageView *firstImgView = self.imageViews.firstObject;
        TailorReserveInsetsClipedImageView *lastImgView = self.imageViews.lastObject;
        
        BOOL isClipStateNormal = self.clipState == TailorToolActionClipStateNormal;
        BOOL btnViewHidden = NO;
        if (btnView.alignment == TailorZoomingFloatEditAlignTop) {
            btnFrame = CGRectMake(
//                                  CGRectGetMinX(visableRect),
                                  firstImgView.left,
                                  firstImgView.top,
//                                  CGRectGetWidth(visableRect),
                                  isVertically ? firstImgView.width : lastImgView.right - firstImgView.left,
                                  btnViewSizeValue);
            btnViewHidden = isClipStateNormal && !isVertically;
        } else if (btnView.alignment == TailorZoomingFloatEditAlignLeft) {
            btnFrame = CGRectMake(firstImgView.left,
//                                  CGRectGetMinY(visableRect),
                                  firstImgView.top,
                                  btnViewSizeValue,
//                                  CGRectGetHeight(visableRect));
                                  isVertically ? lastImgView.bottom - firstImgView.top : firstImgView.height);
            btnViewHidden = isClipStateNormal && isVertically;
        } else if (btnView.alignment == TailorZoomingFloatEditAlignBottom) {
            btnFrame = CGRectMake(
//                                  CGRectGetMinX(visableRect),
                                  firstImgView.left,
                                  lastImgView.bottom - btnViewSizeValue,
//                                  CGRectGetWidth(visableRect),
                                  isVertically ? lastImgView.width : lastImgView.right - firstImgView.left,
                                  btnViewSizeValue);
            btnViewHidden = isClipStateNormal && !isVertically;
        } else {
            btnFrame = CGRectMake(
//                                  CGRectGetMaxX(visableRect) - btnViewSizeValue,
                                  lastImgView.right - btnViewSizeValue,
//                                  CGRectGetMinY(visableRect),
                                  firstImgView.top,
                                  btnViewSizeValue,
//                                  CGRectGetHeight(visableRect));
                                  isVertically ? lastImgView.bottom - firstImgView.top : lastImgView.height);
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
        CGRect imgViewFrame = self.imageViews[idx].frame;
        CGRect btnFrame = CGRectZero;
        if (btnView.alignment == TailorZoomingFloatEditAlignVertically) {
            btnFrame = CGRectMake(CGRectGetMaxX(imgViewFrame) - btnViewSizeValue / 2.f, CGRectGetMinY(imgViewFrame), btnViewSizeValue,  CGRectGetHeight(imgViewFrame));
        } else {
            btnFrame = CGRectMake(CGRectGetMinX(imgViewFrame), CGRectGetMaxY(imgViewFrame) - btnViewSizeValue / 2.f, CGRectGetWidth(imgViewFrame), btnViewSizeValue);
        }
        
        btnView.frame = btnFrame;
        btnView.hidden = self.clipState != TailorToolActionClipStateNormal;
    }];
}

- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.scrollEnabled || touches.count > 1) {
        return ;
    }
    
    BOOL isHorizontally = self.tileDirection == TailorTileDirectionHorizontally;
    self.currentEditingTouch = touches.anyObject;
    CGPoint touchPoint = [self.currentEditingTouch locationInView:self.imageViewsContainer];
    self.preMovedTouchPoint = touchPoint;
    CGFloat minusToEditingBtnView = isHorizontally ? touchPoint.x - self.currentEditingBtnView.centerX : touchPoint.y - self.currentEditingBtnView.centerY;
    
    TailorCilpedImageViewEditingSide editingSide = TailorCilpedImageViewEditingSideNone;
    self.editingSide = editingSide;
    if (self.clipState == TailorToolActionClipStateBounds) {
        if (self.tileDirection == TailorTileDirectionVertically) {
            if (self.currentEditingBtnView.alignment == TailorZoomingFloatEditAlignLeft
                || self.currentEditingBtnView.alignment == TailorZoomingFloatEditAlignRight) {
                editingSide = self.currentEditingBtnView.alignment == TailorZoomingFloatEditAlignLeft ? TailorCilpedImageViewEditingSideLeft : TailorCilpedImageViewEditingSideRight;
                self.editing = YES;
            }
        } else if (self.tileDirection == TailorTileDirectionHorizontally) {
            if (self.currentEditingBtnView.alignment == TailorZoomingFloatEditAlignTop
                || self.currentEditingBtnView.alignment == TailorZoomingFloatEditAlignBottom) {
                editingSide = self.currentEditingBtnView.alignment == TailorZoomingFloatEditAlignTop ? TailorCilpedImageViewEditingSideTop : TailorCilpedImageViewEditingSideBottom;
                self.editing = YES;
            }
        }
        if (self.editing) {
            self.editingSide = editingSide;
        }
    }
    
    // 如果不是bounds clip，则就是normal clip
    if (![self isEditingLinkageBounds]) {
        // 下侧的或者右侧的 image
        if (minusToEditingBtnView > 0) {
            self.currentEditingImageview = [self.imageViews bk_select:^BOOL(TailorReserveInsetsClipedImageView *imageView) {
                return isHorizontally ? imageView.centerX > self.currentEditingBtnView.centerX
                : imageView.centerY > self.currentEditingBtnView.centerY;
            }].firstObject;
            editingSide = isHorizontally ? TailorCilpedImageViewEditingSideLeft : TailorCilpedImageViewEditingSideTop;
        } else {
            self.currentEditingImageview = [self.imageViews bk_select:^BOOL(TailorReserveInsetsClipedImageView *imageView) {
                return isHorizontally ? imageView.centerX < self.currentEditingBtnView.centerX
                : imageView.centerY < self.currentEditingBtnView.centerY;
            }].lastObject;
            editingSide = isHorizontally ? TailorCilpedImageViewEditingSideRight : TailorCilpedImageViewEditingSideBottom;
        }
        
        self.editing = self.currentEditingImageview != nil ? YES : NO;
        if (self.editing) {
            self.editingSide = editingSide;
        }
    }
    NSLog(@"touchesBegan at:%@, y minus:%@, editingSide:%@", NSStringFromCGPoint(touchPoint), @(minusToEditingBtnView), @(editingSide));
}

- (void) touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!self.isEditing || touches.anyObject != self.currentEditingTouch) {
        return ;
    }
    BOOL isHorizontally = self.tileDirection == TailorTileDirectionHorizontally;
    CGPoint touchPoint = [touches.anyObject locationInView:self.imageViewsContainer];
    
    if ([self isEditingLinkageBounds]) {
        CGFloat minusToPreTouch = isHorizontally ? touchPoint.y - self.preMovedTouchPoint.y
                                                 : touchPoint.x - self.preMovedTouchPoint.x;
        
        TailorReserveInsetsClipedImageView *firstImageView = [self.imageViews firstObject];
        if ([firstImageView makeTranslateWithLength:minusToPreTouch editingSide:self.editingSide]) {
            [self.imageViews bk_each:^(TailorReserveInsetsClipedImageView *imageView) {
                if (imageView != firstImageView) {
                    [imageView makeTranslateWithLength:minusToPreTouch editingSide:self.editingSide];
                }
            }];
            if (self.editingSide == TailorCilpedImageViewEditingSideRight
                || self.editingSide == TailorCilpedImageViewEditingSideBottom) {
                self.extraTopOrLeftDistance += minusToPreTouch;
            }
        }
    } else {
        CGFloat minusToPreTouch = isHorizontally ? touchPoint.x - self.preMovedTouchPoint.x
                                                 : touchPoint.y - self.preMovedTouchPoint.y;
        if ([self.currentEditingImageview makeTranslateWithLength:minusToPreTouch editingSide:self.editingSide]) {
            if (self.editingSide == TailorCilpedImageViewEditingSideRight
                || self.editingSide == TailorCilpedImageViewEditingSideBottom) {
                self.extraTopOrLeftDistance += minusToPreTouch;
            }
        }
    }
    self.preMovedTouchPoint = touchPoint;
    
    [self setNeedsLayout];
}

- (void) touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    // 先针对bounds linkage bounds做值保存
    BOOL isVertically = self.tileDirection == TailorTileDirectionVertically;
    BOOL isEditingLinkageBounds = [self isEditingLinkageBounds];
    if (isEditingLinkageBounds) {
        TailorReserveInsetsClipedImageView *firstImageView = self.imageViews.firstObject;
        UIEdgeInsets reverseInsets = firstImageView.assetModel.reverseInsets;
        if (isVertically) {
            self.preBoundsLinkageClipInsets = UIEdgeInsetsMake(0.f, reverseInsets.left, 0.f, reverseInsets.right);
        } else {
            self.preBoundsLinkageClipInsets = UIEdgeInsetsMake(reverseInsets.top, 0.f, reverseInsets.bottom, 0.f);
        }
    }

    self.editing = NO;
    self.editingSide = TailorCilpedImageViewEditingSideNone;
    self.preMovedTouchPoint = CGPointZero;
    self.currentEditingImageview = nil;
    self.currentEditingTouch = nil;
    
    CGPoint preContentOffset = self.contentOffset;

    NSLog(@"touchesEnded, contentOffset before: %@, extraTopOrLeftDistance:%@", NSStringFromCGPoint(self.contentOffset), @(self.extraTopOrLeftDistance));
    
    CGFloat extraTopOrLeftDistanceTmp = self.extraTopOrLeftDistance;
    self.extraTopOrLeftDistance = 0.f;
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
    } completion:^(BOOL finished) {
        NSLog(@"touchesEnded, contentOffset after: %@", NSStringFromCGPoint(self.contentOffset));
    }];
}

- (void) touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageViewsContainer;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self setNeedsLayout];
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    NSMutableArray *allEditBtnViews = [@[] mutableCopy];
    [allEditBtnViews addObjectsFromArray:self.normalEditBtnViews];
    [allEditBtnViews addObjectsFromArray:self.boundsEditBtnViews];
    [[allEditBtnViews bk_select:^BOOL(TailorZoomingFloatEditBtnView *btnView) {
        return !btnView.hidden;
    }] bk_each:^(TailorZoomingFloatEditBtnView *btnView) {
        [btnView setNeedsLayout];
        // 要有这行，不然会因为布局不及时，导致抖动
        [btnView layoutIfNeeded];
    }];
}

#pragma mark - TailorZoomingFloatEditBtnViewDelegate
- (void) floatEditBtnView:(TailorZoomingFloatEditBtnView *)floatEditBtnView isEditing:(BOOL)isEditing {
    self.scrollEnabled = !isEditing;
    
    void(^eachBtnViewBlock)(TailorZoomingFloatEditBtnView *) = ^(TailorZoomingFloatEditBtnView *btn) {
        if (btn != floatEditBtnView) {
            [btn reset];
            btn.alpha = isEditing ? 0.f : 1.f;
        }
    };
    [self.normalEditBtnViews bk_each:eachBtnViewBlock];
    [self.boundsEditBtnViews bk_each:eachBtnViewBlock];
    
    self.currentEditingBtnView = isEditing ? floatEditBtnView : nil;
}

#pragma mark - TailorBottomToolBarControlDelegate
- (void)toolBarControl:(TailorBottomToolBarControl *)toolBarControl actionClip:(TailorToolActionClipState)clipState {
    self.clipState = clipState;
    
    self.scrollEnabled = YES;
    self.preMovedTouchPoint = CGPointZero;
    self.currentEditingBtnView = nil;
    self.currentEditingImageview = nil;
    self.extraTopOrLeftDistance = 0.f;
    
    void(^eachBtnViewBlock)(TailorZoomingFloatEditBtnView *) = ^(TailorZoomingFloatEditBtnView *btn) {
        [btn reset];
        btn.alpha = 1.f;
    };
    [self.normalEditBtnViews bk_each:eachBtnViewBlock];
    [self.boundsEditBtnViews bk_each:eachBtnViewBlock];
    
    [self setNeedsLayout];
}

#pragma mark - private methods
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

#pragma mark - getters
LazyPropertyWithInit(UIView, imageViewsContainer, {})

@end
