//
//  BaseViewController.m
//  ImageTailor
//
//  Created by dl on 2018/4/29.
//  Copyright © 2018年 dl. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.extendedLayoutIncludesOpaqueBars = YES;
//    self.automaticallyAdjustsScrollViewInsets = YES;
//    self.modalPresentationCapturesStatusBarAppearance = NO;
}

- (BOOL)isHotSpotOn {
    return [UIApplication sharedApplication].statusBarFrame.size.height > 20;
}

- (UIEdgeInsets)mergedSafeAreaInsets {
    if (![self isViewLoaded]) {
        goto DEFAULT;
    }
    
    if (UIScreen.mainScreen.nativeBounds.size.height == 2001) {
        // 未适配的 iPhone X
        goto DEFAULT;
    }
    
#ifdef __IPHONE_11_0
    if (@available(iOS 11.0, *)) {
        return self.view.safeAreaInsets;
    }
#endif
    
DEFAULT: {
    CGFloat nativeNavigationBarHeight = self.navigationController.navigationBarHidden ? 0 : self.navigationController.navigationBar.frame.size.height;
    CGFloat statusBarHeight = UIApplication.sharedApplication.statusBarHidden ? 0 : UIApplication.sharedApplication.statusBarFrame.size.height;
    return UIEdgeInsetsMake(nativeNavigationBarHeight + statusBarHeight, 0, 0, 0);
}
}

@end
