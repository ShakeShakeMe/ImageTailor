//
//  EditorViewController.m
//  ImageTailor
//
//  Created by dl on 2018/5/19.
//  Copyright © 2018年 dl. All rights reserved.
//

#import "EditorViewController.h"
#import "EditorCloseAndSwitchControl.h"
#import "EditorZoomingScrollView.h"
#import "EditorBottomToolbarControl.h"
#import "WatermarkEditorViewController.h"

@interface EditorViewController () <EditorCloseAndSwitchControlDelegate, EditorBottomToolbarControlDelegate, EditorBottomToolbarFloatViewDelegate>
@property (nonatomic, strong) EditorCloseAndSwitchControl *swithControl;
@property (nonatomic, strong) UIButton *saveBtn;
@property (nonatomic, strong) EditorBottomToolbarControl *toolBarControl;
@property (nonatomic, strong) EditorZoomingScrollView *zoomingScrollView;

@property (nonatomic, strong) UIView *floatView;
@property (nonatomic, strong) EditorBottomToolbarPixellateFloatView *pixellateFloatView;
@property (nonatomic, strong) EditorBottomToolbarSpacelineFloatView *spacelineFloatView;
@property (nonatomic, strong) EditorBottomToolbarWatermarkFloatView *watermarkFloatView;
@property (nonatomic, strong) EditorBottomToolbarPhoneBoundsFLoatView *phoneBoundsFloatView;
@end

@implementation EditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor hex_colorWithHex:0xD2E1E8];
    self.fd_prefersNavigationBarHidden= YES;
    self.fd_interactivePopDisabled = YES;
    
    [self.view addSubview:self.zoomingScrollView];
    [self.view addSubview:self.swithControl];
    [self.view addSubview:self.saveBtn];
    [self.view addSubview:self.toolBarControl];
    [self.view addSubview:self.floatView];
    
    self.pixellateFloatView.delegate = self;
    self.spacelineFloatView.delegate = self;
    self.watermarkFloatView.delegate = self;
    self.phoneBoundsFloatView.delegate = self;
    
    [self.zoomingScrollView refreshWithAssetModels:self.assetModels tileDirection:self.tileDirection];
    [self.toolBarControl selectBtnType:EditorToolbarBtnTypeClipNormal selected:YES];
}

- (BOOL) prefersStatusBarHidden {
    return YES;
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.toolBarControl.frame = CGRectMake(0.f,
                                           self.view.height - 44.f - self.mergedSafeAreaInsets.bottom,
                                           self.view.width,
                                           44.f);
    self.floatView.frame = CGRectMake(0.f, self.toolBarControl.top - 44.f, self.view.width, 44.f);
    
    CGFloat zoomingScrollViewTop = self.floatView.hidden ? self.toolBarControl.top : self.floatView.top;
    self.zoomingScrollView.frame = CGRectMake(0.f, 0.f, self.view.width, zoomingScrollViewTop);
    self.swithControl.frame = CGRectMake(12.f, 12.f + self.mergedSafeAreaInsets.top, 128.f, 40.f);
    self.saveBtn.size = CGSizeMake(50.f, 50.f);
    self.saveBtn.centerY = self.swithControl.centerY;
    self.saveBtn.right = self.view.right - 7.f;
}

#pragma mark - EditorCloseAndSwitchControlDelegate
- (void) editorClose {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) editorSwitchToState:(BOOL)normalState {
    if (normalState) {
        [self.toolBarControl switchToClip];
        [self.toolBarControl selectBtnType:EditorToolbarBtnTypeClipNormal selected:YES];
        self.floatView.hidden = YES;
        [self.view setNeedsLayout];
    } else {
        [self.toolBarControl switchToTool];
        [self.toolBarControl selectBtnType:EditorToolbarBtnTypeClipNormal selected:NO];
    }
}

#pragma mark - EditorBottomToolbarControlDelegate
- (void) toolbarControl:(EditorBottomToolbarControl *)toolbarControl
               clickBtn:(EditorToolbarBtnType)btnType
               selected:(BOOL)selected {
    switch (btnType) {
        case EditorToolbarBtnTypeClipNormal:
        {
            [self.zoomingScrollView clipWithState:(selected ? TailorToolActionClipStateNormal : TailorToolActionClipStateNone)];
        }
            break;
        case EditorToolbarBtnTypeClipBounds:
        {
            [self.zoomingScrollView clipWithState:(selected ? TailorToolActionClipStateBounds : TailorToolActionClipStateNone)];
        }
            break;
        case EditorToolbarBtnTypeToolPixellate:
        {
            [self showPixellateFloatView:selected];
        }
            break;
        case EditorToolbarBtnTypeToolSpaceline:
        {
            [self showSpacelineFloatView:selected];
        }
            break;
        case EditorToolbarBtnTypeToolWatermark:
        {
            [self showWatermarkFloatView:selected];
        }
            break;
        case EditorToolbarBtnTypeToolPhoneBounds:
        {
            [self showPhoneBoundsFloatView:selected];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - EditorBottomToolbarFloatViewDelegate
- (void)pixellateWithType:(ScrawlToolBarPixellateType)pixellateType {
    [self.zoomingScrollView pixellateWithType:pixellateType];
}

- (void)pixellateWithdraw {
    [self.zoomingScrollView pixellateWithdraw];
}

- (void) spacelineWithType:(EditorToolBarSpacelineType)spacelineType {
    
}

- (void) watermarkWithType:(EditorToolBarWatermarkType)watermarkType {
    
}

- (void) watermarkEditWord {
    WatermarkEditorViewController *vc = [[WatermarkEditorViewController alloc] init];
    [self.navigationController presentViewController:vc animated:NO completion:nil];
}

- (void) phoneBoundsWithType:(EditorToolBarPhoneBoundsType)phoneBoundsType {
    
}

#pragma mark - other methods
- (void) showPixellateFloatView:(BOOL)show {
    self.floatView.hidden = !show;
    [self.floatView removeAllSubviews];
    if (show) {
        [self addSubFloatView:self.pixellateFloatView];
    }
    [self.view setNeedsLayout];
}

- (void) showSpacelineFloatView:(BOOL)show {
    self.floatView.hidden = !show;
    [self.floatView removeAllSubviews];
    if (show) {
        [self addSubFloatView:self.spacelineFloatView];
    }
    [self.view setNeedsLayout];
}

- (void) showWatermarkFloatView:(BOOL)show {
    self.floatView.hidden = !show;
    [self.floatView removeAllSubviews];
    if (show) {
        [self addSubFloatView:self.watermarkFloatView];
    }
    [self.view setNeedsLayout];
}

- (void) showPhoneBoundsFloatView:(BOOL)show {
    self.floatView.hidden = !show;
    [self.floatView removeAllSubviews];
    if (show) {
        [self addSubFloatView:self.phoneBoundsFloatView];
    }
    [self.view setNeedsLayout];
}

- (void) addSubFloatView:(UIView *)subFloatView {
    [self.floatView addSubview:subFloatView];
    [subFloatView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.floatView);
    }];
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [UIColor hex_colorWithHex:0x000000 alpha:0.1f];
    [self.floatView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.floatView);
        make.height.equalTo(@0.5f);
    }];
}

#pragma mark - getters
LazyPropertyWithInit(EditorCloseAndSwitchControl, swithControl, {
    _swithControl.delegate = self;
})
LazyPropertyWithInit(UIButton, saveBtn, {
    [_saveBtn setImage:[UIImage imageNamed:@"btn_navbar_save_n"] forState:UIControlStateNormal];
})
LazyPropertyWithInit(EditorBottomToolbarControl, toolBarControl, {
    _toolBarControl.delegate = self;
})
LazyPropertyWithInit(EditorZoomingScrollView, zoomingScrollView, {})
LazyPropertyWithInit(UIView, floatView, {
    _floatView.backgroundColor = [UIColor whiteColor];
    _floatView.hidden = YES;
})
LazyProperty(EditorBottomToolbarPixellateFloatView, pixellateFloatView)
LazyProperty(EditorBottomToolbarSpacelineFloatView, spacelineFloatView)
LazyProperty(EditorBottomToolbarWatermarkFloatView, watermarkFloatView)
LazyProperty(EditorBottomToolbarPhoneBoundsFLoatView, phoneBoundsFloatView)

@end
