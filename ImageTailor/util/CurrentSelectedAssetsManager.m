//
//  CurrentSelectedAssetsManager.m
//  ImageTailor
//
//  Created by dl on 2018/4/29.
//  Copyright © 2018年 dl. All rights reserved.
//

#import "CurrentSelectedAssetsManager.h"

@interface CurrentSelectedAssetsManager()
@property (nonatomic, strong) NSMutableArray *innerSelectedAssets;
@end

@implementation CurrentSelectedAssetsManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _innerSelectedAssets = [@[] mutableCopy];
    }
    return self;
}

SINGLETON_INSTANCE_METHOD

- (NSInteger) indexForAsset:(PHAsset *)asset {
    return [self.innerSelectedAssets indexOfObject:asset];
}

- (void) didSelectAsset:(PHAsset *)asset {
    [self.innerSelectedAssets addObject:asset];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotiImagePickerItemSelectStatusChange object:nil];
}

- (void) didDeselectAsset:(PHAsset *)asset {
    [self.innerSelectedAssets removeObject:asset];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotiImagePickerItemSelectStatusChange object:nil];
}

- (void) toggleAsset:(PHAsset *)asset {
    if ([self.innerSelectedAssets containsObject:asset]) {
        [self.innerSelectedAssets removeObject:asset];
    } else {
        [self.innerSelectedAssets addObject:asset];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotiImagePickerItemSelectStatusChange object:nil];
}

- (NSArray<PHAsset *> *) allSelectedAssets {
    return [self.innerSelectedAssets copy];
}

- (void) clear {
    [self.innerSelectedAssets removeAllObjects];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotiImagePickerItemSelectStatusChange object:nil];
}

@end
