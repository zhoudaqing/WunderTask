//
//  HTTabBarController.m
//  iOSFinancial
//
//  Created by Mr.Yang on 15/3/27.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "HTTabBarController.h"
#import "HTNavigationController.h"
#import "TaskListViewController.h"
#import "ManagerViewController.h"
#import "MeViewController.h"


@interface HTTabBarController ()

@end

@implementation HTTabBarController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tabBar.translucent = NO;
    
    self.viewControllers = [self subViewControllers];
    
    //  去掉顶部的阴影线
    self.tabBar.clipsToBounds = YES;
    
    [self changeShowdImageColor];
}

//  改变阴影线颜色
- (void)changeShowdImageColor
{
    CGRect rect = CGRectMake(0, 0, APPScreenWidth, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,HTHexColor(0xefeeee).CGColor);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self.tabBar setShadowImage:img];
    [self.tabBar setBackgroundImage:[[UIImage alloc]init]];
}

- (NSArray *)subViewControllers
{
    TaskListViewController *store = [[TaskListViewController alloc]init];
    store.tabBarItem = [self tabbarItemWithTitle:@"任务" andItemImage:@"home"];
    HTNavigationController *nav1 = [[HTNavigationController alloc] initWithRootViewController:store];
    nav1.isContentLight = YES;
    
    ManagerViewController *cart = [[ManagerViewController alloc]init];
    cart.tabBarItem = [self tabbarItemWithTitle:@"监督" andItemImage:@"moreDetail"];
    HTNavigationController *nav2 = [[HTNavigationController alloc] initWithRootViewController:cart];
    nav2.isContentLight = YES;
    
    MeViewController *find = [[MeViewController alloc]init];
    find.tabBarItem = [self tabbarItemWithTitle:@"我" andItemImage:@"myDetail"];
    HTNavigationController *nav3 = [[HTNavigationController alloc] initWithRootViewController:find];
    nav3.isContentLight = YES;
    
    return @[nav1, nav2, nav3];
}

- (UITabBarItem *)tabbarItemWithTitle:(NSString *)title andItemImage:(NSString *)imageStr
{
    UIImage *selectImage = HTImage(HTSTR(@"%@_selected", imageStr));
    UIImage *normalImage = HTImage(HTSTR(@"%@", imageStr));
    UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:normalImage selectedImage:selectImage];
    
    return tabBarItem;
}

@end
