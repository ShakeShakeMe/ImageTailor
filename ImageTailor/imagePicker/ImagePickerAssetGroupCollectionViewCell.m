//
//  ImagePickerAssetGroupCollectionViewCell.m
//  ImageTailor
//
//  Created by dl on 2018/5/23.
//  Copyright © 2018年 dl. All rights reserved.
//

#import "ImagePickerAssetGroupCollectionViewCell.h"
#import "PhotoAssetsService.h"

@interface ImagePickerAssetGroupCollectionViewCell()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *cntLabel;
@end

@implementation ImagePickerAssetGroupCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.cntLabel];
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(60.f, 60.f));
            make.centerY.equalTo(self.contentView);
            make.left.equalTo(@10.f);
        }];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.imageView.mas_right).offset(16.f);
            make.centerY.equalTo(self.contentView);
            make.right.equalTo(@-70.f);
        }];
        [self.cntLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@-16.f);
            make.centerY.equalTo(self.contentView);
        }];
    }
    return self;
}

- (void) bindViewModel:(AssetsGroup *)viewModel {
    CGFloat scale = UIScreen.mainScreen.scale;
    CGSize targetSize = CGSizeMake(60.f * scale, 60.f * scale);
    
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    @weakify(self)
    [[PHCachingImageManager sharedInstance] requestImageForAsset:viewModel.asset targetSize:targetSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage *result, NSDictionary *info) {
        @strongify(self)
        self.imageView.image = result;
    }];
    self.titleLabel.text = viewModel.groupName;
    self.cntLabel.text = [NSString stringWithFormat:@"%@", @(viewModel.assetCount)];
}

LazyPropertyWithInit(UIImageView, imageView, {
    _imageView.clipsToBounds = YES;
    _imageView.layer.cornerRadius = 4.f;
})
LazyPropertyWithInit(UILabel, titleLabel, {
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.font = [UIFont systemFontOfSize:15];
})
LazyPropertyWithInit(UILabel, cntLabel, {
    _cntLabel.textColor = [UIColor hex_colorWithHex:0x98A2A6];
    _cntLabel.textAlignment = NSTextAlignmentRight;
    _cntLabel.font = [UIFont systemFontOfSize:13];
})

@end
