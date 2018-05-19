//
//  ImagePickerItemSectionController.m
//  ImageTailor
//
//  Created by dl on 2018/4/29.
//  Copyright © 2018年 dl. All rights reserved.
//

#import "ImagePickerItemSectionController.h"
#import "ImagePickerItemCollectionViewCell.h"

@interface ImagePickerItemSectionController()
@property (nonatomic, strong) PHAsset *asset;
@end

@implementation ImagePickerItemSectionController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.inset = UIEdgeInsetsMake(0.5f, 0.5f, 0.5f, 0.5f);
    }
    return self;
}

- (NSInteger)numberOfItems {
    return 1;
}

- (CGSize)sizeForItemAtIndex:(NSInteger)index {
    CGFloat containerWidth = self.collectionContext.insetContainerSize.width;
    CGFloat itemWidth = (containerWidth - 2.f) / 4.f;
    CGFloat scale = UIScreen.mainScreen.scale;
    return CGSizeMake(floorf(itemWidth * scale) / scale, itemWidth);
}

- (__kindof UICollectionViewCell *)cellForItemAtIndex:(NSInteger)index {
    ImagePickerItemCollectionViewCell *cell = [self.collectionContext dequeueReusableCellOfClass:[ImagePickerItemCollectionViewCell class]
                                                                            forSectionController:self atIndex:index];

    
    CGSize cellSize = [(IGListAdapter *)self.collectionContext sizeForItemAtIndexPath:[NSIndexPath indexPathForItem:self.section inSection:index]];
    CGFloat scale = UIScreen.mainScreen.scale;
    CGSize targetSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale);
    
    NSInteger tag = cell.tag + 1;
    cell.tag = tag;
    
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    options.resizeMode = PHImageRequestOptionsResizeModeExact;
    @weakify(self)
    [[PHCachingImageManager sharedInstance] requestImageForAsset:self.asset targetSize:targetSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage *result, NSDictionary *info) {
        @strongify(self)
        if (cell.tag == tag) {
            [cell bind:result asset:self.asset];
        }
    }];
    return cell;
}

- (void)didUpdateToObject:(PHAsset *)asset {
    self.asset = asset;
}

@end
