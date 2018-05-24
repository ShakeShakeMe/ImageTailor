//
//  SavePhotoSuccessViewController.m
//  ImageTailor
//
//  Created by dl on 2018/5/24.
//  Copyright © 2018年 dl. All rights reserved.
//

#import "SavePhotoSuccessViewController.h"

@interface SavePhotoSuccessViewController ()
@property (nonatomic, strong) UIButton *bottomBtn;
@property (nonatomic, strong) UIView *extraBottomView;
@end

@implementation SavePhotoSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@""] style:UIBarButtonItemStyleDone target:self action:@selector(navBack)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    [self.view addSubview:self.bottomBtn];
    [self.view addSubview:self.extraBottomView];
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.extraBottomView.frame = CGRectMake(0.f, self.view.height - self.mergedSafeAreaInsets.bottom, self.view.width, self.mergedSafeAreaInsets.bottom);
    self.bottomBtn.frame = CGRectMake(0.f, self.extraBottomView.top - 50.f, self.view.width, 50.f);
}

- (void) navBack {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - getters
LazyPropertyWithInit(UIButton, bottomBtn, {
    _bottomBtn.backgroundColor = [UIColor hex_colorWithHex:0x0036FF];
    [_bottomBtn setTitle:@"完成" forState:UIControlStateNormal];
    @weakify(self)
    [_bottomBtn bk_addEventHandler:^(id sender) {
        @strongify(self)
        [self navBack];
    } forControlEvents:UIControlEventTouchUpInside];
})
LazyPropertyWithInit(UIView, extraBottomView, {
    _extraBottomView.backgroundColor = self.bottomBtn.backgroundColor;
})

@end
