//
//  ImagePickerBottomStatusCollectionViewCell.m
//  ImageTailor
//
//  Created by dl on 2018/4/29.
//  Copyright © 2018年 dl. All rights reserved.
//

#import "ImagePickerBottomStatusCollectionViewCell.h"

@interface ImagePickerBottomStatusCollectionViewCell()
@property (nonatomic, strong) UILabel *txtLabel;
@end

@implementation ImagePickerBottomStatusCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.txtLabel];
        [self.txtLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.contentView);
        }];
    }
    return self;
}

- (void) bindViewModel:(NSString *)viewModel {
    self.txtLabel.text = viewModel;
}

LazyPropertyWithInit(UILabel, txtLabel, {
    _txtLabel.textAlignment = NSTextAlignmentCenter;
    _txtLabel.textColor = [UIColor hex_colorWithHex:0x666666];
    _txtLabel.font = [UIFont systemFontOfSize:15];
})

@end
