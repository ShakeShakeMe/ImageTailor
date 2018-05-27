//
//  ViewController.m
//  ImageTailor
//
//  Created by dl on 2018/4/29.
//  Copyright © 2018年 dl. All rights reserved.
//

#import "ViewController.h"
#import "PhotoAssetsService.h"
#import "ImagePickerItemSectionController.h"
#include "ImagePickerBottomStatusCollectionViewCell.h"
#import "ImagePickerBottomToolBarView.h"
#import "EditorViewController.h"
#import "TailorAssetModel.h"
#import "ImagePickerCatalogView.h"

#import "SavePhotoSuccessViewController.h"

@interface ViewController () <IGListAdapterDataSource, UIScrollViewDelegate, ImagePickerBottomToolBarViewDelegate, PhotoAssetsServiceDelegate, ImagePickerCatalogViewDelegate>

@property (nonatomic, strong) UILabel *navTitleLabel;
@property (nonatomic, strong) UIImageView *navTitleImageView;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) IGListAdapter *adapter;
@property (nonatomic, strong) AssetsGroup *currentAssetGroup;

@property (nonatomic, strong) ImagePickerBottomToolBarView *toolBarView;

@property (nonatomic, strong) ImagePickerCatalogView *catalogView;
@property (nonatomic, assign) BOOL isCatalogShowing;

@property (nonatomic, strong) NSString *imagePickerBottomStatusDesc;

@property (nonatomic, strong) UIButton *floatGoToBottomBtn;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavTitleView];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.toolBarView];
    [self.view addSubview:self.floatGoToBottomBtn];
    
    self.adapter = [[IGListAdapter alloc] initWithUpdater:[IGListAdapterUpdater new] viewController:self];
    self.adapter.dataSource = self;
    self.adapter.collectionView = self.collectionView;
    self.adapter.scrollViewDelegate = self;
    
    [self.view addSubview:self.catalogView];
    
    [PhotoAssetsService sharedInstance].delegate = self;
    [[PhotoAssetsService sharedInstance] loadPhotoAssetGroups];
    
    [self refreshToolBarView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshToolBarView)
                                                 name:kNotiImagePickerItemSelectStatusChange
                                               object:nil];
}

- (void) setupNavTitleView {
    UIView *navTitleView = [[UIView alloc] init];
    [navTitleView addSubview:self.navTitleLabel];
    [navTitleView addSubview:self.navTitleImageView];
    @weakify(self)
    [navTitleView bk_whenTapped:^{
        @strongify(self)
        [self showOrHideCatalogView];
    }];
    self.navigationItem.titleView = navTitleView;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self refreshTitleViewFrame];
}

- (void) refreshTitleViewFrame {
    [self.navTitleLabel sizeToFit];
    CGFloat width = self.navTitleLabel.width + 1.5f + 12.f;
    self.navigationItem.titleView.size = CGSizeMake(width, 44.f);
    self.navTitleLabel.frame = CGRectMake(0.f, 0.f, self.navTitleLabel.width, 44.f);
    self.navTitleImageView.frame = CGRectMake(self.navTitleLabel.right + 1.5f, 16.f, 12.f, 12.f);
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.toolBarView.frame = CGRectMake(0.f, self.view.height - self.mergedSafeAreaInsets.bottom - 50.f, self.view.width, 50.f);
    self.collectionView.frame = CGRectMake(0, 0.f, self.view.width, self.view.height);
    self.floatGoToBottomBtn.size = CGSizeMake(44.f, 44.f);
    self.floatGoToBottomBtn.centerX = self.view.centerX;
    self.floatGoToBottomBtn.bottom = self.toolBarView.top - 24.f;
    
    CGFloat catalogViewTop = self.isCatalogShowing ? self.mergedSafeAreaInsets.top : self.view.height;
    self.catalogView.frame = CGRectMake(0.f,
                                        catalogViewTop,
                                        self.view.width,
                                        self.view.height - self.mergedSafeAreaInsets.top - self.mergedSafeAreaInsets.bottom);
}

#pragma mark - PhotoAssetsServiceDelegate
- (void) loadPhotoWithDefaultAssetGroup:(AssetsGroup *)defaultAssetGroup
                      assetsGroupsArray:(NSArray<AssetsGroup *> *)assetsGroupsArray {
//    NSMutableString *groupNames = [NSMutableString string];
//    [assetsGroupsArray enumerateObjectsUsingBlock:^(AssetsGroup * assetGroup, NSUInteger idx, BOOL * _Nonnull stop) {
//        [groupNames appendFormat:@"%@[%@], ", assetGroup.groupName, @(assetGroup.assetCount)];
//    }];
//    NSLog(@"groupNames: %@", groupNames);
    
    self.currentAssetGroup = defaultAssetGroup;
    if (self.isCatalogShowing) {
        [self.catalogView forceReload];
    }
    [self reloadItems];
}

- (void) authorizationFailed {
    
}

#pragma mark - IGListAdapterDataSource
- (NSArray<id <IGListDiffable>> *)objectsForListAdapter:(IGListAdapter *)listAdapter {
    if (!self.currentAssetGroup.assetsArray) {
        return nil;
    }
    NSMutableArray *items = [@[] mutableCopy];
    [items addObjectsFromArray:self.currentAssetGroup.assetsArray];
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
            return CGSizeMake(collectionContext.insetContainerSize.width, 50.f);
        }];
    }
    return [ImagePickerItemSectionController new];
}

- (nullable UIView *)emptyViewForListAdapter:(IGListAdapter *)listAdapter {
    return nil;
}

#pragma mark - ImagePickerCatalogViewDelegate
- (void) didSelectedAssetGroup:(AssetsGroup *)assetGroup {
    self.currentAssetGroup = assetGroup;
    [self reloadItems];
    [self showOrHideCatalogView];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [UIView animateWithDuration:0.3f animations:^{
        CGFloat offsetToBottom = scrollView.contentSize.height - scrollView.height - scrollView.contentOffset.y;
        self.floatGoToBottomBtn.alpha = offsetToBottom > scrollView.height && scrollView.contentSize.height > 2.f * scrollView.height;
    }];
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
- (void) reloadItems {
    @weakify(self)
    [self.adapter performUpdatesAnimated:NO completion:^(BOOL finished) {
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

- (void) showOrHideCatalogView {
    if (!self.isCatalogShowing) {
        self.isCatalogShowing = YES;
        self.catalogView.currentAssetsGroup = self.currentAssetGroup;
        [self.catalogView forceReload];
    } else {
        self.isCatalogShowing = NO;
    }
    CGFloat catalogViewTop = self.isCatalogShowing ? self.mergedSafeAreaInsets.top : self.view.height;
    [UIView animateWithDuration:0.3f animations:^{
        self.navTitleImageView.transform = self.isCatalogShowing ? CGAffineTransformMakeRotation(M_PI) : CGAffineTransformIdentity;
        self.catalogView.frame = CGRectMake(0.f,
                                            catalogViewTop,
                                            self.view.width,
                                            self.view.height - self.mergedSafeAreaInsets.top - self.mergedSafeAreaInsets.bottom);
    } completion:^(BOOL finished) {
    }];
}

- (void) refreshToolBarView {
    NSInteger selectedCnt = [[CurrentSelectedAssetsManager sharedInstance] allSelectedAssets].count;
    [self.toolBarView show:(selectedCnt > 0) onlyClip:(selectedCnt <= 1)];
}

- (void) gotoTailorPageHorizontally:(BOOL)horizontally {
    EditorViewController *editorVC = [[EditorViewController alloc] init];
    editorVC.assetModels = [[[CurrentSelectedAssetsManager sharedInstance].allSelectedAssets copy] bk_map:^id(PHAsset *asset) {
        return [[TailorAssetModel alloc] initWithAsset:asset];
    }];
    editorVC.tileDirection = horizontally ? TailorTileDirectionHorizontally : TailorTileDirectionVertically;
    [self.navigationController pushViewController:editorVC animated:YES];
    
//    SavePhotoSuccessViewController * vc = [[SavePhotoSuccessViewController alloc] init];
//    vc.asset = [CurrentSelectedAssetsManager sharedInstance].allSelectedAssets.firstObject;
//    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - getters
- (void) setCurrentAssetGroup:(AssetsGroup *)currentAssetGroup {
    if (_currentAssetGroup != currentAssetGroup) {
        _currentAssetGroup = currentAssetGroup;
        self.imagePickerBottomStatusDesc = currentAssetGroup.assetsArray.count ? [NSString stringWithFormat:@"%@张照片", @(currentAssetGroup.assetsArray.count)] : nil;
        [[CurrentSelectedAssetsManager sharedInstance] clear];
        
        self.navTitleLabel.text = self.currentAssetGroup.groupName;
        [self refreshTitleViewFrame];
    }
}
LazyPropertyWithInit(UILabel, navTitleLabel, {
    _navTitleLabel.text = @"全部照片";
    _navTitleLabel.textColor = [UIColor whiteColor];
    _navTitleLabel.font = [UIFont systemFontOfSize:17];
})
LazyPropertyWithInit(UIImageView, navTitleImageView, {
    _navTitleImageView.image = [UIImage imageNamed:@"btn_arrow_down"];
})
- (UICollectionView *) collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[IGListCollectionViewLayout alloc] initWithStickyHeaders:NO topContentInset:0 stretchToEdge:NO]];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.alpha = 0.f;
        _collectionView.allowsMultipleSelection = YES;
        _collectionView.alwaysBounceVertical = YES;
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _collectionView;
}
LazyPropertyWithInit(ImagePickerCatalogView, catalogView, {
    _catalogView.delegate = self;
})
LazyPropertyWithInit(ImagePickerBottomToolBarView, toolBarView, {
    _toolBarView.delegate = self;
})
LazyPropertyWithInit(UIButton, floatGoToBottomBtn, {
    _floatGoToBottomBtn.alpha = 0.f;
    [_floatGoToBottomBtn setImage:[UIImage imageNamed:@"btn_album_tobottom_n"] forState:UIControlStateNormal];
    @weakify(self)
    [_floatGoToBottomBtn bk_addEventHandler:^(id sender) {
        @strongify(self)
        [self gotoBottomAnimated:YES];
    } forControlEvents:UIControlEventTouchUpInside];
})
@end
