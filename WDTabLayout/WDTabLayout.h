//
//  WDTabLayout.h
//  WeiChatRead
//
//  Created by 吴丹 on 2018/8/6.
//  Copyright © 2018 forever.love. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger , WDTabLayoutStyle) {
    WDTabLayoutStyle_buttomIndicate, // 显示下面线条
    WDTabLayoutStyle_interval,       // 之间有间隔
    WDTabLayoutStyle_default,        // 只显示文字
};

@interface WDTabLayout : UIView

/**
 初始化

 @param style 显示样式
 @param titleArray 标题数组
 @param viewControllers 控制器数组
 @param backgroundColor 背景颜色
 @param indicateColor 指示器颜色
 @param normalColor 标题非选中颜色
 @param selectedColor 标题选中颜色
 @param titleSize 字体大小
 @param indicateHeight 底部指示器高度
 @return self
 */
- (instancetype)initWithShowStyle:(WDTabLayoutStyle)style
                       titleArray:(NSArray<NSString *> *)titleArray
                  viewControllers:(NSArray<UIViewController *> *)viewControllers
                  backgroundColor:(UIColor *)backgroundColor
                    indicateColor:(UIColor *)indicateColor
                      normalColor:(UIColor *)normalColor
                    selectedColor:(UIColor *)selectedColor
                        titleSize:(CGFloat)titleSize
                   indicateHeight:(CGFloat)indicateHeight;
@end
