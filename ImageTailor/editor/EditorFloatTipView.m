//
//  EditorFloatTipView.m
//  ImageTailor
//
//  Created by dl on 2018/5/24.
//  Copyright © 2018年 dl. All rights reserved.
//

#import "EditorFloatTipView.h"

@implementation EditorFloatTipView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.image = [UIImage imageNamed:@"img_info_bg"];
        UILabel *tipLabel = [[UILabel alloc] init];
        tipLabel.text = @"点击切换编辑工具";
        if (@available(iOS 9.0, *)) {
            tipLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
        } else {
            tipLabel.font = [UIFont boldSystemFontOfSize:12];
        }
        tipLabel.textColor = [UIColor whiteColor];
        tipLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:tipLabel];
        
        [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@16.f);
            make.right.equalTo(@-16.f);
            make.centerY.equalTo(self);
        }];
    }
    return self;
}

@end
