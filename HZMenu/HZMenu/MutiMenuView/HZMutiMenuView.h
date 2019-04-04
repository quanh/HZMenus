//
//  HZMutiMenuView.h
//  LZM
//
//  Created by Quanhai on 2019/1/17.
//  Copyright © 2019 yuchun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class HZMutiMenuView;
@protocol HZMutiItemMenuDelegate<NSObject>
- (void)itemMenuView:(HZMutiMenuView *)itemMenuView selectItemAtIndex:(NSUInteger)index;
- (void)itemMenuView:(HZMutiMenuView *)itemMenuView selectIconAtIndex:(NSUInteger)index;
@end


typedef NS_ENUM(NSUInteger, HZMutiIconType) {
    HZMutiIconTypeAlignRight = 0,       // 默认icon 在右侧排列
    HZMutiIconTypeAlignLeft,            // 默认icon 在左侧排列
    HZMutiIconTypeNone,                 // 默认没有icon
};

typedef NS_ENUM(NSUInteger, HZMutiHoverType) {
    HZMutiHoverTypeNone = 0,  // 滑块样式， 直接平移
    HZMutiHoverTypeStickiness,   // 粘性滑块样式
};

typedef NS_ENUM(NSUInteger, HZMutiItemStyle) {
    HZMutiItemStyleEqualWidthAlignCenter = 0,   // 每个item等距， 在不超出最大宽度时占满最大宽度， 超出时按照宽度
    HZMutiItemStyleEqualWidthAlignLeft,         // 每个item 等距， 按照宽度从左到右排列
    HZMutiItemStyleSizeFitAlignLeft,            // 每个item 自适应宽度， 按照宽度从左到右
};


@interface HZMutiMenuConfig : NSObject
// icon
@property (nonatomic, assign) HZMutiIconType iconType ; /**< icon type, 默认为0 **/
@property (nonatomic, assign) CGFloat iconMargin ; /**< type left 时为leftMargin, right时为 rightMargin **/
@property (nonatomic, strong) UIColor * iconTitleColor ; /**< icon 标题颜色, 默认 333333 **/
@property (nonatomic, strong) UIFont * iconTitleFont ; /**< icon title font, 默认 14  **/
@property (nonatomic, strong) UIColor * iconBackgroundColor ; /**< 底色, 默认为白色 **/
@property (nonatomic, strong) NSArray <NSNumber *> * iconWidthArray ; /**< icon 的宽度列表, 默认 44.f **/
// item
@property (nonatomic, strong) UIColor * itemBackgroundColor ; /**< 底色, 默认为白色 **/
@property (nonatomic, strong) UIColor * normalColor ; /**< 普通样式颜色, 默认为#666666 **/
@property (nonatomic, strong) UIColor * highlightColor ; /**< 高亮样式颜色, 默认 #4191f1 **/
@property (nonatomic, strong) UIFont * normalFont ; /**< 普通样式font, 默认15  **/
@property (nonatomic, strong) UIFont * highlightFont ; /**< 高亮样式font , 默认16**/
@property (nonatomic, assign) BOOL isEqualWidth ; /**< item是否等距均分, 宽度不超过最大宽度时YES才会生效, 默认为NO **/
@property (nonatomic, assign) CGFloat itemWidth ; /**< item的宽度， 默认为0 即自适应 >0 会生效 **/
@property (nonatomic, assign) CGFloat itemTopMargin ; /**< item 距离顶部距离, 默认为0 **/
@property (nonatomic, assign) CGFloat leftMargin ; /**< 左边距, 默认为 15.f **/
@property (nonatomic, assign) CGFloat rightMargin ; /**< 右边距, 默认为 15.f **/
@property (nonatomic, assign) CGFloat itemSpace ; /**< item之间的距离, 默认为 8.f **/
@property (nonatomic, assign) HZMutiItemStyle itemStyle ; /**< 默认为0 **/
// hover 滑块
@property (nonatomic, assign) BOOL isHoverHidden ; /**< 底部滑动条是否隐藏, 默认为NO **/
@property (nonatomic, assign) HZMutiHoverType hoverType ; /**< 滑块类型， 默认为直接平移 0 **/
@property (nonatomic, assign) CGFloat hoverWidth ; /**< 底部滑块的宽度, 默认为 16 **/
@property (nonatomic, assign) CGFloat hoverHeight ; /**< 底部滑块高度, 默认为 1.5f **/
@property (nonatomic, assign) CGFloat hoverBottomOffset ; /**< 底部滑块距离底部间距， 默认为0 **/
@property (nonatomic, strong) UIColor * hoverColor ; /**< yanse **/
// seprator 分割线
@property (nonatomic, assign) BOOL isSepratorShow ; /**< 默认为NO, 即隐藏 **/
@property (nonatomic, strong) UIColor * sepratorColor ; /**< 分割线颜色， 默认为 groupTableViewBackgroundColor **/

+ (instancetype)defaultConfig;

@end


// version 0.1.0 - 2019.1.15
@interface HZMutiMenuView : UIView

@property (nonatomic, strong, readonly) HZMutiMenuConfig * config ; /**< 设置 **/
@property (nonatomic, assign) NSUInteger selectIndex ; /**< 默认选择index **/
@property (nonatomic, assign) CGFloat progress; /**<0.0 ~ titles count - 1 f*/
@property (nonatomic, strong) UIScrollView * scrollView ; /**< 存放items视图 **/
@property (nonatomic, weak) id <HZMutiItemMenuDelegate> delegate ; /**< item and icon action delegate **/


/**
 HZMutiMenuScrollView 初始化方法

 @param frame frame
 @param items 分组名称数组
 @return 默认config 状态下的 HZMutiMenuScrollView
 */
- (instancetype)initWithFrame:(CGRect)frame items:(NSArray <NSString *> *)items;

/**
 HZMutiMenuScrollView 初始化方法1

 @param frame frame
 @param items 分组名称数组
 @param icons 按钮图标/ 文字 数组, 可以是图标名+ 文字名, v0.1.0 只支持 imageNamed 形式
 @return 默认config 状态下的 HZMutiMenuScrollView
 */
- (instancetype)initWithFrame:(CGRect)frame items:(NSArray <NSString *> *)items icons:(NSArray <NSString *> *)icons;

/**
 HZMutiMenuScrollView 初始化方法2

 @param frame frame
 @param items 分组名称数组
 @param icons 按钮图标/ 文字 数组, 可以是图标名+ 文字名, v0.1.0 只支持 imageNamed 形式
 @param configration 默认设置
 @return config 状态下的 HZMutiMenuScrollView
 */
- (instancetype)initWithFrame:(CGRect)frame items:(NSArray<NSString *> *)items icons:(NSArray<NSString *> *)icons config:(void (^)(HZMutiMenuConfig *config))configration;


/**
 HZMutiMenuScrollView 外部切换 item 的方法
** 正常使用是在外部的scrollViewDidScroll 方法内计算index ， 然后调用此方法
 
 @param index item 的index
 */
- (void)updateHoverViewToIndex:(NSInteger)index; /**< HZMutiHoverTypeDefault 在ScrollViewDidScroll 调用 **/



/**
 避免出现跨分割时字体颜色不正常, 滑动结束调用
 */
- (void)finishedProgress;


@end

NS_ASSUME_NONNULL_END
