//
//  WDTabLayout.m
//  WeiChatRead
//
//  Created by 吴丹 on 2018/8/6.
//  Copyright © 2018 forever.love. All rights reserved.
//

#import "WDTabLayout.h"
/**<< 最小Item之间的间距 <<*/
#define WD_MinItemSpace 20.f
/**<< 间隔宽度 <<*/
#define WD_Space_W 2.0f
/**<< 默认字体大小 <<*/
#define WD_Font [UIFont boldSystemFontOfSize:Font_size]

@interface WDTabLayout  () <UIScrollViewDelegate>
/** 标题数组 */
@property (nonatomic, strong) NSArray *in_titleArray;
/** 控制器数组 */
@property (nonatomic, strong) NSArray *in_viewControllers;
/** 背景颜色 */
@property (nonatomic, strong) UIColor *in_backgroundColor;
/** 底部指示器颜色 */
@property (nonatomic, strong) UIColor *in_indicateColor;
/** 非选中标题颜色 */
@property (nonatomic, strong) UIColor *in_normalColor;
/** 选中标题颜色 */
@property (nonatomic, strong) UIColor *in_selectedColor;
/** 标题字体大小 */
@property (nonatomic, assign) CGFloat in_titleSize;
/** 显示样式 */
@property (nonatomic, assign) WDTabLayoutStyle in_style;
/** 标题Btn数组 */
@property (nonatomic, strong) NSArray *BtnArr;
/** segmentView的Size的大小 */
@property (nonatomic, assign) CGSize size;
/** 按钮title到边的间距 */
@property (nonatomic, assign) CGFloat buttonSpace;
/** 按钮宽度 */
@property (nonatomic, assign) CGFloat button_W;
/** 存放按钮的宽度 */
@property (nonatomic, strong) NSMutableArray *widthBtnArr;
/** segmentView头部标题视图 */
@property (nonatomic, strong) UIScrollView *segmentTitleView;
/** segmentView控制器视图 */
@property (nonatomic, strong) UIScrollView *segmentContentView;
/** 指示杆 */
@property (nonatomic, strong) UIView *indicateView;
/** 分割线View */
@property (nonatomic, strong) UIView *spaceView;
/** 当前被选中的按钮 */
@property (nonatomic, strong) UIButton *selectedButton;
/** 底部分割线 */
@property (nonatomic, strong) UIView *bottomLineView;
/** 控制器View的Y */
@property (nonatomic, assign) CGFloat scrollView_Y;
/** 父控制器 */
@property (nonatomic, weak) UIViewController *parentViewController;

@end

static CGFloat Font_size = 0;
static CGFloat IndicateHeight  = 3;

@implementation WDTabLayout

- (instancetype)initWithShowStyle:(WDTabLayoutStyle)style
                       titleArray:(NSArray<NSString *> *)titleArray
                  viewControllers:(NSArray<UIViewController *> *)viewControllers
                  backgroundColor:(UIColor *)backgroundColor
                    indicateColor:(UIColor *)indicateColor
                      normalColor:(UIColor *)normalColor
                    selectedColor:(UIColor *)selectedColor
                        titleSize:(CGFloat)titleSize
                   indicateHeight:(CGFloat)indicateHeight{
    self = [super init];
    if(self) {
        if(titleArray.count != viewControllers.count) {
            @throw [NSException exceptionWithName:@"WDTablayout" reason:@"名称和控制器数量不一致" userInfo:nil];
        }
        
        self.in_titleArray = titleArray;
        self.in_viewControllers = viewControllers;
        self.in_backgroundColor = backgroundColor;
        self.in_indicateColor = indicateColor;
        self.in_normalColor = normalColor;
        self.in_selectedColor = selectedColor;
        self.in_titleSize = titleSize;
        self.in_style = style;
        IndicateHeight = indicateHeight;
        Font_size = titleSize;
    }
    return self;
}

#pragma mark --  设置布局
- (void)layoutSubviews{
    // 视图大小
    self.size = self.frame.size;
    
    // 计算间距
    self.buttonSpace = [self calculateSpace];
    
    // 绘制视图
    [self setupViewsWithStyle:self.in_style];
    
    // 配置
    self.segmentTitleView.backgroundColor = self.in_backgroundColor;
    
    // 默认标题颜色
    for (UIButton *titleBtn in self.BtnArr) {
        [titleBtn setTitleColor:self.in_normalColor forState:UIControlStateNormal];
    }
    
    // 标题选中颜色
    for (UIButton *titleBtn in self.BtnArr) {
        [titleBtn setTitleColor:self.in_selectedColor forState:UIControlStateSelected];
    }
    
    // 默认选中第一个
    [self didClickButton:self.BtnArr.firstObject];
    
    // 线条颜色
    self.indicateView.backgroundColor = self.in_indicateColor;
}

#pragma mark -- 计算按钮间距
- (CGFloat)calculateSpace {
    CGFloat space = 0.f;
    CGFloat totalWidth = 0.f;
    
    for (NSString *title in self.in_titleArray) {
        CGSize titleSize = [title sizeWithAttributes:@{NSFontAttributeName : WD_Font}];
        totalWidth += titleSize.width;
    }
    
    space = (self.size.width - totalWidth) / self.in_titleArray.count / 2;
    if (space > WD_MinItemSpace / 2) {
        return space;
    } else {
        return WD_MinItemSpace / 2;
    }
}

#pragma mark -- 绘制页面
- (void)setupViewsWithStyle:(WDTabLayoutStyle)style {
    
    [self addSubview:self.segmentTitleView];
    [self addSubview:self.bottomLineView];
    
    CGFloat item_x = 0;
    NSString *title;
    NSMutableArray *mutBtnArr = [NSMutableArray array];
    
    if(style == WDTabLayoutStyle_interval) {
        
        self.segmentTitleView.backgroundColor = [UIColor whiteColor];
        for (int i = 0; i < self.in_titleArray.count; i++) {
            title = self.in_titleArray[i];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(item_x, 0, self.button_W , 45);
            [button setTag:i];
            if (i != self.in_titleArray.count - 1) {
                UIView *spaceLine = [[UIView alloc] init];
                spaceLine.frame = CGRectMake(self.button_W + (self.button_W + WD_Space_W)*i , 6, WD_Space_W, 45 - 12);
                spaceLine.backgroundColor = [UIColor groupTableViewBackgroundColor];
                [self.segmentTitleView addSubview:spaceLine];
            }
            
            [button setTitle:title forState:UIControlStateNormal];
            button.titleLabel.font = WD_Font;
            [button addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];
            [self.segmentTitleView addSubview:button];
            [mutBtnArr addObject:button];
            
            [self.widthBtnArr addObject:[NSNumber numberWithDouble:CGRectGetWidth(button.frame)]];
            item_x += self.button_W + WD_Space_W;
            if (i == self.in_titleArray.count - 1) {
                item_x = item_x - WD_Space_W;
            }
        }
        
    } else if (style == WDTabLayoutStyle_buttomIndicate) {
        
        for (int i = 0; i < self.in_titleArray.count; i++) {
            title = self.in_titleArray[i];
            CGSize titleSize = [title sizeWithAttributes:@{NSFontAttributeName: WD_Font}];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(item_x, 0, _buttonSpace *2 + titleSize.width, 45);
            [button setTag:i];
            [button setTitle:title forState:UIControlStateNormal];
            [button addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];
            [self.segmentTitleView addSubview:button];
            [mutBtnArr addObject:button];
            
            [self.widthBtnArr addObject:[NSNumber numberWithDouble:CGRectGetWidth(button.frame)]];
            item_x += self.buttonSpace * 2 + titleSize.width;
            if (i == 0) {
                button.selected = YES;
                self.selectedButton = button;
                self.selectedButton.titleLabel.font = WD_Font;
                self.indicateView.frame = CGRectMake(self.buttonSpace, 45 - IndicateHeight, titleSize.width, IndicateHeight);
                [self.segmentTitleView addSubview:self.indicateView];
            }else {
                button.titleLabel.font = WD_Font;
            }
        }
    } else {
        
        for (int i = 0; i < self.in_titleArray.count; i++) {
            title = self.in_titleArray[i];
            CGSize titleSize = [title sizeWithAttributes:@{NSFontAttributeName: WD_Font}];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(item_x, 0, _buttonSpace *2 + titleSize.width, 45);
            [button setTag:i];
            [button setTitle:title forState:UIControlStateNormal];
            [button addTarget:self action:@selector(didClickButton:) forControlEvents:UIControlEventTouchUpInside];
            [self.segmentTitleView addSubview:button];
            [mutBtnArr addObject:button];
            
            [self.widthBtnArr addObject:[NSNumber numberWithDouble:CGRectGetWidth(button.frame)]];
            item_x += self.buttonSpace * 2 + titleSize.width;
            if (i == 0) {
                button.selected = YES;
                self.selectedButton = button;
                self.selectedButton.titleLabel.font = WD_Font;
            }else {
                button.titleLabel.font = WD_Font;
            }
        }
    }
    
    self.BtnArr = [mutBtnArr copy];
    self.segmentTitleView.contentSize = CGSizeMake(item_x, 45);
}

#pragma mark -- 按钮点击事件
- (void)didClickButton:(UIButton *)button {
    if (button != self.selectedButton) {
        button.selected = YES;
        button.titleLabel.font = WD_Font;
        self.selectedButton.selected = !self.selectedButton.selected;
        self.selectedButton.titleLabel.font = WD_Font;
        self.selectedButton = button;
        [self scrollIndicateView];
        [self scrollSegementView];
    }
    [self loadOtherVCWith:self.selectedButton.tag];
}

#pragma mark -- 根据Tag加载对应的控制器
- (void)loadOtherVCWith:(NSInteger)tag {
    UIViewController *viewController = self.in_viewControllers[tag];
    [viewController.view setFrame:CGRectMake(self.size.width * tag, 0, self.size.width, UIScreen.mainScreen.bounds.size.height-self.scrollView_Y)];
    [self.parentViewController addChildViewController:viewController];
    [viewController didMoveToParentViewController:self.parentViewController];
    [self.segmentContentView addSubview:viewController.view];
}

#pragma mark -- 根据下标更换segment标题名称
- (void)changeTitleWithIndex:(NSInteger)index title:(NSString *)title {
    if (index < self.BtnArr.count) {
        UIButton *titleBtn = self.BtnArr[index];
        [titleBtn setTitle:title forState:UIControlStateNormal];
    }
}

#pragma mark -- 根据选中的按钮滑动指示杆
- (void)scrollIndicateView {
    
    NSInteger index = [self selectedAtIndex];
    CGSize titleSize = [self.selectedButton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName : WD_Font}];
    
    __weak __typeof(self)weakSelf = self;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if (weakSelf.in_style == WDTabLayoutStyle_buttomIndicate) {
            weakSelf.indicateView.frame = CGRectMake(CGRectGetMinX(weakSelf.selectedButton.frame) + weakSelf.buttonSpace, CGRectGetMinY(weakSelf.indicateView.frame), titleSize.width, IndicateHeight);
        } else {
            weakSelf.indicateView.frame = CGRectMake(CGRectGetMinX(weakSelf.selectedButton.frame), CGRectGetMinY(weakSelf.indicateView.frame), [self widthAtIndex:index], IndicateHeight);
        }
        
        [weakSelf.segmentContentView setContentOffset:CGPointMake(index * weakSelf.size.width, 0)];
        
    } completion:^(BOOL finished) {
        
    }];
}

- (CGFloat)widthAtIndex:(NSInteger)index {
    if (index < 0 || index > self.in_titleArray.count - 1) {
        return 0.f;
    }
    return [[self.widthBtnArr objectAtIndex:index] doubleValue];
}


#pragma mark -- 根据选中调整segementView的offset
- (void)scrollSegementView {
    
    CGFloat selectedWidth = self.selectedButton.frame.size.width;
    CGFloat offsetX = (self.size.width - selectedWidth) / 2;
    
    if (self.selectedButton.frame.origin.x <= self.size.width / 2) {
        [self.segmentTitleView setContentOffset:CGPointMake(0, 0) animated:true];
    } else if (CGRectGetMaxX(self.selectedButton.frame) >= (self.segmentTitleView.contentSize.width - self.size.width / 2)) {
        [self.segmentTitleView setContentOffset:CGPointMake(self.segmentTitleView.contentSize.width - self.size.width, 0) animated:true];
    } else {
        [self.segmentTitleView setContentOffset:CGPointMake(CGRectGetMinX(self.selectedButton.frame) - offsetX, 0) animated:true];
    }
}

#pragma mark -- index
- (NSInteger)selectedAtIndex {
    return self.selectedButton.tag;
}

- (void)setSelectedItemAtIndex:(NSInteger)index {
    for (UIView *view in self.segmentTitleView.subviews) {
        if ([view isKindOfClass:[UIButton class]] && view.tag == index) {
            UIButton *button = (UIButton *)view;
            [self didClickButton:button];
        }
    }
}

#pragma mark -- scrollView delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger index = round(scrollView.contentOffset.x / self.size.width);
    [self setSelectedItemAtIndex:index];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    NSInteger currentIndex = [self selectedAtIndex];
    CGFloat offset;
    NSInteger buttonIndex = currentIndex;
    if (offsetX >= [self selectedAtIndex] * self.size.width) {
        offset = offsetX - [self selectedAtIndex] * self.size.width;
        buttonIndex += 1;
    } else {
        offset = [self selectedAtIndex] * self.size.width - offsetX;
        buttonIndex -= 1;
        currentIndex -= 1;
    }
    
    CGFloat originMovedX = self.in_style == WDTabLayoutStyle_buttomIndicate? (CGRectGetMinX(self.selectedButton.frame) + self.buttonSpace) : CGRectGetMinX(self.selectedButton.frame);
    CGFloat targetMovedWidth = [self widthAtIndex:currentIndex];
    CGFloat targetButtonWidth = self.in_style == WDTabLayoutStyle_buttomIndicate? ([self widthAtIndex:buttonIndex] - 2 * self.buttonSpace) : [self widthAtIndex:buttonIndex];
    CGFloat originButtonWidth = self.in_style == WDTabLayoutStyle_buttomIndicate? ([self widthAtIndex:[self selectedAtIndex]] - 2 * self.buttonSpace) : [self widthAtIndex:[self selectedAtIndex]];
    
    CGFloat moved;
    moved = offsetX - [self selectedAtIndex] * self.size.width;
    self.indicateView.frame = CGRectMake(originMovedX + targetMovedWidth / self.size.width * moved, self.indicateView.frame.origin.y,  originButtonWidth + (targetButtonWidth - originButtonWidth) / self.size.width * offset, self.indicateView.frame.size.height);
}


#pragma mark -- getter && setter
- (UIView *)bottomLineView {
    if (!_bottomLineView) {
        _bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 45, self.size.width, 5)];
        _bottomLineView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        self.scrollView_Y = 45 + 5;
    }
    return _bottomLineView;
}

- (NSMutableArray *)widthBtnArr {
    if (!_widthBtnArr) {
        _widthBtnArr = [NSMutableArray array];
    }
    return _widthBtnArr;
}

- (UIScrollView *)segmentTitleView {
    if (!_segmentTitleView) {
        _segmentTitleView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.size.width, 45)];
        _segmentTitleView.showsHorizontalScrollIndicator = false;
        _segmentTitleView.showsVerticalScrollIndicator = false;
        self.button_W = (self.size.width - WD_Space_W * (self.in_titleArray.count -1)) / self.in_titleArray.count;
    }
    return _segmentTitleView;
}

- (UIScrollView *)segmentContentView {
    if (!_segmentContentView) {
        _segmentContentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.scrollView_Y, self.size.width, UIScreen.mainScreen.bounds.size.height - self.scrollView_Y)];
        _segmentContentView.delegate = self;
        _segmentContentView.showsHorizontalScrollIndicator = false;
        _segmentContentView.pagingEnabled = true;
        _segmentContentView.bounces = true;
        _segmentContentView.contentSize = CGSizeMake(self.size.width * self.in_viewControllers.count, 0);
        UIViewController *viewController = self.in_viewControllers[0];
        viewController.view.frame = CGRectMake(0, 0, self.size.width, self.size.height-self.scrollView_Y);
        [self.parentViewController addChildViewController:viewController];
        [viewController didMoveToParentViewController:self.parentViewController];
        [_segmentContentView addSubview:viewController.view];
        [self addSubview:_segmentContentView];
    }
    return _segmentContentView;
}

- (UIView *)indicateView {
    if (!_indicateView) {
        _indicateView = [[UIView alloc] init];
        _indicateView.layer.cornerRadius = IndicateHeight/2;
        _indicateView.layer.masksToBounds = true;
    }
    return _indicateView;
}

@end
