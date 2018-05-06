//
//  ScrawlZoomingScollView.m
//  ImageTailor
//
//  Created by dl on 2018/5/5.
//  Copyright © 2018年 dl. All rights reserved.
//

#import "ScrawlZoomingScollView.h"
#import "TailorReserveInsetsClipedImageView.h"

@interface ScrawlZoomingScollView()<UIScrollViewDelegate>
@property (nonatomic, strong) UIView *imageContainerView;
@property (nonatomic, strong) NSArray<TailorReserveInsetsClipedImageView *> *imageViews;

@property (nonatomic, assign, readwrite) TailorTileDirection tileDirection;
@property (nonatomic, strong, readwrite) NSArray<TailorAssetModel *> *assetModels;

@property (nonatomic, assign) CGPoint defaultContentOffset;
@end

@implementation ScrawlZoomingScollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.imageContainerView];
        
        self.scrollsToTop = NO;
        self.delegate = self;
        self.minimumZoomScale = TailorMinZoomingScale;
        self.maximumZoomScale = TailorMaxZoomingScale;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
    }
    return self;
}

- (void) refreshWithAssetModels:(NSArray<TailorAssetModel *> *)assetModels
                  tileDirection:(TailorTileDirection)tileDirection
               defaultZoomScale:(CGFloat) zoomScale
           defaultContentOffset:(CGPoint)contentOffset {
    self.tileDirection = tileDirection;
    self.assetModels = [assetModels copy];
    
    // remove from super view
    [self.imageViews bk_each:^(UIImageView *imageView) {
        [imageView removeFromSuperview];
    }];
    self.imageViews = [assetModels bk_map:^id(TailorAssetModel *model) {
        TailorReserveInsetsClipedImageView *imageView = [[TailorReserveInsetsClipedImageView alloc] init];
        [imageView bindAssetModel:model];
        imageView.backgroundColor = [UIColor hex_randomColorWithAlpha:0.5f];
        [self.imageContainerView addSubview:imageView];
        return imageView;
    }];
    
    // others
    if (tileDirection == TailorTileDirectionVertically) {
        self.alwaysBounceVertical = YES;
        self.alwaysBounceHorizontal = NO;
    } else {
        self.alwaysBounceVertical = NO;
        self.alwaysBounceHorizontal = YES;
    }
    
    self.zoomScale = zoomScale;
    self.defaultContentOffset = contentOffset;
    [self setNeedsLayout];
}

- (void) viewDidAppear {
    self.defaultContentOffset = CGPointZero;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    BOOL isVertically = self.tileDirection == TailorTileDirectionVertically;
    CGFloat imageFixedTiledValue = isVertically ? self.width : self.height;
    __block UIView *preView = nil;
    __block CGFloat growingTileSum = 0.f;
    
    [self.imageViews enumerateObjectsUsingBlock:^(TailorReserveInsetsClipedImageView * _Nonnull imageView, NSUInteger idx, BOOL * _Nonnull stop) {
        TailorAssetModel *model = self.assetModels[idx];
        CGFloat width = isVertically ? imageFixedTiledValue : imageFixedTiledValue * model.scaledImageSize.width / model.scaledImageSize.height;
        CGFloat height = isVertically ? imageFixedTiledValue * model.scaledImageSize.height / model.scaledImageSize.width : imageFixedTiledValue;
        CGFloat x = isVertically ? (imageFixedTiledValue - width) : (preView ? preView.right : 0.f);
        CGFloat y = isVertically ? (preView ? preView.bottom : 0.f) : (imageFixedTiledValue - height);
        
        width -= model.reverseInsets.left + model.reverseInsets.right;
        height -= model.reverseInsets.top + model.reverseInsets.bottom;
        
        imageView.frame = CGRectMake(x, y, width, height);
        
        growingTileSum += isVertically ? height : width;
        preView = imageView;
    }];
    
    CGFloat contentSizeWidth = (isVertically ? self.width : growingTileSum) * self.zoomScale;
    CGFloat contentSizeHeight = (isVertically ? growingTileSum : self.height)  * self.zoomScale;
    CGSize containerViewSize = CGSizeMake(contentSizeWidth, contentSizeHeight);
    self.contentSize = containerViewSize;
    if (!CGPointEqualToPoint(self.defaultContentOffset, CGPointZero)) {
        self.contentOffset = self.defaultContentOffset;
    }
    
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
    self.imageContainerView.frame = frameToCenter;
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageContainerView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self setNeedsLayout];
}

#pragma mark - getters
LazyPropertyWithInit(UIView, imageContainerView, {})
@end
