//
//  NSArray+IGListExtension.m
//  ImageTailor
//
//  Created by dl on 2018/4/29.
//  Copyright © 2018年 dl. All rights reserved.
//

#import "NSArray+IGListExtension.h"

@implementation NSArray (IGListExtension)

#pragma mark - IGListDiffable
- (nonnull id<NSObject>)diffIdentifier {
    return self;
}

- (BOOL)isEqualToDiffableObject:(nullable id<IGListDiffable>)object {
    return object != nil && (self == object || [self isEqual:object]);
}

@end
