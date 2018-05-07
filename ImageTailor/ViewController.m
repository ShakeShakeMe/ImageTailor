//
//  ViewController.m
//  ImageTailor
//
//  Created by dl on 2018/4/29.
//  Copyright © 2018年 dl. All rights reserved.
//

#import "ViewController.h"
#import "ImagePickerItemSectionController.h"
#include "ImagePickerBottomStatusCollectionViewCell.h"
#import "ImagePickerBottomToolBarView.h"
#import "TailorViewController.h"
#import "TailorAssetModel.h"

@interface ViewController () <IGListAdapterDataSource, UIScrollViewDelegate, ImagePickerBottomToolBarViewDelegate, PHPhotoLibraryChangeObserver>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) IGListAdapter *adapter;
@property (nonatomic, strong) ImagePickerBottomToolBarView *toolBarView;

@property (nonatomic, strong) PHFetchResult *allPhotoAssetFetchResult;
@property (nonatomic, strong) NSString *imagePickerBottomStatusDesc;

@property (nonatomic, strong) UIButton *floatGoToBottomBtn;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"所有照片";
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.toolBarView];
    [self.view addSubview:self.floatGoToBottomBtn];
    
    self.adapter = [[IGListAdapter alloc] initWithUpdater:[IGListAdapterUpdater new] viewController:self];
    self.adapter.dataSource = self;
    self.adapter.collectionView = self.collectionView;
    self.adapter.scrollViewDelegate = self;
    
    [self initPhotoAsset];
    [self refreshToolBarView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshToolBarView)
                                                 name:kNotiImagePickerItemSelectStatusChange
                                               object:nil];
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.toolBarView.frame = CGRectMake(0.f, self.view.height - self.mergedSafeAreaInsets.bottom - 44.f, self.view.width, 44.f);
    self.collectionView.frame = CGRectMake(0, 0.f, self.view.width, self.view.height);
    UIEdgeInsets inset = self.collectionView.contentInset;
    self.collectionView.contentInset = UIEdgeInsetsMake(inset.top, inset.left, self.mergedSafeAreaInsets.bottom, inset.right);
    self.floatGoToBottomBtn.size = CGSizeMake(44.f, 44.f);
    self.floatGoToBottomBtn.centerX = self.view.centerX;
    self.floatGoToBottomBtn.bottom = self.toolBarView.top - 44.f;
}

- (void) initPhotoAsset {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (status) {
                case PHAuthorizationStatusAuthorized:
                {
                    [self fetchPhotoAsset];
                    break;
                }
                default:
                {
                    [self showAccessDenied];
                    break;
                }
            }
        });
    }];
}

- (void) fetchPhotoAsset {
    PHFetchOptions *fetchOptions = [PHFetchOptions new];
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    self.allPhotoAssetFetchResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:fetchOptions];
    self.imagePickerBottomStatusDesc = self.allPhotoAssetFetchResult.count ? [NSString stringWithFormat:@"%@张照片", @(self.allPhotoAssetFetchResult.count)] : nil;
    [self reloadItems];
}

- (void) reloadItems {
    @weakify(self)
    [self.adapter performUpdatesAnimated:YES completion:^(BOOL finished) {
        @strongify(self)
        [self gotoBottomAnimated:NO];
        self.collectionView.alpha = 1.f;
    }];
}

- (void) gotoBottomAnimated:(BOOL)animated {
    if (self.imagePickerBottomStatusDesc) {
        [self.adapter scrollToObject:self.imagePickerBottomStatusDesc
                  supplementaryKinds:nil
                     scrollDirection:UICollectionViewScrollDirectionVertical
                      scrollPosition:UICollectionViewScrollPositionBottom
                            animated:animated];
    }
}

- (void) showAccessDenied {
    
}

#pragma mark - IGListAdapterDataSource
- (NSArray<id <IGListDiffable>> *)objectsForListAdapter:(IGListAdapter *)listAdapter {
    NSMutableArray *items = [@[] mutableCopy];
    [self.allPhotoAssetFetchResult enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL * _Nonnull stop) {
        [items addObject:asset];
    }];
    if (self.imagePickerBottomStatusDesc) {
        [items addObject:self.imagePickerBottomStatusDesc];
    }
    return items;
}

- (IGListSectionController *)listAdapter:(IGListAdapter *)listAdapter
              sectionControllerForObject:(id)object {
    if ([object isKindOfClass:[NSString class]]) {
        return [[IGListSingleSectionController alloc] initWithCellClass:[ImagePickerBottomStatusCollectionViewCell class] configureBlock:^(NSString *item, __kindof ImagePickerBottomStatusCollectionViewCell * _Nonnull cell) {
            [cell bindViewModel:item];
        } sizeBlock:^CGSize(NSString *item, id<IGListCollectionContext>  _Nullable collectionContext) {
            return CGSizeMake(collectionContext.insetContainerSize.width, 44.f);
        }];
    }
    return [ImagePickerItemSectionController new];
}

- (nullable UIView *)emptyViewForListAdapter:(IGListAdapter *)listAdapter {
    return nil;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [UIView animateWithDuration:0.3f animations:^{
        CGFloat offsetToBottom = scrollView.contentSize.height - scrollView.height - scrollView.contentOffset.y;
        self.floatGoToBottomBtn.alpha = offsetToBottom > scrollView.height && scrollView.contentSize.height > 2.f * scrollView.height;
    }];
}

#pragma mark - PHPhotoLibraryChangeObserver
- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    dispatch_async(dispatch_get_main_queue(), ^{
        PHFetchResultChangeDetails *changeDetails = [changeInstance changeDetailsForFetchResult:self.allPhotoAssetFetchResult];
        if (changeDetails) {
            self.allPhotoAssetFetchResult = changeDetails.fetchResultAfterChanges;
            if (!changeDetails.hasIncrementalChanges || changeDetails.hasMoves) {
                
            } else {
                NSMutableArray *deselectAssets = [NSMutableArray new];
                for (PHAsset *asset in [[CurrentSelectedAssetsManager sharedInstance] allSelectedAssets]) {
                    PHObjectChangeDetails *changeDetails = [changeInstance changeDetailsForObject:asset];
                    
                    if (changeDetails.objectWasDeleted) {
                        [deselectAssets addObject:asset];
                    }
                }
                for (PHAsset *asset in deselectAssets) {
                    [[CurrentSelectedAssetsManager sharedInstance] didDeselectAsset:asset];
                }
            }
            [self reloadItems];
        }
    });
}

#pragma mark - ImagePickerBottomToolBarViewDelegate
- (void) didClickClear:(ImagePickerBottomToolBarView *)toolBarView {
    [[CurrentSelectedAssetsManager sharedInstance] clear];
}

- (void) didClickClip:(ImagePickerBottomToolBarView *)toolBarView {
    [self gotoTailorPageHorizontally:NO];
}

- (void) didClickSpliceHorizontally:(ImagePickerBottomToolBarView *)toolBarView {
    [self gotoTailorPageHorizontally:YES];
}

- (void) didClickSpliceVertically:(ImagePickerBottomToolBarView *)toolBarView {
    [self gotoTailorPageHorizontally:NO];
}

#pragma mark - private methods
- (void) refreshToolBarView {
    NSInteger selectedCnt = [[CurrentSelectedAssetsManager sharedInstance] allSelectedAssets].count;
    [self.toolBarView show:(selectedCnt > 0) onlyClip:(selectedCnt <= 1)];
}

- (void) gotoTailorPageHorizontally:(BOOL)horizontally {
    TailorViewController *tailorVC = [[TailorViewController alloc] init];
    tailorVC.assetModels = [[[CurrentSelectedAssetsManager sharedInstance].allSelectedAssets copy] bk_map:^id(PHAsset *asset) {
        return [[TailorAssetModel alloc] initWithAsset:asset];
    }];
    tailorVC.tileDirection = horizontally ? TailorTileDirectionHorizontally : TailorTileDirectionVertically;
    [self.navigationController pushViewController:tailorVC animated:YES];
}

#pragma mark - getters
- (UICollectionView *) collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[IGListCollectionViewLayout alloc] initWithStickyHeaders:NO topContentInset:0 stretchToEdge:NO]];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.alpha = 0.f;
        _collectionView.allowsMultipleSelection = YES;
        _collectionView.alwaysBounceVertical = YES;
    }
    return _collectionView;
}
LazyPropertyWithInit(ImagePickerBottomToolBarView, toolBarView, {
    _toolBarView.delegate = self;
})
LazyPropertyWithInit(UIButton, floatGoToBottomBtn, {
    _floatGoToBottomBtn.alpha = 0.f;
    _floatGoToBottomBtn.layer.cornerRadius = 22.f;
    _floatGoToBottomBtn.clipsToBounds = YES;
    _floatGoToBottomBtn.backgroundColor = [UIColor hex_colorWithHex:0x333333 alpha:0.7f];
    @weakify(self)
    [_floatGoToBottomBtn bk_addEventHandler:^(id sender) {
        @strongify(self)
        [self gotoBottomAnimated:YES];
    } forControlEvents:UIControlEventTouchUpInside];
})
@end
