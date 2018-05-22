//
//  ImagePickerCatalogView.m
//  ImageTailor
//
//  Created by dl on 2018/5/22.
//  Copyright © 2018年 dl. All rights reserved.
//

#import "ImagePickerCatalogView.h"
#import "ImagePickerAssetGroupCollectionViewCell.h"

@interface ImagePickerCatalogView() <IGListAdapterDataSource, IGListSingleSectionControllerDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) IGListAdapter *adapter;

@end

@implementation ImagePickerCatalogView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.adapter = [[IGListAdapter alloc] initWithUpdater:[IGListAdapterUpdater new] viewController:nil];
        self.adapter.dataSource = self;
        self.adapter.collectionView = self.collectionView;
        
        [self addSubview:self.collectionView];
    }
    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    self.collectionView.frame = self.bounds;
}

- (void) forceReload {
    [self.adapter reloadDataWithCompletion:nil];
}

#pragma mark - IGListAdapterDataSource
- (NSArray<id <IGListDiffable>> *)objectsForListAdapter:(IGListAdapter *)listAdapter {
    return [PhotoAssetsService sharedInstance].assetsGroupsArray;
}

- (IGListSectionController *)listAdapter:(IGListAdapter *)listAdapter
              sectionControllerForObject:(id)object {
    IGListSingleSectionController *sc = [[IGListSingleSectionController alloc] initWithCellClass:[ImagePickerAssetGroupCollectionViewCell class] configureBlock:^(AssetsGroup *item, __kindof ImagePickerAssetGroupCollectionViewCell * _Nonnull cell) {
        [cell bindViewModel:item];
        BOOL selected = (self.currentAssetsGroup == item);
        cell.contentView.backgroundColor = selected ? [UIColor hex_colorWithHex:0xebf0f3] : [UIColor whiteColor];
    } sizeBlock:^CGSize(NSString *item, id<IGListCollectionContext>  _Nullable collectionContext) {
        return CGSizeMake(collectionContext.insetContainerSize.width, 80.f);
    }];
    sc.selectionDelegate = self;
    return sc;
}

- (nullable UIView *)emptyViewForListAdapter:(IGListAdapter *)listAdapter {
    return nil;
}

#pragma mark - IGListSingleSectionControllerDelegate
- (void)didSelectSectionController:(IGListSingleSectionController *)sectionController
                        withObject:(id)object {
    if ([self.delegate respondsToSelector:@selector(didSelectedAssetGroup:)]) {
        [self.delegate didSelectedAssetGroup:object];
    }
}

#pragma mark -getters
- (UICollectionView *) collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[IGListCollectionViewLayout alloc] initWithStickyHeaders:NO topContentInset:0 stretchToEdge:NO]];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.alwaysBounceVertical = YES;
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _collectionView;
}

@end
