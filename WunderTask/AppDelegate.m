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
#import "FirstTableViewController.h"
#import <objc/runtime.h>
#import "YTKNetworkConfig.h"
#import "MoreViewController.h"
#import "InvestSelectionViewController.h"
#import "MyAccountViewController.h"
#import "HTGestureViewController.h"
#import "LogOrRegViewController.h"
#import "HTGuideManager.h"
#import "SecurityStrategy.h"
#import "HTVersionManager.h"
#import "UIAlertView+RWBlock.h"
#import "AdverViewController.h"
#import "InvestViewController.h"
#import "InvestSelectionViewController.h"
#import "InvestMarketDetailController.h"

//  友盟组件
#import "umsocial.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"
#import "UMSocialSinaHandler.h"
#import "MobClick.h"
#import "ActionWebViewController.h"

//  腾讯bug反馈
#import <Bugly/CrashReporter.h>

#import "UMessage.h"


#define UMSYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define _IPHONE80_ 80000

@interface AppDelegate () <HTGuideManagerDelegate, UITabBarControllerDelegate>
{
    NSInteger _willSelectTab;
}

@property (nonatomic)  HTTabBarController *tabBarController;


@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //  MARK:推送设置
    [self setUMengpushSetting:launchOptions];
    
    //  MARK:友盟设置
    [self setUMengSetting];
    
    //  MARK:崩溃监测
    [self setBuglyReport];

    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];

    [self setAppStyle];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    self.window.rootViewController = self.tabBarController;

    //  默认进项目列表
    self.tabBarController.selectedIndex = 1;
    _willSelectTab = 1;
    
    [self.window makeKeyAndVisible];
    
    //  MARK:远程推送
    NSDictionary * userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (userInfo) {
        [self handleRemoteNotification:userInfo];
    }
    
    //  MARK:显示引导页
    [HTGuideManager showGuideViewWithDelegate:self];
    
    //  MARK:登陆成功后，设置用户手势解锁密码
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentGestureViewController) name:__USER_LOGIN_SUCCESS object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoginAccessTokenOutDate:) name:__USER_ACCESSTOKEN_OUTDATE object:nil];
    
    [self checkIsUserLoginOutOfDate];
    
    return YES;
}

//  ----------------------------------------------------------------------------------------------------

//  MARK:UMeng Key and setting
- (void)setUMengpushSetting:(NSDictionary *)launchOptions
{
    //set AppKey and AppSecret
    [UMessage startWithAppkey:@"54f52161fd98c52c280001a0" launchOptions:launchOptions];
    [UMessage setAutoAlert:NO];
    
    if(UMSYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
    {
        //register remoteNotification types （iOS 8.0及其以上版本）
        UIMutableUserNotificationAction *action1 = [[UIMutableUserNotificationAction alloc] init];
        action1.identifier = @"action1_identifier";
        action1.title=@"Accept";
        action1.activationMode = UIUserNotificationActivationModeForeground;//当点击的时候启动程序
        
        UIMutableUserNotificationAction *action2 = [[UIMutableUserNotificationAction alloc] init];  //第二按钮
        action2.identifier = @"action2_identifier";
        action2.title=@"Reject";
        action2.activationMode = UIUserNotificationActivationModeBackground;//当点击的时候不启动程序，在后台处理
        //需要解锁才能处理，如果action.activationMode = UIUserNotificationActivationModeForeground;则这个属性被忽略；
        action2.authenticationRequired = YES;
        
        action2.destructive = YES;
        
        UIMutableUserNotificationCategory *categorys = [[UIMutableUserNotificationCategory alloc] init];
        categorys.identifier = @"category1";//这组动作的唯一标示
        [categorys setActions:@[action1,action2] forContext:(UIUserNotificationActionContextDefault)];
        
        UIUserNotificationSettings *userSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert
                                                                                     categories:[NSSet setWithObject:categorys]];
        [UMessage registerRemoteNotificationAndUserNotificationSettings:userSettings];
        
    } else{
        //register remoteNotification types (iOS 8.0以下)
        [UMessage registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge
         |UIRemoteNotificationTypeSound
         |UIRemoteNotificationTypeAlert];
    }
    
    //for log
    //[UMessage setLogEnabled:YES];
    
}

//  远程推送
- (void)handleRemoteNotification:(NSDictionary *)userInfo
{
    NSString *model = [userInfo stringForKey:@"model"];
    NSString *action = [userInfo stringForKey:@"action"];
    NSString *target = [userInfo stringForKey:@"object"];
    
    if ([model isEqualToString:@"discover"]) {
        //  open webview
        [self showWebViewController:target];
        
    }else if ([model isEqualToString:@"project"]) {
        //  open project detail
        if (action.length > 0) {
            [self showProjectDetailViewController:target];
            
        }else {
            [self showInvestProjectsViewController];
        }
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [UMessage registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [UMessage didReceiveRemoteNotification:userInfo];
    
    if ([application applicationState] == UIApplicationStateInactive) {
        [self handleRemoteNotification:userInfo];
        
    }else {
        //  MARK:应用内前台运行时收到推送 暂不处理
        
    }
}

- (void)showWebViewController:(NSString *)detailURL
{
    ActionWebViewController *actionWeb = [[ActionWebViewController alloc] init];
    HTNavigationController *nav = [[HTNavigationController alloc] initWithRootViewController:actionWeb];
    actionWeb.url = HTURL(detailURL);
    
    [self.tabBarController presentViewController:nav animated:YES completion:^{
    
    }];
}

- (void)showInvestProjectsViewController
{
    InvestSelectionViewController *invest = [[InvestSelectionViewController alloc] init];
    HTNavigationController *nav = [[HTNavigationController alloc] initWithRootViewController:invest];
    
    [self.tabBarController presentViewController:nav animated:YES completion:nil];
}

- (void)showProjectDetailViewController:(NSString *)projectID
{
    InvestMarketDetailController *invest = [[InvestMarketDetailController alloc] initWithTableViewStyle:UITableViewStyleGrouped];
    HTNavigationController *nav = [[HTNavigationController alloc] initWithRootViewController:invest];
    invest.projectID = projectID;
    invest.isRedeem = NO;
    
    [self.tabBarController presentViewController:nav animated:YES completion:nil];
}

//  ----------------------------------------------------------------------------------------------------

//  检测用户没设置手势密码的时候是否超时
- (void)checkIsUserLoginOutOfDate
{
    User *user = [User sharedUser];
    
    //  用户登陆了，但是没有设置手势密码
    if (![HTGestureViewController isHaveSetGesturePass] && [User sharedUser].isLogin) {
        //  没设置手势密码
        
        if ([user isUserLoginOutTime]) {
            //  超时
            [user doLoginOut];
            
        }else {
            //  设置手势密码
            [self presentGestureViewController];
        }
    }
}

//  MARK:User AccessToken Outdate
- (void)userLoginAccessTokenOutDate:(NSNotification *)notifaction
{
    NSDictionary *error = notifaction.object;
    NSString *message = [error stringForKey:@"message"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert setCompletionBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 0) {
            [self dismissControllerAndShowLoginVC];
            
            //  加入用户在账号页面，则跳到投资列表页
            if (self.tabBarController.selectedIndex == __UserAccountIndex) {
                [self.tabBarController setSelectedIndex:0];
            }
        }
    }];
    
    [alert show];
}

//  将presentViewController 收回
- (void)dismissControllerAndShowLoginVC
{
    UIViewController *presentViewController = self.tabBarController.presentedViewController;
    
    if (presentViewController) {
        [presentViewController dismissViewControllerAnimated:NO completion:^ {
            [self presentLoginViewController];
        }];
        
    }else {
        [self presentLoginViewController];
    }
}

#pragma mark GuideManager Delegate
- (void)guideManagerWantDisappear:(HTGuideManager *)guideManager
{
    [guideManager makeGuideViewDisappear];
    guideManager = nil;
}

#pragma mark - tabbarDelegate

//  FIXME:后期需要更改维护
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    
    NSInteger willSelect = [tabBarController.viewControllers indexOfObject:viewController];
    _willSelectTab = willSelect;
    
    if (willSelect == tabBarController.selectedIndex) {
        return NO;
    }
    
    if (tabBarController.selectedIndex == __UserAccountIndex) {
        //  如果是从账户页面到其它页面，则刷新账户登录时间,防止用户在操作账户页面时
        [[User sharedUser] refreshUserLoginTime];
    }
    
    if (willSelect != __UserAccountIndex) {
        
        /*
        if ([viewController isKindOfClass:[MoreViewController class]]) {
            MoreViewController *vc = (MoreViewController *)viewController;
            [vc refreshUserState];
        }*/
        
        _showedViewController = (HTNavigationController *)viewController;
        return YES;
    }
    
    //  如果选中的时账户页面，则需要先登录
    User *user = [User sharedUser];
    if (!user.isLogin) {
        
        [self presentLoginViewController];
        
        return NO;
        
    }else {
        if ([user isUserLoginOutTime]) {
            //  显示手势密码
            [self presentGestureViewController];
            return NO;
        }else {
            //  刷新用户登录时间，防止用户在使用我的账户的时候过期
            [user refreshUserLoginTime];
        }
    }
    
    _showedViewController = (HTNavigationController *)viewController;
    
    return YES;
}

//  MARK:显示手势密码
- (void)presentGestureViewController
{
    HTGestureViewController *gesture = [[HTGestureViewController alloc] init];
    HTNavigationController *nav = [[HTNavigationController alloc] initWithRootViewController:gesture];

    NSInteger index = self.tabBarController.selectedIndex;
    
    if (__UserAccountIndex == index) {
        //  不允许返回
        gesture.shouldCancel = NO;
    }
    
    [self.tabBarController presentViewController:nav animated:__UserAccountIndex == index ? NO : YES completion:^ {
        
    }];
}

//  MARK:显示登录对话框
- (void)presentLoginViewController
{
    LogOrRegViewController *loginVC = [[LogOrRegViewController alloc] init];
    HTNavigationController *nav = [[HTNavigationController alloc] initWithRootViewController:loginVC];
    [loginVC addHeadBtnType:Login];
    
    [self.tabBarController presentViewController:nav animated:YES completion:^{
        
    }];
}

#pragma mark - TabbarController

- (HTTabBarController *)tabBarController
{
    if (!_tabBarController) {
        _tabBarController = [[HTTabBarController alloc] init];
        _tabBarController.delegate = self;
        [_tabBarController setViewControllers:[self subViewControllers]];
    }
    
    return _tabBarController;
}

- (void)changeTabbarIndex
{
    HTNavigationController *controller = [_tabBarController.viewControllers objectAtIndex:_willSelectTab];
    _showedViewController = controller;
    [_tabBarController setSelectedIndex:_willSelectTab];
}

- (NSArray *)subViewControllers
{
    NSMutableArray *array = [@[] mutableCopy];
    
    AdverViewController *adver = [[AdverViewController alloc] initWithTableViewStyle:UITableViewStyleGrouped];
    adver.title = @"发现";
    HTNavigationController *navigationController1 = [[HTNavigationController alloc] initWithRootViewController:adver];
    navigationController1.tabBarItem = [self tabbarItemWithTitle:@"发现" andItemImage:@"discover"];
    [array addObject:navigationController1];
    _showedViewController = navigationController1;
    
    InvestSelectionViewController *investController = [[InvestSelectionViewController alloc] init];
    investController.title = @"理财";
    HTNavigationController *navigationController2 = [[HTNavigationController alloc] initWithRootViewController:investController];
    navigationController2.tabBarItem  = [self tabbarItemWithTitle:@"理财" andItemImage:@"invest"];
    
    [array addObject:navigationController2];
    
    MyAccountViewController *accountController = [[MyAccountViewController alloc] initWithTableViewStyle:UITableViewStyleGrouped];
    accountController.title = @"我的账户";
    HTNavigationController *navigationController3 = [[HTNavigationController alloc] initWithRootViewController:accountController];
    navigationController3.tabBarItem = [self tabbarItemWithTitle:@"账户" andItemImage:@"myDetail"];
    
    [array addObject:navigationController3];
    
    MoreViewController *moreVc = [[MoreViewController alloc] initWithTableViewStyle:UITableViewStyleGrouped];
    HTNavigationController *navigationController4 = [[HTNavigationController alloc] initWithRootViewController:moreVc];
    navigationController4.tabBarItem = [self tabbarItemWithTitle:@"更多" andItemImage:@"moreDetail"];
    
    [array addObject:navigationController4];
    
    return array;
}

- (UITabBarItem *)tabbarItemWithTitle:(NSString *)title andItemImage:(NSString *)imageStr
{
    UIImage *selectImage = HTImage(HTSTR(@"%@_selected", imageStr));
    UITabBarItem *tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:HTImage(imageStr) selectedImage:selectImage];
    
    return tabBarItem;
}

#pragma mark - Appdelegate

//UMeng回调专用
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return  [UMSocialSnsService handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return  [UMSocialSnsService handleOpenURL:url];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSInteger index = self.tabBarController.selectedIndex;
    if (__UserAccountIndex == index) {
        //  刷新用户的登陆时间（如果用户操作的是账户页面则重新记录一遍用户时间,防止用户来回切换过期）
        [[User sharedUser] refreshUserLoginTime];
        
        //  如果是在账户页面，且不是登陆或者手势验证页面
        if (self.tabBarController.presentedViewController == nil) {
            [SecurityStrategy addBlurEffect];
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    User *user = [User sharedUser];
    // 设置用户ID (崩溃检测)
    if (user.isLogin) {
        [[CrashReporter sharedInstance] setUserId:[User sharedUser].userID];
    }
    
    [SecurityStrategy removeBlurEffect];
    
    //  检测版本
    [[HTVersionManager sharedManager] checkAppversion];
    
    if ([user isUserLoginOutTime]) {
        NSInteger index = self.tabBarController.selectedIndex;
        if (__UserAccountIndex == index) {
            //  肯定是登陆且已经设置过手势密码
            [self presentGestureViewController];
        }
    }
}

#pragma mark -

//  MARK: Setting

- (void)setAppStyle
{
    [[UINavigationBar appearance] setBackgroundImage:HTImage(@"navitationBar") forBarMetrics:UIBarMetricsDefault];
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor],NSFontAttributeName : [UIFont systemFontOfSize:18]}];
    
    [[UITabBar appearance] setTintColor:[UIColor jd_barTintColor]];
    
    //  修改navigation Bar底下的黑色线
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    
    //修改返回按钮图片
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBackIndicatorImage:[UIImage imageNamed:@"dismissIndicatior"]];
    [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:[UIImage imageNamed:@"dismissIndicatior"]];
    
    [[UITableView appearance] setSeparatorColor:[UIColor jd_lineColor]];
    
    [[UISwitch appearance] setOnTintColor:[UIColor jd_barTintColor]];
    
}

//   友盟设置
- (void)setUMengSetting
{
    //  友盟页面统计
    [MobClick startWithAppkey:UMengShareAppKey reportPolicy:BATCH   channelId:nil];
    
    //  友盟分享
    [UMSocialData setAppKey:UMengShareAppKey];
    
    [UMSocialConfig hiddenNotInstallPlatforms:nil];
    
    //  设置微信AppId、appSecret，分享url
    [UMSocialWechatHandler setWXAppId:WeiXinAppKey appSecret:WeiXinAppSecreat url:kWebServiceURL];
    
    //  设置分享到QQ/Qzone的应用Id，和分享url 链接
    [UMSocialQQHandler setQQWithAppId:QQAppId appKey:QQAppKey url:kWebServiceURL];
    
    //打开新浪微博的SSO开关，设置新浪微博回调地址，这里必须要和你在新浪微博后台设置的回调地址一致。
    //若在新浪后台设置我们的回调地址，“http://sns.whalecloud.com/sina2/callback”，这里可以传nil
    [UMSocialSinaHandler openSSOWithRedirectURL:nil];
}

//  设置bug报告
- (void)setBuglyReport
{
    //  版本渠道信息
    [[CrashReporter sharedInstance] setChannel:__APP_CHANNEL];
    //  合并上传
    [[CrashReporter sharedInstance] setExpMergeUpload:YES];
    //  设置appId
    [[CrashReporter sharedInstance] installWithAppId:__BUGLY_APP_ID];
    //  打开Log
    [[CrashReporter sharedInstance] enableLog:YES];
}

@end
