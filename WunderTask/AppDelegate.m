//
//  AppDelegate.m
//  iOSFinancial
//
//  Created by Mr.Yang on 15/3/26.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "AppDelegate.h"
#import "HTNavigationController.h"
#import "HTTabBarController.h"
#import "HTGuideManager.h"


@interface AppDelegate () <HTGuideManagerDelegate, UITabBarControllerDelegate>
{
    NSInteger _willSelectTab;
}

@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self initFinishLaunch:application andOption:launchOptions];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    self.window.rootViewController = self.tabBarController;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (HTTabBarController *)tabBarController
{
    if (!_tabBarController) {
        _tabBarController = [[HTTabBarController alloc] init];
    }
    
    return _tabBarController;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *token =
    [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""]stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    token = nil;
}

- (void)guideManagerWantDisappear:(HTGuideManager *)guideManager
{
    
}

- (void)initFinishLaunch:(UIApplication *)application  andOption:(NSDictionary *)launchOptions
{
    //  MARK:系统样式
    [self initAppStyle];
}

//  MARK: Setting
- (void)initAppStyle
{
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor],NSFontAttributeName : [UIFont systemFontOfSize:18]}];
    
    //  去掉tabbar底下的黑线 (顶部的阴影线 是 shoadowImage 造成的)
    [[UITabBar appearance] setTintColor:[UIColor jd_barTintColor]];
    
    //  修改navigation Bar底下的黑色线
    //    [[UINavigationBar appearance] setBarTintColor:[UIColor jt_barTintColor]];
    //[[UINavigationBar appearance] setShadowImage:HTImage(@"")];//[[UIImage alloc] init]
    
    //修改返回按钮图片
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBackIndicatorImage:[UIImage imageNamed:@"dismissIndicatior"]];
    [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:[UIImage imageNamed:@"dismissIndicatior"]];
    
    [[UITableView appearance] setSeparatorColor:[UIColor jd_lineColor]];
    
    [[UISwitch appearance] setOnTintColor:[UIColor jd_barTintColor]];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -160)
                                                         forBarMetrics:UIBarMetricsDefault];
}

@end
