//
//  ViewController.m
//  HZMenu
//
//  Created by Quanhai on 2019/4/4.
//  Copyright © 2019 Quanhai. All rights reserved.
//

#import "ViewController.h"
#import "HZMutiMenuView.h"
#import "Masonry.h"

@interface ViewController ()
<
UIScrollViewDelegate,
HZMutiItemMenuDelegate
>
@property (nonatomic, strong) UIScrollView * scrollView ; /**<  **/
@property (nonatomic, strong) HZMutiMenuView * menu1 ; /**<  **/
@property (nonatomic, strong) HZMutiMenuView * menu2 ; /**<  **/
@property (nonatomic, strong) NSArray <NSString *> * items ; /**<  **/
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.menu1];
    [self.view addSubview:self.menu2];
    
    [self.view addSubview:self.scrollView];
    for (int i = 0; i < self.items.count; i ++) {
        UIViewController *controller = [UIViewController new];
        controller.view.backgroundColor = [UIColor colorWithRed:125.f/255.f green:(255.f - 10*i)/255.f blue:89.f/255.f alpha:1];
        [self addChildViewController:controller];
        controller.view.frame = CGRectMake(i*self.scrollView.bounds.size.width, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
        [self.scrollView addSubview:controller.view];
    }
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.bounds.size.width*self.items.count, self.scrollView.bounds.size.height)];
}


#pragma mark - delegate
- (void)itemMenuView:(HZMutiMenuView *)itemMenuView selectItemAtIndex:(NSUInteger)index{
    [self.scrollView setContentOffset:CGPointMake(index*self.scrollView.bounds.size.width, 0) animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    self.menu1.progress = scrollView.contentOffset.x/scrollView.frame.size.width;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self.menu1 finishedProgress];
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    [self.menu1 finishedProgress];
}

#pragma mark - getter
- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height/2, self.view.bounds.size.width, self.view.bounds.size.height/2)];
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _scrollView.bounces = NO;
        _scrollView.showsVerticalScrollIndicator = false;
        _scrollView.showsHorizontalScrollIndicator = false;
    }
    return _scrollView;
}

- (HZMutiMenuView *)menu1{
    if (!_menu1) {
        _menu1 = [[HZMutiMenuView alloc] initWithFrame:CGRectMake(0, 40, self.view.bounds.size.width, 50.f) items:self.items icons:@[] config:^(HZMutiMenuConfig * _Nonnull config) {
            config.normalFont = [UIFont systemFontOfSize:14];
            config.highlightFont = [UIFont boldSystemFontOfSize:17];
            config.normalColor = [UIColor grayColor];
            config.highlightColor = [UIColor orangeColor];
            config.hoverWidth = 40.f;
            config.itemBackgroundColor = [UIColor groupTableViewBackgroundColor];
            config.iconBackgroundColor = [UIColor lightGrayColor];
        }];
        _menu1.delegate = self;
    }
    return _menu1;
}

- (HZMutiMenuView *)menu2{
    if (!_menu2) {
        _menu2 = [[HZMutiMenuView alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, 80.f) items:@[@"芒果芒果", @"苹果铅笔---", @"毒"] icons:nil config:^(HZMutiMenuConfig * _Nonnull config) {
            config.normalFont = [UIFont systemFontOfSize:14];
            config.highlightFont = [UIFont boldSystemFontOfSize:17];
            config.normalColor = [UIColor grayColor];
            config.highlightColor = [UIColor orangeColor];
            config.hoverWidth = 40.f;
            config.itemBackgroundColor = [UIColor groupTableViewBackgroundColor];
            config.isEqualWidth = YES;
        }];
    }
    return _menu2;
}

- (NSArray<NSString *> *)items{
    if (!_items) {
        _items = @[@"一个大蠢驴", @"AAABBBCD", @"芒果芒果", @"苹果铅笔---", @"毒"];
    }
    return _items;
}

@end
