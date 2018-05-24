//
//  PreviewLargeImageViewController.m
//  ImageTailor
//
//  Created by dl on 2018/5/25.
//  Copyright © 2018年 dl. All rights reserved.
//

#import "PreviewLargeImageViewController.h"

@interface PreviewLargeImageViewController () <UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation PreviewLargeImageViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.imageView];
    
    [self loadImage];
}

- (void) loadImage {
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    
    CGSize originImageSize = CGSizeMake(self.asset.pixelWidth, self.asset.pixelHeight);
    CGFloat smallSideSize = MIN(originImageSize.width, originImageSize.height);
    CGFloat reduceScale = [UIScreen mainScreen].bounds.size.width * [UIScreen mainScreen].scale / smallSideSize;
    CGSize targetSize = CGSizeMake(self.asset.pixelWidth * reduceScale, self.asset.pixelHeight * reduceScale);
    [[PHCachingImageManager sharedInstance] requestImageForAsset:self.asset targetSize:targetSize contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        self.imageView.image = result;
        
        CGSize imageSize = CGSizeMake(result.size.width, result.size.height);
        BOOL isVertical = imageSize.width < imageSize.height;
        CGSize imageViewSize = CGSizeZero;
        if (isVertical) {
            imageViewSize.width = self.view.width;
            imageViewSize.height = imageSize.height * imageSize.width / imageViewSize.width;
        } else {
            imageViewSize.height = self.view.height * 0.6f;
            imageViewSize.width = imageSize.width * imageSize.height / imageViewSize.height;
        }
        
        self.imageView.size = imageViewSize;
        if (isVertical) {
            self.imageView.centerX = self.view.centerX;
        } else {
            self.imageView.centerY = self.view.centerY;
        }
        self.scrollView.contentSize = imageViewSize;
    }];
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.scrollView.frame = self.view.bounds;
    
    CGSize boundsSize = self.view.bounds.size;
    CGRect frameToCenter = (CGRect){CGPointZero, self.imageView.size};
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
    self.imageView.frame = frameToCenter;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.view.alpha = 0.f;
    [UIView animateWithDuration:0.3f animations:^{
        self.view.alpha = 1.f;
    }];
}

- (void)dismissAnimating {
    [UIView animateWithDuration:0.3f animations:^{
        self.view.alpha = 0.f;
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

#pragma mark - getters
LazyPropertyWithInit(UIScrollView, scrollView, {
    _scrollView.delegate = self;
    _scrollView.minimumZoomScale = TailorMinZoomingScale;
    _scrollView.maximumZoomScale = TailorMaxZoomingScale;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
})
LazyPropertyWithInit(UIImageView, imageView, {
    _imageView.userInteractionEnabled = YES;
    @weakify(self)
    [_imageView bk_whenTapped:^{
        @strongify(self)
        [self dismissAnimating];
    }];
})
@end
