//
//  ImagePickerItemCollectionViewCell.m
//  ImageTailor
//
//  Created by dl on 2018/4/29.
//  Copyright © 2018年 dl. All rights reserved.
//

#import "ImagePickerItemCollectionViewCell.h"

@interface ImagePickerItemCollectionViewCell()
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UIView *selectedMaskView;
@property (nonatomic, strong) UILabel *selectedIndexLabel;

@property (nonatomic, strong) PHAsset *asset;
@end

@implementation ImagePickerItemCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.imgView];
        [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
        [self.contentView addSubview:self.selectedMaskView];
        [self.selectedMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
        [self.selectedMaskView addSubview:self.selectedIndexLabel];
        [self.selectedIndexLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.selectedMaskView);
        }];
        
        @weakify(self)
        [self.contentView bk_whenTapped:^{
            @strongify(self)
            [[CurrentSelectedAssetsManager sharedInstance] toggleAsset:self.asset];
        }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshSelectStatus) name:kNotiImagePickerItemSelectStatusChange object:nil];
    }
    return self;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) bind:(UIImage *)image asset:(PHAsset *)asset {
    self.asset = asset;
    self.imgView.image = image;
    [self refreshSelectStatus];
}

- (void) refreshSelectStatus {
    NSInteger selectedIndex = [[CurrentSelectedAssetsManager sharedInstance] indexForAsset:self.asset];
    self.selectedMaskView.hidden = selectedIndex == NSNotFound;
    if (selectedIndex != NSNotFound) {
        self.selectedIndexLabel.text = [NSString stringWithFormat:@"%@", @(selectedIndex + 1)];
    }
}

LazyPropertyWithInit(UIImageView, imgView, {
    _imgView.contentMode = UIViewContentModeScaleAspectFill;
    _imgView.clipsToBounds = YES;
})
LazyPropertyWithInit(UIView, selectedMaskView, {
    _selectedMaskView.backgroundColor = [UIColor hex_colorWithHex:0x0036FF alpha:0.6f];
    
})
LazyPropertyWithInit(UILabel, selectedIndexLabel, {
    _selectedIndexLabel.font = [UIFont boldSystemFontOfSize:44];
    _selectedIndexLabel.textColor = [UIColor whiteColor];
})

@end
