//
//  WatermarkEditorViewController.m
//  ImageTailor
//
//  Created by dl on 2018/5/18.
//  Copyright © 2018年 dl. All rights reserved.
//

#import "WatermarkEditorViewController.h"

@interface WatermarkEditorViewController ()
@property (nonatomic, strong) UIVisualEffectView *blurBgView;
@property (nonatomic, strong) UIButton *finishBtn;
@property (nonatomic, strong) UITextField *tf;

@property (nonatomic, assign) CGFloat keybordHeight;
@end

@implementation WatermarkEditorViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    self.blurBgView = [[UIVisualEffectView alloc] initWithEffect:blur];
    self.blurBgView.alpha = 0.f;
    [self.view addSubview:self.blurBgView];
    
    self.finishBtn = [[UIButton alloc] init];
    [self.finishBtn setTitle:@"完成" forState:UIControlStateNormal];
    [self.finishBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.finishBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.blurBgView.contentView addSubview:self.finishBtn];
    @weakify(self)
    [self.finishBtn bk_addEventHandler:^(id sender) {
        @strongify(self)
        [self dismissAnimating];
        [self.tf resignFirstResponder];
    } forControlEvents:UIControlEventTouchUpInside];
    
    self.tf = [[UITextField alloc] init];
    self.tf.textColor = [UIColor whiteColor];
    self.tf.font = [UIFont systemFontOfSize:20];
    self.tf.textAlignment = NSTextAlignmentCenter;
    self.tf.borderStyle = UITextBorderStyleNone;
    NSDictionary *attrs = @{NSFontAttributeName: [UIFont systemFontOfSize:20],
                            NSForegroundColorAttributeName: [UIColor hex_colorWithHex:0x999999]};
    self.tf.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"输入水印文案" attributes:attrs];
    self.tf.clearButtonMode = UITextFieldViewModeNever;
    self.tf.keyboardType = UIKeyboardTypeDefault;
    self.tf.returnKeyType = UIReturnKeyDone;
    [self.tf becomeFirstResponder];
    [self.blurBgView.contentView addSubview:self.tf];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keybordWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keybordWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [UIView animateWithDuration:0.3f animations:^{
        self.blurBgView.alpha = 1.f;
    }];
}

- (void)dismissAnimating {
    [UIView animateWithDuration:0.3f animations:^{
        self.blurBgView.alpha = 0.f;
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.blurBgView.frame = self.view.bounds;
    self.finishBtn.size = CGSizeMake(80.f, 40.f);
    self.finishBtn.right = self.blurBgView.right;
    self.finishBtn.top = self.mergedSafeAreaInsets.top;
    
    self.tf.size = CGSizeMake(self.view.width, 40.f);
    self.tf.left = self.view.left;
    self.tf.centerY = self.view.centerY - self.keybordHeight / 2.f;
}

- (void) keybordWillShow:(NSNotification *)noti {
    self.keybordHeight = [[noti.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    self.tf.centerY = self.view.centerY - self.keybordHeight / 2.f;
}

- (void) keybordWillHide:(NSNotification *)noti {
    self.keybordHeight = 0.f;
    self.tf.centerY = self.view.centerY;
}

@end
