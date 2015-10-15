//
//  ActionWebViewController.m
//  iOSFinancial
//
//  Created by Mr.Yang on 15/6/12.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "ActionWebViewController.h"
#import "BalanceViewController.h"
#import "InvitationFriendViewController.h"
#import "HTNavigationController.h"
#import "UIBarButtonExtern.h"

@interface ActionWebViewController () <UIWebViewDelegate>

@property (nonatomic, assign)   BOOL isNeedRedriect;
@property (nonatomic, copy)     NSString *redirectURL;

@end

@implementation ActionWebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoginSuccess) name:__USER_LOGIN_SUCCESS object:nil];
    
    [self addCloseBarbutton];
}

- (void)addCloseBarbutton
{
    if (self.navigationController.viewControllers.count == 1) {
        self.navigationItem.leftBarButtonItem = [UIBarButtonExtern closeBarButtonItem:@selector(closeButtonClicked:) andTarget:self];
    }
}

- (void)closeButtonClicked:(UIBarButtonItem *)buttonItem
{
    [self dismissViewController:^{
        
    }];
}

- (void)userLoginSuccess
{
    if (_isNeedRedriect) {
        
        self.url = HTURL(HTSTR(@"%@%@", jianDanWapServer, _redirectURL));
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
    NSString *theTitle=[webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    self.title = theTitle;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"URL:%@", request.URL);
    
    NSString *requestURL = [request.URL absoluteString];
    NSString *relativePath = [request.URL relativePath];
    relativePath = [[requestURL componentsSeparatedByString:@"://"] objectAtIndex:1];
    NSString *scheme = request.URL.scheme;
    if ([scheme rangeOfString:@"com.yyyy.jdlc"].length > 0) {
        if ([relativePath rangeOfString:@"extern"].length > 0) {
            //其它浏览器打开
            NSString *openURL = [self getParamAtIndex:1 inURL:requestURL];
            
            NSString *detailURL = [NSString stringWithFormat:@"%@/%@", jianDanWapServer, openURL];
            
            [[UIApplication sharedApplication] openURL:HTURL(detailURL)];
            
            _isNeedRedriect = NO;
            
            return NO;
            
        }else {
            //  ([scheme containsString:@"native"]
            //  本地的逻辑
            if ([relativePath rangeOfString:@"/login"].length > 0) {
                
                _redirectURL = [self getParamAtIndex:1 inURL:requestURL];
                
                _isNeedRedriect = YES;
                [self presentUserLoginViewController];
                
            }else if ([relativePath rangeOfString:@"/invite"].length > 0) {
                //  查看邀请人
                
                [self showInviteViewController];
                
            }else if ([relativePath rangeOfString:@"/yesx"].length > 0) {
                //  查看余额生息
                
                [self showBalanceViewController];
                
            }else {
                
            
            }
            
            return NO;
        }
        
    }
   
    _isNeedRedriect = NO;
    
    return YES;
}

- (NSString *)getParamAtIndex:(NSInteger)i inURL:(NSString *)urlStr
{
    NSArray *array = [urlStr componentsSeparatedByString:@"?url="];
    NSString *param = 0x0;
    
    if (array.count > i) {
        param = array[i];
    }
    
    /*
    array = [param componentsSeparatedByString:@"="];
    
    if (array.count  > 1) {
        param = array[1];
    }
    */

    return param;
}


- (void)showBalanceViewController
{
    BalanceViewController *balancevc = [[BalanceViewController alloc] initWithTableViewStyle:UITableViewStyleGrouped];
    HTNavigationController *nav = [[HTNavigationController alloc] initWithRootViewController:balancevc];
    
    [self presentViewController:nav animated:YES completion:nil];
    
}

- (void)showInviteViewController
{
    InvitationFriendViewController *invition = [[InvitationFriendViewController alloc] initWithTableViewStyle:UITableViewStyleGrouped];
    HTNavigationController *nav = [[HTNavigationController alloc] initWithRootViewController:invition];
    
    [self presentViewController:nav animated:YES completion:nil];
}


@end
