//
//  TailorViewController.m
//  ImageTailor
//
//  Created by dl on 2018/4/30.
//  Copyright © 2018年 dl. All rights reserved.
//

#import "TailorViewController.h"
#import "TailorZoomingScrollView.h"
#import "TailorBottomToolBarControl.h"
#import "ScrawlViewController.h"

@interface TailorViewController ()
@property (nonatomic, strong) TailorBottomToolBarControl *bottomToolBarControl;
@property (nonatomic, strong) TailorZoomingScrollView *zoomingScrollView;
@end

@implementation TailorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"裁剪";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"去涂鸦" style:UIBarButtonItemStylePlain target:self action:@selector(goScrawl)];
    
    [self.view addSubview:self.bottomToolBarControl];
    [self.view addSubview:self.zoomingScrollView];
    
    [self.zoomingScrollView refreshWithAssetModels:self.assetModels tileDirection:self.tileDirection];
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.bottomToolBarControl.frame = CGRectMake(0.f, self.view.height - 44.f - self.mergedSafeAreaInsets.bottom, self.view.width, 44.f);
    self.zoomingScrollView.frame = CGRectMake(0.f,
                                              0.f,
                                              self.view.width,
                                              self.bottomToolBarControl.top);
}

#pragma mark - TailorBottomToolBarControlDelegate

#pragma mark - custom events
- (void) goScrawl {
//    UIImage *snapshotImage = [self.zoomingScrollView tailoredImagesSnapshot];
//    if (snapshotImage) {
////        UIImageWriteToSavedPhotosAlbum(snapshotImage, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
//        ScrawlViewController *scrawlVC = [[ScrawlViewController alloc] init];
//        scrawlVC.snapshot = snapshotImage;
//        scrawlVC.rects = [self.zoomingScrollView imageRectsOnSnapshot];
//        scrawlVC.zoomScale = self.zoomingScrollView.zoomScale;
//        scrawlVC.conentOffset = self.zoomingScrollView.contentOffset;
//        scrawlVC.tileDirection = self.zoomingScrollView.tileDirection;
//        [self.navigationController pushViewController:scrawlVC animated:YES];
//    }
    
    ScrawlViewController *scrawlVC = [[ScrawlViewController alloc] init];
    scrawlVC.assetModels = self.zoomingScrollView.assetModels;
    scrawlVC.zoomScale = self.zoomingScrollView.zoomScale;
    scrawlVC.conentOffset = self.zoomingScrollView.contentOffset;
    scrawlVC.tileDirection = self.zoomingScrollView.tileDirection;
    [self.navigationController pushViewController:scrawlVC animated:YES];
}

- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSString *message = @"保存图片失败";
    if (!error) {
        message = @"成功保存到相册";
    }
    NSLog(@"saved msg: %@", message);
}

#pragma mark - getters
LazyPropertyWithInit(TailorBottomToolBarControl, bottomToolBarControl, {
    _bottomToolBarControl.delegate = self.zoomingScrollView;
})
LazyPropertyWithInit(TailorZoomingScrollView, zoomingScrollView, {})
@end
