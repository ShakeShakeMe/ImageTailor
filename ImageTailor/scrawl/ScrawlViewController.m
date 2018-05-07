//
//  ScrawlViewController.m
//  ImageTailor
//
//  Created by dl on 2018/5/5.
//  Copyright © 2018年 dl. All rights reserved.
//

#import "ScrawlViewController.h"
#import "ScrawlZoomingScollView.h"
#import "ScrawlBottomToolBarControl.h"

@interface ScrawlViewController () <ScrawlBottomToolBarControlDelegate, ScrawlBottomToolBarFLoatViewDelegate>
@property (nonatomic, strong) ScrawlZoomingScollView *zoomingScrollView;
@property (nonatomic, strong) ScrawlBottomToolBarControl *toolBarControl;
@property (nonatomic, strong) ScrawlBottomToolBarFLoatView *toolBarFloatView;
@end

@implementation ScrawlViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"涂鸦";
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self.view addSubview:self.zoomingScrollView];
    [self.zoomingScrollView refreshWithAssetModels:self.assetModels
                                     tileDirection:self.tileDirection
                                  defaultZoomScale:self.zoomScale
                              defaultContentOffset:self.conentOffset];
    [self.view addSubview:self.toolBarControl];
    [self.view addSubview:self.toolBarFloatView];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.zoomingScrollView viewDidAppear];
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.toolBarControl.frame = CGRectMake(0.f, self.view.height - 44.f - self.mergedSafeAreaInsets.bottom, self.view.width, 44.f);
    self.toolBarFloatView.frame = CGRectMake(0.f, self.toolBarControl.top - 44.f, self.view.width, 44.f);
    
    CGFloat zoomingScrollViewHeight = (self.toolBarFloatView.alpha == 0.f ? self.toolBarControl.top : self.toolBarFloatView.top) - self.mergedSafeAreaInsets.top;
    self.zoomingScrollView.frame = CGRectMake(0.f,
                                              self.mergedSafeAreaInsets.top,
                                              self.view.width,
                                              zoomingScrollViewHeight);
}

#pragma mark - ScrawlBottomToolBarControlDelegate
- (void)toolBarControl:(ScrawlBottomToolBarControl *)toolBarControl didSelected:(BOOL)selected toolBarItem:(ScrawlToolBarItemType)itemType {
    switch (itemType) {
        case ScrawlToolBarItemTypePixellate:
            [self clickPixellateBtn:selected];
            break;
        case ScrawlToolBarItemTypeWatermark:
            [self clickWatermark:selected];
            break;
        case ScrawlToolBarItemTypeGuideLine:
            [self clickGuideLine:selected];
            break;
        case ScrawlToolBarItemTypePhoneBounds:
            [self clickPhoneBounds:selected];
            break;
        default:
            break;
    }
}

#pragma mark - ScrawlBottomToolBarFLoatViewDelegate
- (void)floatView:(ScrawlBottomToolBarFLoatView *)floatView
      toolBarItem:(ScrawlToolBarItemType)itemType
      didSelected:(BOOL)selected
          atIndex:(NSInteger)index {
    [self.zoomingScrollView endDoPixllate];
    switch (itemType) {
        case ScrawlToolBarItemTypePixellate:
        {
            if (index == 3) {
                [self.zoomingScrollView pixellateWithdraw];
            } else if (selected) {
                NSDictionary *pixellateActionMap = @{@0: @(ScrawlToolBarPixellateTypeLarge),
                                                     @1: @(ScrawlToolBarPixellateTypeMiddle),
                                                     @2: @(ScrawlToolBarPixellateTypeSmall)};
                [self.zoomingScrollView beginDoPixellateWithType:[pixellateActionMap[@(index)] integerValue]];
            }
        }
            break;
        case ScrawlToolBarItemTypeWatermark:
            
            break;
        case ScrawlToolBarItemTypeGuideLine:
            
            break;
        case ScrawlToolBarItemTypePhoneBounds:
            
            break;
        default:
            break;
    }
}

#pragma mark - action
- (void) clickPixellateBtn:(BOOL)selected {
    [self resetFloatView];
    if (selected) {
        self.toolBarFloatView.alpha = 1.f;
        self.toolBarFloatView.showVerticalLine = YES;
        self.toolBarFloatView.selectedIndex = 1;
        [self.toolBarFloatView refreshWithSelectedImages:@[@"", @"", @"", @""]
                                 unselectedImages:@[@"", @"", @"", @""]
                                           titles:@[@"大", @"中", @"小", @"撤销"]
                                                itemType:ScrawlToolBarItemTypePixellate];
        
        [self floatView:self.toolBarFloatView toolBarItem:ScrawlToolBarItemTypePixellate didSelected:YES atIndex:1];
    }
    [self.view setNeedsLayout];
}

- (void) clickWatermark:(BOOL)selected {
    [self resetFloatView];
    if (selected) {
        self.toolBarFloatView.alpha = 1.f;
        self.toolBarFloatView.showVerticalLine = YES;
        [self.toolBarFloatView refreshWithSelectedImages:@[@"", @"", @"", @"", @""]
                                 unselectedImages:@[@"", @"", @"", @"", @""]
                                           titles:@[@"关", @"左下", @"中下", @"右下", @"设置"]
                                                itemType:ScrawlToolBarItemTypeWatermark];
    }
    [self.view setNeedsLayout];
}

- (void) clickGuideLine:(BOOL)selected {
    [self resetFloatView];
    if (selected) {
        self.toolBarFloatView.alpha = 1.f;
        [self.toolBarFloatView refreshWithSelectedImages:@[@"", @"", @""]
                                 unselectedImages:@[@"", @"", @""]
                                           titles:@[@"关", @"space", @"bounds"]
                                                itemType:ScrawlToolBarItemTypeGuideLine];
    }
    [self.view setNeedsLayout];
}

- (void) clickPhoneBounds:(BOOL)selected {
    [self resetFloatView];
    if (selected) {
        self.toolBarFloatView.alpha = 1.f;
        [self.toolBarFloatView refreshWithSelectedImages:@[@"", @"", @"", @""]
                                 unselectedImages:@[@"", @"", @"", @""]
                                           titles:@[@"关", @"黑", @"银", @"金"]
                                                itemType:ScrawlToolBarItemTypePhoneBounds];
    }
    [self.view setNeedsLayout];
}

- (void) resetFloatView {
    self.toolBarFloatView.alpha = 0.f;
    self.toolBarFloatView.showVerticalLine = NO;
    self.toolBarFloatView.selectedIndex = 0;
}

#pragma mark - getters
LazyPropertyWithInit(ScrawlZoomingScollView, zoomingScrollView, {})
LazyPropertyWithInit(ScrawlBottomToolBarControl, toolBarControl, {
    _toolBarControl.delegate = self;
})
LazyPropertyWithInit(ScrawlBottomToolBarFLoatView, toolBarFloatView, {
    _toolBarFloatView.alpha = 0.f;
    _toolBarFloatView.delegate = self;
})
@end
