////
////  TailorNavigatorToolBarControl.m
////  ImageTailor
////
////  Created by dl on 2018/4/30.
////  Copyright © 2018年 dl. All rights reserved.
////
//
//#import "TailorNavigatorToolBarControl.h"
//
//@interface TailorNavigatorToolBarControl()
//@property (nonatomic, strong) NSArray *itemBtns;
//@property (nonatomic, strong, readwrite) NSArray<NSString *> *titles;
//@end
//
//@implementation TailorNavigatorToolBarControl
//
//- (void) refreshWithTitles:(NSArray<NSString *> *)titles {
//    [self refreshWithTitles:titles selectedIndex:0];
//}
//- (void) refreshWithTitles:(NSArray<NSString *> *)titles selectedIndex:(NSInteger)selectedIndex {
//    self.titles = [titles copy];
//    
//    [self.itemBtns bk_each:^(UIButton *btn) {
//        [btn removeFromSuperview];
//    }];
//    self.itemBtns = [titles bk_map:^id(NSString *title) {
//        UIButton *btn = [[UIButton alloc] init];
//        [btn setTitle:title forState:UIControlStateNormal];
//        [btn setTitleColor:[UIColor hex_colorWithHex:0x999999] forState:UIControlStateNormal];
//        [btn setTitleColor:[UIColor hex_colorWithHex:0x333333] forState:UIControlStateSelected];
//        btn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
//        return btn;
//    }];
//    @weakify(self)
//    [self.itemBtns enumerateObjectsUsingBlock:^(UIButton *btn, NSUInteger idx, BOOL * _Nonnull stop) {
//        [self addSubview:btn];
//        
//        [btn bk_addEventHandler:^(id sender) {
//            @strongify(self)
//            [self selectItemWithIndex:idx];
//        } forControlEvents:UIControlEventTouchUpInside];
//    }];
//    [self setNeedsUpdateConstraints];
//    
//    [self selectItemWithIndex:((selectedIndex >= 0 && selectedIndex < self.titles.count) ? selectedIndex : 0)];
//}
//
//- (NSInteger) currentSelectedIndex {
//    __block NSInteger selectedIndex = 0;
//    [self.itemBtns enumerateObjectsUsingBlock:^(UIButton *btn, NSUInteger idx, BOOL * _Nonnull stop) {
//        if (btn.selected) {
//            selectedIndex = idx;
//            *stop = YES;
//        }
//    }];
//    return selectedIndex;
//}
//
//- (void) layoutSubviews {
//    [super layoutSubviews];
//    
//    CGFloat itemWidth = ceilf(self.width / self.itemBtns.count);
//    [self.itemBtns enumerateObjectsUsingBlock:^(UIButton *btn, NSUInteger idx, BOOL * _Nonnull stop) {
//        btn.frame = CGRectMake(idx * itemWidth, 0.f, itemWidth, self.height);
//    }];
//}
//
//- (void) selectItemWithIndex:(NSInteger)index {
//    if (index < 0 || index >= self.itemBtns.count) {
//        return ;
//    }
//    [self.itemBtns enumerateObjectsUsingBlock:^(UIButton *btn, NSUInteger idx, BOOL * _Nonnull stop) {
//        btn.selected = index == idx;
//    }];
//    if ([self.delegate respondsToSelector:@selector(didSelectToolBarControl:index:)]) {
//        [self.delegate didSelectToolBarControl:self index:index];
//    }
//}
//
//@end
