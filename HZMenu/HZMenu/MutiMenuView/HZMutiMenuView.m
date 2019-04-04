//
//  HZMutiMenuView.m
//  LZM
//
//  Created by Quanhai on 2019/1/17.
//  Copyright © 2019 Quanhai. All rights reserved.
//

#import "HZMutiMenuView.h"


#define kMenuRGB(x,y,z)    [UIColor colorWithRed:x/255.0 green:y/255.0 blue:z/255.0 alpha:1]


CGFloat const kHZMutiIconWidth = 44.f;


@implementation HZMutiMenuConfig

+ (instancetype)defaultConfig{
    HZMutiMenuConfig *config = [HZMutiMenuConfig new];
    config.iconBackgroundColor = [UIColor whiteColor];
    config.iconType = HZMutiIconTypeAlignRight;
    config.iconMargin = 15.f;
    config.iconTitleColor = kMenuRGB(51, 51, 51);
    config.iconTitleFont = [UIFont systemFontOfSize:14];
//    config.iconWidthArray = @[];
    
    config.itemBackgroundColor = [UIColor whiteColor];
    config.normalColor = kMenuRGB(102, 102, 102);
    config.highlightColor = kMenuRGB(65, 145, 241);
    config.normalFont = [UIFont systemFontOfSize:15];
    config.highlightFont = [UIFont systemFontOfSize:16];
    config.isEqualWidth = YES;
    config.itemWidth = 0.f;
    config.itemTopMargin = 0.f;
    config.leftMargin = 15.f;
    config.rightMargin = 15.f;
    config.itemSpace = 8.f;
    config.itemStyle = HZMutiItemStyleEqualWidthAlignCenter;
    
    config.isHoverHidden = NO;
    config.hoverType = HZMutiHoverTypeStickiness;
    config.hoverWidth = 16.f;
    config.hoverHeight = 1.5f;
    config.hoverBottomOffset = 1.f;
    config.hoverColor = kMenuRGB(65, 145, 241);
    
    config.sepratorColor = [UIColor groupTableViewBackgroundColor];
    config.isSepratorShow = NO;
    
    return config;
}

@end


@interface HZMutiMenuView()

@property (nonatomic, strong, readwrite) HZMutiMenuConfig * config ; /**<  **/
@property (nonatomic, strong) NSArray <NSString *> * itemTitles ; /**< 标题列表 **/
@property (nonatomic, strong) NSArray <NSString *> * iconImageNames ; /**< icon 图标, 不存在的话会作为文字展示 **/
@property (nonatomic, strong) NSMutableArray <UILabel *> * itemLabels ; /**< 标题items **/
@property (nonatomic, strong) NSMutableArray <UIButton *> * iconButtons ; /**< 按钮icons **/

//@property (nonatomic, strong) UIScrollView * scrollView ; /**< 存放items视图 **/
@property (nonatomic, strong) UIView * iconContentView ; /**< 存放icons 视图 **/
@property (nonatomic, strong) UIView * hoverView ; /**< 底部滑块 **/
@property (nonatomic, strong) UIView * sepratorView ; /**< 分割线 **/

@end

@implementation HZMutiMenuView

#pragma mark ------------------------------ initlization
- (instancetype)initWithFrame:(CGRect)frame items:(NSArray <NSString *> *)items{
    HZMutiMenuView *menuView = [self initWithFrame:frame items:items icons:nil config:^(HZMutiMenuConfig *config) {
        config.iconType = HZMutiIconTypeNone;
    }];
    return menuView;
}

- (instancetype)initWithFrame:(CGRect)frame items:(NSArray <NSString *> *)items icons:(NSArray <NSString *> *)icons{
    HZMutiMenuView *menuView = [self initWithFrame:frame items:items icons:icons config:^(HZMutiMenuConfig *config) {
    }];
    return menuView;
}

- (instancetype)initWithFrame:(CGRect)frame items:(NSArray<NSString *> *)items icons:(NSArray<NSString *> *)icons config:(void (^)(HZMutiMenuConfig *config))configration{
    if (self = [super initWithFrame:frame]) {
        self.config = [HZMutiMenuConfig defaultConfig];
        if (configration){
            configration(self.config);
        }
        self.itemTitles = items;
        self.iconImageNames = icons;
        [self setupSubviews];
    }
    return self;
}


#pragma mark ------------------------------ subviews
- (void)setupSubviews{
    [self setupIcons];
    [self setupItems];
    [self setupSeprator];
    [self updateItems];
    [self.scrollView addSubview:self.hoverView];
    [self updateHoverViewToIndex:_selectIndex];
}

- (void)setupIcons{
    if (self.iconImageNames.count == 0 || self.config.iconType == HZMutiIconTypeNone){
        return;
    }
    
    if (self.config.iconWidthArray.count != self.iconImageNames.count){
        NSLog(@"设置的iconWidth 和 iconImageNames 数量不相等 : %ld != %ld \n宽度已重置为 44.f", self.config.iconWidthArray.count, self.iconImageNames.count);
            NSMutableArray *widthArray = [NSMutableArray array];
            for (NSString *imageName in self.iconImageNames) {
                [widthArray addObject:@(44.f)];
            }
            self.config.iconWidthArray = [widthArray copy];
    }
    
    self.iconContentView = [[UIView alloc] init];
    self.iconContentView.backgroundColor = self.config.iconBackgroundColor;
    self.iconButtons = [NSMutableArray array];
    CGFloat iconHeight = (self.bounds.size.height > 44.f)? 44.f : self.bounds.size.height;
    CGFloat iconY = (self.bounds.size.height > 44.f)? (self.bounds.size.height -44.f)/2 : 0;
    CGFloat totalWidth = 0.f;
    if (self.config.iconType == HZMutiIconTypeAlignLeft){
        totalWidth = self.config.leftMargin;
    }
    NSUInteger index = 0;
    for (NSNumber *iconWidth in self.config.iconWidthArray) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(totalWidth, iconY, iconWidth.floatValue, iconHeight)];
        NSString *imageName = [self.iconImageNames objectAtIndex:index];
        UIImage *image = [UIImage imageNamed:imageName];
        if (image){
            [button setImage:image forState:UIControlStateNormal];
        }else{
            [button setTitle:imageName forState:UIControlStateNormal];
        }
        button.titleLabel.font = self.config.iconTitleFont;
        [button setTitleColor:self.config.iconTitleColor forState:UIControlStateNormal];
        [button addTarget:self action:@selector(iconSelected:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = index;
        [self.iconContentView addSubview:button];
        [self.iconButtons addObject:button];
        index ++;
        totalWidth += iconWidth.floatValue;
    }
    totalWidth += self.config.iconMargin;
    if (self.config.iconType == HZMutiIconTypeAlignRight){
        self.iconContentView.frame = CGRectMake(self.bounds.size.width - totalWidth , 0, totalWidth, self.bounds.size.height);
    }else if (self.config.iconType == HZMutiIconTypeAlignLeft){
        self.iconContentView.frame = CGRectMake(0, 0, totalWidth, self.bounds.size.height);
    }
    [self addSubview:self.iconContentView];
}

- (void)setupItems{
    if (self.itemTitles.count == 0){
        return;
    }
    CGRect frame ;
    //1. 根据icon位置 确定 scrollView 的位置
//    if (self.config.iconType == HZMutiIconTypeAlignRight){
//        self.scrollView.frame = CGRectMake(0, self.config.itemTopMargin, self.bounds.size.width -CGRectGetWidth(self.iconContentView.frame), self.bounds.size.height -1);
//    }else
        if (self.config.iconType == HZMutiIconTypeAlignLeft){
        frame = CGRectMake(CGRectGetWidth(self.iconContentView.frame), self.config.itemTopMargin, self.bounds.size.width -CGRectGetWidth(self.iconContentView.frame), self.bounds.size.height -1);
    }else {
         frame = CGRectMake(0, self.config.itemTopMargin, self.bounds.size.width-CGRectGetWidth(self.iconContentView.frame), self.bounds.size.height -1);
    }
    self.scrollView = [[UIScrollView alloc] initWithFrame:frame];
    self.scrollView.backgroundColor = self.config.itemBackgroundColor;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.bounces = NO;
    [self addSubview:self.scrollView];
    // 2. 计算item
    self.itemLabels = [NSMutableArray array];
    __block CGFloat totoalItemWidth = 0.f;
    __block CGFloat itemX = 0.f;
    CGFloat itemHeight = self.scrollView.bounds.size.height - self.config.hoverBottomOffset - self.config.hoverHeight;
    // 设定了 itemWidth
    if (self.config.itemWidth > 0){
        itemX += self.config.leftMargin;
        // 等距等宽item
        totoalItemWidth += self.config.leftMargin;
        totoalItemWidth += (self.itemTitles.count-1)*self.config.itemSpace;
        totoalItemWidth += self.itemTitles.count *self.config.itemWidth;
        totoalItemWidth += self.config.rightMargin;
        
        CGFloat itemWidth = self.config.itemWidth;
        CGFloat itemSpace = self.config.itemSpace;
        totoalItemWidth = MAX(totoalItemWidth, self.scrollView.bounds.size.width) ;
        if (self.config.isEqualWidth){
            itemWidth = (totoalItemWidth - self.config.leftMargin - (self.itemTitles.count-1)*self.config.itemSpace - self.config.rightMargin)/self.itemTitles.count;
        }

        [self.scrollView setContentSize:CGSizeMake(totoalItemWidth, self.scrollView.bounds.size.height)];
        
        [self.itemTitles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UILabel *itemLabel = [[UILabel alloc] init];
            itemLabel.textAlignment = NSTextAlignmentCenter;
            itemLabel.font = self.config.highlightFont;
            itemLabel.tag = idx;
            itemLabel.text = obj;
            itemLabel.userInteractionEnabled = YES;
            if (idx != 0){
                itemX += itemSpace;
            }
            itemLabel.frame = CGRectMake(itemX, 0, itemWidth, itemHeight);
            itemX += itemWidth;

            [self.scrollView addSubview:itemLabel];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemTapGesture:)];
            [itemLabel addGestureRecognizer:tap];
            [self.itemLabels addObject:itemLabel];
        }];
        return;
    }
    
    // 自适应
    totoalItemWidth += self.config.leftMargin;
    __block CGFloat maxItemWidth = 0.f;
    NSMutableArray <NSNumber *>* itemWidths = [NSMutableArray array];
    [self.itemTitles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UILabel *itemLabel = [[UILabel alloc] init];
        itemLabel.font = self.config.highlightFont;
        itemLabel.tag = idx;
        itemLabel.text = obj;
        itemLabel.textAlignment = NSTextAlignmentCenter;
        itemLabel.userInteractionEnabled = YES;
        CGSize itemSize = [itemLabel sizeThatFits:CGSizeMake(0, itemHeight)];
        [itemWidths addObject:@(itemSize.width)];
        maxItemWidth = MAX(itemSize.width, maxItemWidth);
        totoalItemWidth += itemSize.width;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(itemTapGesture:)];
        [itemLabel addGestureRecognizer:tap];
        [self.itemLabels addObject:itemLabel];
    }];
    
    totoalItemWidth += self.config.itemSpace*(self.itemTitles.count -1);
    totoalItemWidth += self.config.rightMargin;
    
    CGFloat maxToalWith = MAX(totoalItemWidth, self.scrollView.bounds.size.width);
    CGFloat itemAverageWidth = (maxToalWith - (self.itemTitles.count -1)*self.config.itemSpace -self.config.leftMargin - self.config.rightMargin )/self.itemTitles.count;
    maxItemWidth = self.config.isEqualWidth? itemAverageWidth : maxItemWidth;

    NSInteger index = 0;
    itemX = self.config.leftMargin;
    CGFloat finalItemWith = self.config.leftMargin;
    
    for (UILabel *label in self.itemLabels) {
        label.font = self.config.normalFont;
        CGFloat itemWidth = self.config.isEqualWidth? maxItemWidth : [itemWidths objectAtIndex:index].floatValue;
        if (index !=0){
            itemX += self.config.itemSpace;
        }
        label.frame = CGRectMake(itemX, 0, itemWidth, itemHeight);
        [self.scrollView addSubview:label];
        itemX += itemWidth;
        finalItemWith += itemWidth;
        index ++;
    }
    
    finalItemWith += self.config.itemSpace*(self.itemTitles.count -1);
    finalItemWith += self.config.rightMargin;
    
    [self.scrollView setContentSize:CGSizeMake(finalItemWith, self.scrollView.bounds.size.height)];
}


- (void)setupSeprator{
    self.sepratorView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height -1, self.bounds.size.width, 1.f)];
    self.sepratorView.backgroundColor = self.config.sepratorColor;
    self.sepratorView.hidden = !self.config.isSepratorShow;
    [self addSubview:self.sepratorView];
}

- (void)updateItems{
    NSInteger index = 0;
    for (UILabel *label in self.itemLabels) {
        label.font = self.config.normalFont;
        label.textColor = self.config.normalColor;
        if (index == _selectIndex){
            label.font = self.config.highlightFont;
            label.textColor = self.config.highlightColor;
        }
        index++;
    }
    [self setItemAjustWithIndex:_selectIndex];
}

- (void)updateHoverViewToIndex:(NSInteger)index{
    UILabel *preLabel = [self.itemLabels objectAtIndex:_selectIndex];
    CGFloat preHoverWidth = MIN(preLabel.bounds.size.width, self.config.hoverWidth);
    CGFloat y = self.scrollView.bounds.size.height - self.config.hoverHeight - self.config.hoverBottomOffset;
    if (index == _selectIndex){
        // 第一次初始化
        CGFloat x =  preLabel.center.x - preHoverWidth/2;
        self.hoverView.frame = CGRectMake(x, y, preHoverWidth, self.config.hoverHeight);
        return;
    }
    UILabel *nextLabel = [self.itemLabels objectAtIndex:index];
    CGFloat nextHoverWidth = MIN(nextLabel.bounds.size.width, self.config.hoverWidth);
    // 假设右侧
    CGFloat endX = nextLabel.center.x + nextHoverWidth/2;
    CGFloat startX = self.hoverView.frame.origin.x;
    if (index < _selectIndex){
        // 左侧
        startX = nextLabel.center.x - nextHoverWidth/2;
        endX = self.hoverView.frame.origin.x + self.hoverView.bounds.size.width;
    }
    
    CGRect finalFrame = CGRectMake(nextLabel.center.x - nextHoverWidth/2, y, nextHoverWidth, self.config.hoverHeight);
    
    if (self.config.hoverType == HZMutiHoverTypeNone){
        self.hoverView.frame = finalFrame;
        return ;
    }
    
    self.hoverView.frame = CGRectMake(startX, y, endX - startX, self.config.hoverHeight);
    [UIView animateWithDuration:0.2 animations:^{
        self.hoverView.frame = finalFrame;
    }];
}

- (void)setProgress:(CGFloat)progress{
    if (self.config.hoverType == HZMutiHoverTypeNone){
        NSLog(@"%s 只能在HZMutiHoverTypeStickiness 类型下调用", __func__);
        return;
    }
    //核心代码 一行一块钱
    if(progress > self.itemLabels.count - 1 || progress < 0) return;
    
    _progress = progress;
    
    NSInteger min = MAX(0, floorf(progress));
    NSInteger max = MIN(self.itemLabels.count - 1, ceilf(progress));
    
    CGFloat gress = progress - min;
    
    UILabel *minLabel = self.itemLabels[min];
    UILabel *maxLabel = self.itemLabels[max];
    
    CGFloat minX = minLabel.center.x - self.config.hoverWidth/2.f;
    CGFloat maxX = maxLabel.center.x + self.config.hoverWidth/2.f;
    CGFloat pathWidth = maxX - minX - self.config.hoverWidth;  //总路程
    
    CGFloat progressX = minX + MAX(0, (gress - 0.5) * 2)*pathWidth;
    CGFloat progressWidth = self.config.hoverWidth + (1 - (fabs(gress - 0.5f) * 2)) * pathWidth;

    //底部滚动条动画
    self.hoverView.frame = CGRectMake(progressX, self.hoverView.frame.origin.y, progressWidth, self.config.hoverHeight);
    
    //字体颜色动画
    CGFloat nomalR,nomalG,nomalB,nomalA;
    CGFloat highR, highG,highB,highA;
    [self.config.normalColor getRed:&nomalR green:&nomalG blue:&nomalB alpha:&nomalA];
    [self.config.highlightColor getRed:&highR green:&highG blue:&highB alpha:&highA];
    
    UILabel *currentLable, *toLabel;
    if(min == _selectIndex){
        currentLable = minLabel;
        toLabel = maxLabel;
    }else{
        currentLable = maxLabel;
        toLabel = minLabel;
        gress = 1 - gress;
    }
    currentLable.textColor = [UIColor colorWithRed:highR + (nomalR - highR) * gress green: highG + (nomalG - highG) * gress blue:highB + (nomalB - highB) * gress alpha:1];
    toLabel.textColor = [UIColor colorWithRed:nomalR + (highR - nomalR) * gress green:nomalG + (highG - nomalG) * gress blue:nomalB + (highB - nomalB) * gress alpha:1];
    
    if(max == min){
        [self setTitleSelected:NO atIndex:_selectIndex];
        _selectIndex = min;
        [self setTitleSelected:YES atIndex:_selectIndex];
    }
}

- (void)finishedProgress{
    [self updateLabelColorWithIndex:_selectIndex];
}

- (void)updateLabelColorWithIndex:(NSInteger)selectIndex {
    NSInteger index = 0;
    for (UILabel *label in self.itemLabels) {
        label.textColor = self.config.normalColor;
        label.font = self.config.normalFont;
        if (selectIndex == index){
            label.textColor = self.config.highlightColor;
            label.font = self.config.highlightFont;
        }
        index ++;
    }
}

- (UILabel *)setTitleSelected:(BOOL)isSelected atIndex:(NSInteger)index{
    [self setItemAjustWithIndex:index];
    UILabel *label = [self.itemLabels objectAtIndex:index];
    label.textColor = isSelected? self.config.highlightColor : self.config.normalColor;
    label.font = isSelected? self.config.highlightFont : self.config.normalFont;
    return label;
}

- (void)setItemAjustWithIndex:(NSInteger)index{
    if (index < 0 || index >= self.itemTitles.count){
        return;
    }
    if (self.scrollView.contentSize.width <= self.scrollView.frame.size.width){
        return ;
    }
    
    UILabel *label = [self.itemLabels objectAtIndex:index];

    CGFloat scrollCenterX = self.scrollView.bounds.size.width /2.f;
    CGFloat contentOffsetX = label.center.x - scrollCenterX;
    contentOffsetX = MAX(0, contentOffsetX);
    contentOffsetX = MIN(contentOffsetX, self.scrollView.contentSize.width - self.scrollView.bounds.size.width);
    
    if (index == 0){
        contentOffsetX = 0;
    }
    if (index == self.itemLabels.count-1){
        contentOffsetX = self.scrollView.contentSize.width - self.scrollView.bounds.size.width;
    }
    
//    if (index > 1 && index < (self.itemLabels.count -2)) {
    [self.scrollView setContentOffset:CGPointMake(contentOffsetX, 0) animated:YES];
//    }else{
    UILabel *item = self.itemLabels[index] ;
    [self.scrollView scrollRectToVisible:item.frame animated:YES];
//    }
}

#pragma mark ----------------------------- actions
- (void)iconSelected:(UIButton *)button{
    if ([self.delegate respondsToSelector:@selector(itemMenuView:selectIconAtIndex:)]){
        [self.delegate itemMenuView:self selectIconAtIndex:button.tag];
    }
}

- (void)itemTapGesture:(UITapGestureRecognizer *)tap{
    _selectIndex = tap.view.tag;
    if ([self.delegate respondsToSelector:@selector(itemMenuView:selectItemAtIndex:)]){
        [self.delegate itemMenuView:self selectItemAtIndex:tap.view.tag];
    }
}


#pragma mark - setter
- (void)setSelectIndex:(NSUInteger)selectIndex{
    if (_selectIndex < 0 || _selectIndex >= self.itemTitles.count || selectIndex == _selectIndex){
        return;
    }
    [self updateHoverViewToIndex:selectIndex];
    _selectIndex = selectIndex;
//    [self setTitleSelected:YES atIndex:_selectIndex];
    [self updateItems];
}

#pragma mark - lazy & getter
- (UIView *)hoverView{
    if(!_hoverView){
        _hoverView = [[UIView alloc] initWithFrame:CGRectMake(0, self.scrollView.bounds.size.height - self.config.hoverHeight - self.config.hoverBottomOffset , self.config.hoverWidth, self.config.hoverHeight)];
        _hoverView.backgroundColor = self.config.hoverColor;
        _hoverView.layer.cornerRadius = self.config.hoverHeight/2.f;
    }
    return _hoverView;
}


@end
