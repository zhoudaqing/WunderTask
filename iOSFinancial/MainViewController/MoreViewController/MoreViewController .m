//
//  MoreViewController.m
//  iOSFinancial
//
//  Created by Mr.Yang on 15/4/15.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "MoreViewController.h"
#import "User.h"
#import "NameCertificationController.h"
#import "BindingPhoneNumberTableViewController.h"
#import "LogInPasswordTableViewController.h"
#import "PayPasswordTableViewController.h"
#import "IdeaSendViewController.h"
#import "AboutUsViewController.h"
#import "ButtonCell.h"
#import "HTBaseCell.h"
#import "LogOrRegViewController.h"
#import "HTNavigationController.h"


@interface MoreViewController ()

@property (nonatomic) NSArray *settingCellTitle;

@property (nonatomic) NSArray *settingCellIcon;

@end

@implementation MoreViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([User sharedUser].isLogin) {
        [self.tableView reloadData];
    }

}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"更多";
    
    _settingCellTitle =  @[@[@"实名认证"],@[@"绑定手机号码"],@[@"登录密码",@"支付密码"],@[@"意见反馈",@"关于我们"]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoginOut) name:__USER_LOGINOUT_SUCCESS object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoginIn) name:__USER_LOGIN_SUCCESS object:nil];
    
    //  主动通知用户信息刷新
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUserState) name:__USER_INFOMATION_REFRESH_NOTIFACTION object:nil];
    
    if ([User sharedUser].isLogin) {
        self.showRefreshHeaderView = YES;
        [self.refreshHeaderView refreshByManual];
    }
}

- (void)refreshUserState
{
    User *user = [User sharedUser];
    
    //  实名或者手机号正在认证中，则每次进来都要刷新一次
    if (user.real_name_status == UserNameAuthStateAuthing) {
        if (!self.refreshHeaderView.isRefreshing) {
            [self.refreshHeaderView refreshByManual];
        }
    }
}

- (void)refreshViewBeginRefresh:(MJRefreshBaseView *)baseView
{
    [self requestUserState];
}

- (void)requestUserState
{
    HTBaseRequest *request = [HTBaseRequest requestWithURL:[NSString more]];
    
    [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        
        NSDictionary *result = [request.responseJSONObject dictionaryForKey:@"result"];
        if (result) {
            [[User sharedUser] moreConfigWithCertificatedDic:result];
            [self.tableView reloadData];
        }
        
        [self.refreshHeaderView refreshContentInsetZero];
        [self.refreshHeaderView endRefreshing];
        
    } failure:^(YTKBaseRequest *request) {
        [self.refreshHeaderView refreshContentInsetZero];
        [self.refreshHeaderView endRefreshing];
    }];
    
}

#pragma mark - UserLogin

//  MARK:user Login out
- (void)userLoginOut
{
    self.showRefreshHeaderView = NO;
    self.tableView.contentInset = UIEdgeInsetsZero;
    [self.tableView reloadData];
}

- (void)userLoginIn
{
    self.showRefreshHeaderView = YES;
    [self.tableView reloadData];
}

#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.settingCellTitle.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 4) {
        return 1;
    }
    
    NSArray *array = self.settingCellTitle[section];
    return array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 4) {
        return 49.0f;
    }
    
    return 44.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 4) {
        ButtonCell *buttonCell = [[ButtonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        
        NSString *login = [User sharedUser].isLogin ? @"退出当前账号" : @"登录账号";
        buttonCell.submitText = login;
        
        return buttonCell;
    }
    
    static NSString * cellIdentifier = @"cellIdentifier";
    
     HTBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[HTBaseCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
        cell.detailTextLabel.textColor = [UIColor jd_settingDetailColor];
        cell.textLabel.textColor = [UIColor jd_globleTextColor];
    }
    
    cell.textLabel.text = self.settingCellTitle[indexPath.section][indexPath.row];
    
    cell.detailTextLabel.text = [self detailTextAtIndex:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    UIViewController *controller = nil;
    
    User *user = [User sharedUser];
    
        if (section == 3) {
            
            if (row == 1) {
                AboutUsViewController *ctr = [[AboutUsViewController alloc] initWithTableViewStyle:UITableViewStyleGrouped];
                controller = ctr;
            }else {
                IdeaSendViewController *ctr = [[IdeaSendViewController alloc]init];
                controller = ctr;
            }
            
        }else {
            
            if (!user.isLogin) {
                [self presentUserLoginViewController];
                return;
                
            }else {
                
                if (section == 0) {
                    if (user.real_name_status == UserNameAuthStateUnAuth ||
                        user.real_name_status == UserNameAuthStateFailed) {
                        
                        NameCertificationController *ctr= [[NameCertificationController alloc]init];
                        controller = ctr;
                        
                    }else {
                        switch (user.real_name_status) {
                            case UserNameAuthStateAuthed: [self showPromptMessage:@"真实姓名已经认证成功"]; break;
                            case UserNameAuthStateOutTime: [self showPromptMessage:@"姓名认证次数超出限制"]; break;
                            case UserNameAuthStateAuthing: [self showPromptMessage:@"认证中,请耐心等待"]; break;
                            default:
                                break;
                        }
                    }
                    
                }else if (section == 1) {
                    
                    if (user.userTelPhone.length != 11) {
                        BindingPhoneNumberTableViewController *ctr= [[BindingPhoneNumberTableViewController alloc]init];
                        controller = ctr;
                        
                    }else {
                        [self showPromptMessage:@"手机号码已经绑定成功"];
                        return;
                    }
                    
                }else if (section == 2) {
                    if (row == 0) {
                        LogInPasswordTableViewController *ctr= [[LogInPasswordTableViewController alloc]init];
                        controller = ctr;
                        
                    }else {
                        
                        //  手机号码的验证状态
                        if (user.userTelPhone.length != 11) {
                            
                            __weakSelf;
                            [self alertViewWithButtonsBlock:^NSArray *{
                                return @[@"绑定"];
                            } andHandleBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                if (buttonIndex == 1) {
                                    [weakSelf showBindPhoneViewController];
                                }
                                
                            } andMessage:@"请先绑定手机号"];
                            
                        }else {
                            PayPasswordTableViewController *ctr= [[PayPasswordTableViewController alloc]init];
                            controller = ctr;
                        }
                    }
                }else {
                    //  退出登录
                    [self showLoginOut];
                    return;
                }
        }
    }

    controller.title = self.settingCellTitle[section][row];
    controller.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:controller animated:YES];

}

- (void)showBindPhoneViewController
{
    BindingPhoneNumberTableViewController *ctr= [[BindingPhoneNumberTableViewController alloc] init];
    [self.navigationController pushViewController:ctr animated:YES];
}

- (void)showPromptMessage:(NSString *)message
{
    NSString *prompt = HTSTR(@"%@。如需修改请拨打客服电话:%@", message, kServicePhone_f);
    [self alertViewWithButtonsBlock:^NSArray *{
        return @[@"拨打"];
    } andHandleBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            // 拨打电话
            NSString *telphone = HTSTR(@"tel://%@",kServicePhone);
            [[UIApplication sharedApplication] openURL:HTURL(telphone)];
        }
        
    } andMessage:prompt];
}

- (void)showLoginOut
{
    [self alertViewWithButtonsBlock:^NSArray *{
        return @[@"确定"];
    } andHandleBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            [[User sharedUser] doLoginOut];
        }
        
    } andMessage:@"确定要退出吗?"];
}

- (NSString *)detailTextAtIndex:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    User *user = [User sharedUser];
    
    if (section == 0) {
        if (user.isLogin) {
            return user.real_name_status_description;
            
        }else {
            return @"未登录";
        }
        
    }else if (section == 1) {
        if (user.isLogin) {
            if (user.userTelPhone.length > 0) {
                return user.userVirsulPhone;
            }else {
                return @"未绑定";
            }
            
        }else {
            return @"未登录";
        }
        
    }else if (section == 2) {
        return @"修改";
    }
    
    return nil;
}

@end
