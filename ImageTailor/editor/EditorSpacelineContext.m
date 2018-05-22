//
//  EditorSpacelineContext.m
//  ImageTailor
//
//  Created by dl on 2018/5/22.
//  Copyright © 2018年 dl. All rights reserved.
//

#import "EditorSpacelineContext.h"

@interface EditorSpacelineContext()
@property (nonatomic, assign, readwrite) EditorToolBarSpacelineType spacelineType;
@property (nonatomic, strong, readwrite) NSArray<UIView *> *spacelineViews;
@property (nonatomic, strong, readwrite) NSArray<UIView *> *boundslineViews;
@end

@implementation EditorSpacelineContext

- (void) setup {
    UIView *(^createLine)(void) = ^UIView*(void) {
        UIView *line = [[UIView alloc] init];
        line.backgroundColor = [UIColor whiteColor];
        line.hidden = YES;
        line.layer.transform = CATransform3DMakeTranslation(0, 0, 500);
        [self.imageContainerView addSubview:line];
        return line;
    };
    
    self.boundslineViews = [@[@0, @1, @2, @3] bk_map:^id(id obj) {
        return createLine();
    }];
    
    NSMutableArray *spacelines = [@[] mutableCopy];
    for (int i=0; i<self.imagesCnt; i++) {
        [spacelines addObject:createLine()];
    }
    self.spacelineViews = [spacelines copy];
}

- (void) didChangeAllImageViewsRect:(CGRect)allImageViewsRect
                         imageRects:(NSArray *)imageRects {
    [self.boundslineViews enumerateObjectsUsingBlock:^(UIView * line, NSUInteger idx, BOOL * _Nonnull stop) {
        line.hidden = self.spacelineType != EditorToolBarSpacelineTypeAllBounds;
    }];
    [self.spacelineViews enumerateObjectsUsingBlock:^(UIView * line, NSUInteger idx, BOOL * _Nonnull stop) {
        line.hidden = self.spacelineType == EditorToolBarSpacelineTypeNone;
    }];
    if (self.spacelineType == EditorToolBarSpacelineTypeAllBounds) {
        self.boundslineViews[0].frame = (CGRect){allImageViewsRect.origin, CGSizeMake(CGRectGetWidth(allImageViewsRect), 2.f)};
        self.boundslineViews[1].frame = (CGRect){allImageViewsRect.origin, CGSizeMake(2.f, CGRectGetHeight(allImageViewsRect))};
        self.boundslineViews[2].frame = CGRectMake(CGRectGetMinX(allImageViewsRect),
                                                   CGRectGetMaxY(allImageViewsRect) - 2.f,
                                                   CGRectGetWidth(allImageViewsRect),
                                                   2.f);
        self.boundslineViews[3].frame = CGRectMake(CGRectGetMaxX(allImageViewsRect) - 2.f,
                                                   CGRectGetMinY(allImageViewsRect),
                                                   2.f,
                                                   CGRectGetHeight(allImageViewsRect));
    }
    if (self.spacelineType != EditorToolBarSpacelineTypeNone) {
        [imageRects enumerateObjectsUsingBlock:^(NSValue *rectValue, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx < imageRects.count - 1) {
                CGRect lineFrame = CGRectZero;
                CGRect imageRect = [rectValue CGRectValue];
                if (self.tileDirection == TailorTileDirectionVertically) {
                    lineFrame = CGRectMake(CGRectGetMinX(allImageViewsRect),
                                           CGRectGetMaxY(imageRect) - 1.f,
                                           CGRectGetWidth(allImageViewsRect),
                                           2.f);
                } else {
                    lineFrame = CGRectMake(CGRectGetMaxX(imageRect) - 1.f,
                                           CGRectGetMinY(allImageViewsRect),
                                           2.f,
                                           CGRectGetHeight(allImageViewsRect));
                }
                self.spacelineViews[idx].frame = lineFrame;
            }
        }];
    }
}

- (void) showSpacelineWithType:(EditorToolBarSpacelineType)spacelineType {
    self.spacelineType = spacelineType;
}

- (void) hide {
    self.spacelineType = EditorToolBarSpacelineTypeNone;
}

- (NSArray<UIView *> *) allLineViews {
    NSMutableArray *spacelines = [@[] mutableCopy];
    [spacelines addObjectsFromArray:[self.boundslineViews bk_select:^BOOL(UIView *line) {
        return !line.hidden;
    }]];
    [spacelines addObjectsFromArray:[self.spacelineViews bk_select:^BOOL(UIView *line) {
        return !line.hidden;
    }]];
    return [spacelines copy];
}

@end
