//
//  ScrawlZoomingScollView.m
//  ImageTailor
//
//  Created by dl on 2018/5/5.
//  Copyright © 2018年 dl. All rights reserved.
//

#import "ScrawlZoomingScollView.h"
#import "TailorReserveInsetsClipedImageView.h"
#import "ScrawlPixellateUtil.h"

static void *kPixellateLayerImageKey = &kPixellateLayerImageKey;

@interface ScrawlZoomingScollView()<UIScrollViewDelegate>
@property (nonatomic, strong) UIView *imageContainerView;
@property (nonatomic, strong) NSArray<TailorReserveInsetsClipedImageView *> *imageViews;

@property (nonatomic, assign, readwrite) TailorTileDirection tileDirection;
@property (nonatomic, strong, readwrite) NSArray<TailorAssetModel *> *assetModels;

@property (nonatomic, assign) CGPoint defaultContentOffset;

// pixellate
@property (nonatomic, strong) UIImage *snapshotImage;
@property (nonatomic, assign) ScrawlToolBarPixellateType pixellateType;
@property (nonatomic, strong) CALayer *smallRadiusPixellateImageLayer;
@property (nonatomic, strong) CALayer *middleRadiusPixellateImageLayer;
@property (nonatomic, strong) CALayer *largeRadiusPixellateImageLayer;
@property (nonatomic, strong) CAShapeLayer *pixellateDrawLayer;
@property (nonatomic, strong) NSMutableArray<UIImageView *> *pixellateImageViews;
@property (nonatomic, strong) UITouch *startTouch;
@property (nonatomic, assign) CGPoint startTouchPoint;

@property (nonatomic, assign) CGMutablePathRef path;
@end

@implementation ScrawlZoomingScollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.imageContainerView];
        self.pixellateImageViews = [@[] mutableCopy];
        
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

- (void) beginDoPixellateWithType:(ScrawlToolBarPixellateType)pixellateType {
    if (!self.snapshotImage) {
        [self generateSnapshot];
    }
    self.pixellateType = pixellateType;
    [self generatePixellateImage];
    self.panGestureRecognizer.minimumNumberOfTouches = 2;
    
    if (pixellateType == ScrawlToolBarPixellateTypeSmall) {
        [self.imageContainerView.layer addSublayer:self.smallRadiusPixellateImageLayer];
        self.smallRadiusPixellateImageLayer.mask = self.pixellateDrawLayer;
    } else if (pixellateType == ScrawlToolBarPixellateTypeMiddle) {
        [self.imageContainerView.layer addSublayer:self.middleRadiusPixellateImageLayer];
        self.middleRadiusPixellateImageLayer.mask = self.pixellateDrawLayer;
    } else {
        [self.imageContainerView.layer addSublayer:self.largeRadiusPixellateImageLayer];
        self.largeRadiusPixellateImageLayer.mask = self.pixellateDrawLayer;
    }
}

- (void) endDoPixllate {
    self.pixellateType = ScrawlToolBarPixellateTypeNone;
    self.panGestureRecognizer.minimumNumberOfTouches = 1;
    
    [self.smallRadiusPixellateImageLayer removeFromSuperlayer];
    [self.middleRadiusPixellateImageLayer removeFromSuperlayer];
    [self.largeRadiusPixellateImageLayer removeFromSuperlayer];
    self.pixellateDrawLayer.path = NULL;
}

- (void) pixellateWithdraw {
    UIImageView *lastPixellateImageView = self.pixellateImageViews.lastObject;
    [lastPixellateImageView removeFromSuperview];
    [self.pixellateImageViews removeObject:lastPixellateImageView];
    [self setNeedsLayout];
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
        
        if (isVertically) {
            x += (model.reverseInsets.left + model.reverseInsets.right) / 2.f;
        } else {
            y += (model.reverseInsets.top + model.reverseInsets.bottom) / 2.f;
        }
        
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

#pragma mark - touches
- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.pixellateType == ScrawlToolBarPixellateTypeNone || touches.count > 1) {
        return ;
    }
    
    self.startTouch = touches.anyObject;
    self.startTouchPoint = [self.startTouch locationInView:self.imageContainerView];
}

- (void) touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (touches.anyObject != self.startTouch || touches.count > 1) {
        return ;
    }
    CGPoint touchPoint = [touches.anyObject locationInView:self.imageContainerView];
    CGRect currentPixellateRect = CGRectMake(MIN(touchPoint.x, self.startTouchPoint.x),
                                             MIN(touchPoint.y, self.startTouchPoint.y),
                                             fabs(touchPoint.x - self.startTouchPoint.x),
                                             fabs(touchPoint.y - self.startTouchPoint.y));
    
    self.pixellateDrawLayer.path = [UIBezierPath bezierPathWithRect:currentPixellateRect].CGPath;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (touches.anyObject != self.startTouch || touches.count > 1) {
        return ;
    }
    
    CGPoint touchPoint = [touches.anyObject locationInView:self.imageContainerView];
    CGRect currentPixellateRect = CGRectMake(MAX(MIN(touchPoint.x, self.startTouchPoint.x), 0.f),
                                             MAX(MIN(touchPoint.y, self.startTouchPoint.y), 0.f),
                                             fabs(touchPoint.x - self.startTouchPoint.x),
                                             fabs(touchPoint.y - self.startTouchPoint.y));
    CGFloat width = MIN(CGRectGetWidth(currentPixellateRect), self.imageContainerView.width / self.zoomScale - CGRectGetMinX(currentPixellateRect));
    CGFloat height = MIN(CGRectGetHeight(currentPixellateRect), self.imageContainerView.height / self.zoomScale - CGRectGetMinY(currentPixellateRect));
    currentPixellateRect.size = CGSizeMake(width, height);
    
    NSLog(@"currentPixellateRect: %@", NSStringFromCGRect(currentPixellateRect));
    [self pastePixellateImageViewWithRect:currentPixellateRect];
    self.startTouch = nil;
    self.startTouchPoint = CGPointZero;
    self.pixellateDrawLayer.mask = NULL;
}

- (void) touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}

#pragma mark - private methods

- (void) generateSnapshot {
    CGSize snapshotSize = CGSizeMake(self.imageContainerView.size.width / self.zoomScale,
                                     self.imageContainerView.size.height / self.zoomScale);
    UIGraphicsBeginImageContextWithOptions(snapshotSize, self.imageContainerView.opaque, 0);
    [self.imageContainerView drawViewHierarchyInRect:self.imageContainerView.bounds afterScreenUpdates:YES];
    self.snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

- (void) generatePixellateImage {
    if (!self.pixellateDrawLayer) {
        self.pixellateDrawLayer = [CAShapeLayer layer];
        self.pixellateDrawLayer.frame = self.imageContainerView.bounds;
        self.pixellateDrawLayer.fillColor = [UIColor lightGrayColor].CGColor;
    }
    
    if (self.pixellateType == ScrawlToolBarPixellateTypeSmall && !self.smallRadiusPixellateImageLayer) {
        UIImage *image = [ScrawlPixellateUtil pixellateImageWithOriginImage:self.snapshotImage radius:10];
        self.smallRadiusPixellateImageLayer = [CALayer new];
        self.smallRadiusPixellateImageLayer.frame = self.imageContainerView.bounds;
        self.smallRadiusPixellateImageLayer.contents = (id) image.CGImage;
        [self.imageContainerView.layer addSublayer:self.smallRadiusPixellateImageLayer];
        [self.smallRadiusPixellateImageLayer bk_associateValue:image withKey:kPixellateLayerImageKey];
    }
    if (self.pixellateType == ScrawlToolBarPixellateTypeMiddle && !self.middleRadiusPixellateImageLayer) {
        UIImage *image = [ScrawlPixellateUtil pixellateImageWithOriginImage:self.snapshotImage radius:30];
        self.middleRadiusPixellateImageLayer = [CALayer new];
        self.middleRadiusPixellateImageLayer.frame = self.imageContainerView.bounds;
        self.middleRadiusPixellateImageLayer.contents = (id) image.CGImage;
        [self.middleRadiusPixellateImageLayer bk_associateValue:image withKey:kPixellateLayerImageKey];
    }
    if (self.pixellateType == ScrawlToolBarPixellateTypeLarge && !self.largeRadiusPixellateImageLayer) {
        UIImage *image = [ScrawlPixellateUtil pixellateImageWithOriginImage:self.snapshotImage radius:60];
        self.largeRadiusPixellateImageLayer = [CALayer new];
        self.largeRadiusPixellateImageLayer.frame = self.imageContainerView.bounds;
        self.largeRadiusPixellateImageLayer.contents = (id) image.CGImage;
        [self.largeRadiusPixellateImageLayer bk_associateValue:image withKey:kPixellateLayerImageKey];
    }
}

- (void) prepareForPixellateLayer {
    
}

- (void) pastePixellateImageViewWithRect:(CGRect)rect {
    UIImage *pixellateImage = nil;
    if (self.pixellateType == ScrawlToolBarPixellateTypeSmall) {
        pixellateImage = [self.smallRadiusPixellateImageLayer bk_associatedValueForKey:kPixellateLayerImageKey];
    } else if (self.pixellateType == ScrawlToolBarPixellateTypeMiddle) {
        pixellateImage = [self.middleRadiusPixellateImageLayer bk_associatedValueForKey:kPixellateLayerImageKey];
    } else {
        pixellateImage = [self.largeRadiusPixellateImageLayer bk_associatedValueForKey:kPixellateLayerImageKey];
    }
//    CGFloat enlargeScale = image.size.width * image.scale / CGRectGetWidth(rect);
    
//    CGRect pixellateImageRect = CGRectMake(CGRectGetMinX(rect) * enlargeScale,
//                                           CGRectGetMinY(rect) * enlargeScale,
//                                           CGRectGetWidth(rect) * enlargeScale,
//                                           CGRectGetHeight(rect) * enlargeScale);
    CGFloat enlargeScale = pixellateImage.size.width * pixellateImage.scale / (self.imageContainerView.width / self.zoomScale);
    CGRect pixellateRect = CGRectMake(CGRectGetMinX(rect) * enlargeScale,
                                      CGRectGetMinY(rect) * enlargeScale,
                                      CGRectGetWidth(rect) * enlargeScale,
                                      CGRectGetHeight(rect) * enlargeScale);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(pixellateImage.CGImage, pixellateRect);
    UIImage *pixellateRectImage = [UIImage imageWithCGImage:imageRef scale:pixellateImage.scale orientation:pixellateImage.imageOrientation];
    CGImageRelease(imageRef);
    
    UIImageView *pixellateRectImageView = [[UIImageView alloc] initWithImage:pixellateRectImage];
    pixellateRectImageView.frame = rect;
    [self.pixellateImageViews addObject:pixellateRectImageView];
    [self.imageContainerView addSubview:pixellateRectImageView];
    
    [self setNeedsLayout];
}

- (void) saveImage:(UIImage *)image {
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
}

- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSString *message = @"保存图片失败";
    if (!error) {
        message = @"成功保存到相册";
    }
    NSLog(@"saved msg: %@", message);
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
