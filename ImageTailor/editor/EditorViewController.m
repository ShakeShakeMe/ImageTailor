//
//  EditorViewController.m
//  ImageTailor
//
//  Created by dl on 2018/5/19.
//  Copyright © 2018年 dl. All rights reserved.
//

#import "EditorViewController.h"
#import "EditorCloseAndSwitchControl.h"
#import "EditorFloatTipView.h"
#import "EditorZoomingScrollView.h"
#import "EditorBottomToolbarControl.h"
#import "WatermarkEditorViewController.h"
#import "SaveToPhotoViewController.h"
#import "SavePhotoSuccessViewController.h"

static NSString *WatermarkTextKey = @"WatermarkTextKey";
static NSString *WatermarkTextPrefixKey = @"WatermarkTextPrefixKey";
static NSString *WatermarkPositionTypeKey = @"WatermarkPositionTypeKey";

@interface EditorViewController () <EditorCloseAndSwitchControlDelegate, EditorBottomToolbarControlDelegate, EditorBottomToolbarFloatViewDelegate, WatermarkEditorViewControllerDelegate, SaveToPhotoViewControllerDelegate>
@property (nonatomic, strong) EditorCloseAndSwitchControl *swithControl;
@property (nonatomic, strong) EditorFloatTipView *floatTipView;
@property (nonatomic, strong) UIButton *saveBtn;
@property (nonatomic, strong) EditorBottomToolbarControl *toolBarControl;
@property (nonatomic, strong) EditorZoomingScrollView *zoomingScrollView;

@property (nonatomic, strong) UIView *floatView;
@property (nonatomic, strong) EditorBottomToolbarPixellateFloatView *pixellateFloatView;
@property (nonatomic, strong) EditorBottomToolbarSpacelineFloatView *spacelineFloatView;
@property (nonatomic, strong) EditorBottomToolbarWatermarkFloatView *watermarkFloatView;
@property (nonatomic, strong) EditorBottomToolbarPhoneBoundsFLoatView *phoneBoundsFloatView;

@property (nonatomic, copy) NSString *watermarkText;
@property (nonatomic, assign) EditorToolBarWatermarkType watermarkType;;
@property (nonatomic, assign) EditorWatermarkPrefixType watermarkPrefixType;
@end

@implementation EditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor hex_colorWithHex:0xD2E1E8];
    self.fd_prefersNavigationBarHidden= YES;
    self.fd_interactivePopDisabled = YES;
    
    [self.view addSubview:self.zoomingScrollView];
    [self.view addSubview:self.swithControl];
    [self.view addSubview:self.floatTipView];
    [self.view addSubview:self.saveBtn];
    [self.view addSubview:self.toolBarControl];
    [self.view addSubview:self.floatView];
    
    [self.floatTipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.swithControl.mas_right).offset(-16.f);
        make.centerY.equalTo(self.swithControl);
    }];
    
    self.pixellateFloatView.delegate = self;
    self.spacelineFloatView.delegate = self;
    self.watermarkFloatView.delegate = self;
    self.phoneBoundsFloatView.delegate = self;
    
    [self.zoomingScrollView refreshWithAssetModels:self.assetModels tileDirection:self.tileDirection];
    [self.toolBarControl selectBtnType:EditorToolbarBtnTypeClipNormal selected:YES];
    
    self.watermarkText = [[NSUserDefaults standardUserDefaults] stringForKey:WatermarkTextKey];
    self.watermarkPrefixType = [[[NSUserDefaults standardUserDefaults] valueForKey:WatermarkTextPrefixKey] integerValue];
    self.watermarkType = [[[NSUserDefaults standardUserDefaults] valueForKey:WatermarkPositionTypeKey] integerValue];
    
    if (self.watermarkText.length == 0) {
        self.watermarkText = @"拼图大师Pro";
        self.watermarkPrefixType = EditorWatermarkPrefixTypeNormal;
        self.watermarkType = EditorToolBarWatermarkTypeRight;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshPixellateWithdraState:)
                                                 name:@"kPixellateStateChangeNotiName"
                                               object:nil];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL) prefersStatusBarHidden {
    return YES;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BOOL floatTipViewHasShown = [[NSUserDefaults standardUserDefaults] boolForKey:@"kFloatTipViewHasShown"];
    if (!floatTipViewHasShown) {
        self.floatTipView.alpha = 1.f;
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kFloatTipViewHasShown"];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3f animations:^{
                self.floatTipView.alpha = 0.f;
            }];
        });
    }
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

- (BOOL) shouldAskSwitchToNormal {
    return [self.zoomingScrollView hasChanged];
}

- (void) editorSwitchToState:(BOOL)normalState {
    if (normalState) {
        [self.toolBarControl switchToClip];
        [self.toolBarControl selectBtnType:EditorToolbarBtnTypeClipNormal selected:YES];
        self.floatView.hidden = YES;
        [self resetAllTailorState];
        [self.view setNeedsLayout];
    } else {
        [self.toolBarControl switchToTool];
        [self.toolBarControl selectBtnType:EditorToolbarBtnTypeClipNormal selected:NO];
        [self.zoomingScrollView pixellateClear];
    }
}

- (void) resetAllTailorState {
    [self.zoomingScrollView abandonAllTailorChanges];
    [self.pixellateFloatView reset];
    [self.spacelineFloatView reset];
    [self.watermarkFloatView reset];
    [self.phoneBoundsFloatView reset];
}

#pragma mark - EditorBottomToolbarControlDelegate
- (void) toolbarControl:(EditorBottomToolbarControl *)toolbarControl
               clickBtn:(EditorToolbarBtnType)btnType
               selected:(BOOL)selected {
    
    [self.zoomingScrollView pixellateEnd];
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
            [self.zoomingScrollView pixellateEnd];
        }
            break;
        case EditorToolbarBtnTypeToolWatermark:
        {
            [self showWatermarkFloatView:selected];
            [self.zoomingScrollView pixellateEnd];
        }
            break;
        case EditorToolbarBtnTypeToolPhoneBounds:
        {
            [self showPhoneBoundsFloatView:selected];
            [self.zoomingScrollView pixellateEnd];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - WatermarkEditorViewControllerDelegate
- (void) didChangeWatermarkText:(NSString *)text prefixType:(EditorWatermarkPrefixType)prefixType {
    self.watermarkText = text;
    self.watermarkPrefixType = prefixType;
    [self watermarkWithType:self.watermarkType];
}

#pragma mark - EditorBottomToolbarFloatViewDelegate
- (void)pixellateWithType:(ScrawlToolBarPixellateType)pixellateType {
    [self.zoomingScrollView pixellateWithType:pixellateType];
}

- (void)pixellateWithdraw {
    [self.zoomingScrollView pixellateWithdraw];
}

- (void) spacelineWithType:(EditorToolBarSpacelineType)spacelineType {
    [self.zoomingScrollView showSpacelineWithType:spacelineType];
}

- (void) watermarkWithType:(EditorToolBarWatermarkType)watermarkType {
    if (watermarkType == EditorToolBarWatermarkTypeNone) {
        [self.zoomingScrollView hideWatermark];
    } else {
        NSDictionary *watermarkPrefixMap = @{
            @(EditorWatermarkPrefixTypeNormal): @"©",
            @(EditorWatermarkPrefixTypeOther): @"@ ",
            @(EditorToolBarWatermarkTypeNone): @""
        };
        NSString *text = [NSString stringWithFormat:@"%@ %@", watermarkPrefixMap[@(self.watermarkPrefixType)], self.watermarkText];
        [self.zoomingScrollView showWatermarkWithType:watermarkType text:text];
    }
}

- (void) watermarkEditWord {
    WatermarkEditorViewController *vc = [[WatermarkEditorViewController alloc] init];
    vc.text = self.watermarkText;
    vc.prefixType = self.watermarkPrefixType;
    vc.delegate = self;
    [self.navigationController presentViewController:vc animated:NO completion:nil];
}

- (void) phoneBoundsWithType:(EditorToolBarPhoneBoundsType)phoneBoundsType {
    [self.zoomingScrollView showPhoneBoundsWithType:phoneBoundsType];
}

#pragma mark - SaveToPhotoViewControllerDelegate
- (void) saveToPhoto:(BOOL)success asset:(PHAsset *)asset {
    SavePhotoSuccessViewController *vc = [[SavePhotoSuccessViewController alloc] init];
    vc.asset = asset;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - other methods
- (void) showPixellateFloatView:(BOOL)show {
    self.floatView.hidden = !show;
    [self.floatView removeAllSubviews];
    if (show) {
        [self addSubFloatView:self.pixellateFloatView];
        [self.zoomingScrollView pixellateWithType:[self.pixellateFloatView currentPixellateType]];
    }
    [self.view setNeedsLayout];
}

- (void) refreshPixellateWithdraState:(NSNotification *)noti {
    [self.pixellateFloatView setWithdrawEnable:[[noti object] boolValue]];
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
- (void) setWatermarkText:(NSString *)watermarkText {
    _watermarkText = watermarkText;
    [[NSUserDefaults standardUserDefaults] setValue:watermarkText forKey:WatermarkTextKey];
}

- (void) setWatermarkPrefixType:(EditorWatermarkPrefixType)watermarkPrefixType {
    _watermarkPrefixType = watermarkPrefixType;
    [[NSUserDefaults standardUserDefaults] setValue:@(watermarkPrefixType) forKey:WatermarkTextPrefixKey];
}

- (void) setWatermarkType:(EditorToolBarWatermarkType)watermarkType {
    _watermarkType = watermarkType;
    [[NSUserDefaults standardUserDefaults] setValue:@(watermarkType) forKey:WatermarkPositionTypeKey];
}

LazyPropertyWithInit(EditorCloseAndSwitchControl, swithControl, {
    _swithControl.delegate = self;
})
LazyPropertyWithInit(EditorFloatTipView, floatTipView, {
    _floatTipView.alpha = 0.f;
})
LazyPropertyWithInit(UIButton, saveBtn, {
    [_saveBtn setImage:[UIImage imageNamed:@"btn_navbar_save_n"] forState:UIControlStateNormal];
    [_saveBtn setImage:[UIImage imageNamed:@"btn_navbar_save_n"] forState:UIControlStateHighlighted];
    @weakify(self)
    [_saveBtn bk_addEventHandler:^(id sender) {
        @strongify(self)
        SaveToPhotoViewController *vc = [[SaveToPhotoViewController alloc] init];
        vc.delegate = self;
        vc.tileDirection = self.zoomingScrollView.tileDirection;
        vc.assetModels = self.zoomingScrollView.assetModels;
        vc.pixellateImageViews = self.zoomingScrollView.pixellateContext.pixellateImageViews;
        vc.watermarkLabel = self.zoomingScrollView.watermarkContext.watermarkLabel;
        vc.lineViews = [self.zoomingScrollView.spacelineContext allVisableLineViews];
        vc.phoneBoundsImageView = self.zoomingScrollView.phoneBoundsContext.phoneBoundsImageView;
        vc.imageViewsUnionRect = self.zoomingScrollView.imageViewsUnionRect;
        [self.navigationController presentViewController:vc animated:NO completion:nil];
    } forControlEvents:UIControlEventTouchUpInside];
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
