//
//  ReturnMoneyDetailViewController.m
//  iOSFinancial
//
//  Created by Mr.Yan on 15/4/29.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "ReturnMoneyDetailViewController.h"
#import "ReturnMoneyDetailViewCell.h"
#import "RedeemViewController.h"
#import "PdfWebViewController.h"

/*!
 @header        ReturnMoneyDetailViewController
 @abstract
 @discussion    暂时不使用，新本版中可能使用所以暂留，我的账户--剩余回款--回款详情
 */

@interface ReturnMoneyDetailViewController ()<RedeemViewDelegate>
{
    NSArray *_redeenArray;
    NSDictionary *_redeenDict;
    BOOL isFirstReturn;
}
/** 项目总金额 */
@property (nonatomic)UILabel *allMoneyLable;

/** 完成时间 */
@property (nonatomic)UILabel *finishTimeLable;

/** 担保方 */
@property (nonatomic)UILabel *guaranteeLable;

/** 项目类型 */
@property (nonatomic)UILabel *projectType;


@end

@implementation ReturnMoneyDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"查看详情";
    isFirstReturn = YES;
    
    [self.tableView removeFromSuperview];
    __weakSelf;
    [self.loadingStateView setTouchBlock:^(LoadingStateView *view, LoadingState state){
        [weakSelf setNetWork];
    }];
    
    [self showLoadingViewWithState:LoadingStateLoading];
    
    [self setNetWork];
    
}

- (void)setNetWork
{
    HTBaseRequest *request = [HTBaseRequest requestWithURL:[NSString stringWithFormat:@"%@%@?pid=%@",[NSString projectsRelationReback],self.redeenModel.ipid,self.redeenModel.pid]];
    [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        [self removeLoadingView];
        NSDictionary *result = [request.responseJSONObject dictionaryForKey:@"result"];
        if (result) {
            _redeenArray = [result arrayForKey:@"data"];
        }
        [self.view addSubview:self.tableView];
        self.tableView.frame = CGRectMake(self.tableView.origin.x, self.tableView.origin.y, APPScreenWidth, APPScreenHeight - 44);
        
        if (self.redeenModel.i == 0 && self.redeenModel.can_redeem) {
            // 添加提前赎回按钮
            UIButton * aheadOfTimeBtn =[Sundry BigBottomBtnWithTitle:@"提前赎回"];
            [aheadOfTimeBtn addTarget:self action:@selector(redeem) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:aheadOfTimeBtn];
        }
       
        
    } failure:^(YTKBaseRequest *request) {
        
        [self showLoadingViewWithState:LoadingStateNetworkError];
        
        
    }];
    
}


#pragma -TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_redeenArray.count == 0) {
        return 1;
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0 &&_redeenArray.count == 0) {
        
        if (!self.redeenModel.isMcc_id) {
            return 1;
        }
        
        return 2;
    }
    
    if (_redeenArray.count != 0 && section == 1) {
        
        if (!self.redeenModel.isMcc_id) {
            return 1;
        }
        return 2;
    }
    return _redeenArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0&&_redeenArray.count != 0) {
        ReturnMoneyDetailViewCell *cell = [[ReturnMoneyDetailViewCell alloc]init];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSDictionary *dic = _redeenArray[indexPath.row];
        cell.times = [[dic stringIntForKey:@"reback_time"] intValue] + 1;
        cell.time = [[dic stringForKey:@"reback_date"] substringToIndex:11];
        cell.returnMoney = [dic stringFloatForKey:@"reback_capital"];
        cell.interests = [dic stringFloatForKey:@"reback_interest"];
        cell.returnStatus = [dic stringForKey:@"is_reback"];
        [cell addView];
        
        if (indexPath.row == _redeenArray.count - 1) {
            _redeenDict = dic;
        }
        
        return cell;
    }else
    {
        static NSString *identifier = @"ReturnMoneyDetailIdentifier";
        HTBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell) {
            cell = [[HTBaseCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            if (indexPath.row == 0) {
                cell.textLabel.text = @"查看合同";
            }else
            {
                cell.textLabel.text = @"收购承诺书";
            }
        }
        return cell;
    }
    

}

- (UITableView *)tableViewWithStyle:(UITableViewStyle)tableViewStyle
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero
                                                  style:UITableViewStyleGrouped];
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.frame = self.view.frame;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        //  去掉空白多余的行
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    
    return _tableView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1||_redeenArray.count == 0) {
        return 44;
    }
    return 79.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 155.0f;
    }
    return 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 &&_redeenArray.count == 0) {
        
        if (indexPath.row == 0)
        {
            [self requestWith:[NSString stringWithFormat:@"%@%@&id=%@",[NSString agreement],self.redeenModel.agreement_type,self.redeenModel.ipid]];
        }else
        {
            [self pushViewVcWiht:@"收购承诺书" wihtUrl:@"https://www.jiandanlicai.com/web/pdf/%E6%94%B6%E8%B4%AD%E6%89%BF%E8%AF%BA%E4%B9%A6.pdf"];
        }
        
    }else if (_redeenArray.count != 0 && indexPath.section == 1) {
        
        if (indexPath.row == 0)
        {
            [self requestWith:[NSString stringWithFormat:@"%@%@&id=%@",[NSString agreement],self.redeenModel.agreement_type,self.redeenModel.ipid]];
        }else
        {
            [self pushViewVcWiht:@"收购承诺书" wihtUrl:@"https://www.jiandanlicai.com/web/pdf/%E6%94%B6%E8%B4%AD%E6%89%BF%E8%AF%BA%E4%B9%A6.pdf"];
        }
    }

}

- (void)requestWith:(NSString *)url
{
    [self showHudWaitingView:@"加载中......"];
    HTBaseRequest *request = [HTBaseRequest requestWithURL:url];
    [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        NSDictionary *result = [request.responseJSONObject dictionaryForKey:@"result"];
        [self removeHudInManaual];
        if (result) {
            NSString *url = [result stringForKey:@"download_link"];
            [self pushViewVcWiht:@"查看合同" wihtUrl:url];
        }else
        {
            [self showHudAuto:@"数据修复中,请稍后再试"];
        }
        
    } failure:^(YTKBaseRequest *request) {
        [self showHudErrorView:PromptTypeError];
    }];
}

- (void)pushViewVcWiht:(NSString *)title wihtUrl:(NSString *)url
{
    PdfWebViewController *vc = [[PdfWebViewController alloc] init];
    vc.title = title;
    vc.url = url;
    [self.navigationController pushViewController:vc animated:YES];

}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return [self headerView];
    }
    return nil;
}


- (UIView *)headerView
{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, APPScreenWidth, 155)];
    headerView.backgroundColor = [UIColor jd_backgroudColor];
    UIView *whiteBcak = [[UIView alloc]initWithFrame:CGRectMake(0, 10, APPScreenWidth, 135)];
    whiteBcak.backgroundColor = HTWhiteColor;
    for (int i = 0; i<2; i++) {
        UIView *rimline = [Sundry  rimLine];
        rimline.frame = CGRectMake(0, i*135, APPScreenWidth, 0.5);
        [whiteBcak addSubview:rimline];
    }
    [headerView addSubview:whiteBcak];
    
    UILabel *projecktInforLable = [[UILabel alloc]initWithFrame:CGRectMake(15, 15, APPScreenWidth, 15.0)];
    projecktInforLable.text = @"项目信息";
    projecktInforLable.font = [UIFont systemFontOfSize:15.0];
    [whiteBcak addSubview:projecktInforLable];
    
    UILabel *allMoneyTitle = [[UILabel alloc]initWithFrame:CGRectMake(15, projecktInforLable.bottom + 15, 6 * 13.0, 13)];
    allMoneyTitle.text = @"项目总金额:";
    allMoneyTitle.font = [UIFont systemFontOfSize:13.0];
    [whiteBcak addSubview:allMoneyTitle];
    self.allMoneyLable.frame = CGRectMake(allMoneyTitle.right, allMoneyTitle.origin.y, APPScreenWidth, 13.0);
    self.allMoneyLable.text = self.redeenModel.loan_money;
    [whiteBcak addSubview:self.allMoneyLable];
    
    UILabel *finishTimeTitle = [[UILabel alloc]initWithFrame:CGRectMake(15, allMoneyTitle.bottom + 10, 7 * 13, 13.0)];
    finishTimeTitle.font = [UIFont systemFontOfSize:13.0];
    finishTimeTitle.text = @"募资完成时间:";
    [whiteBcak addSubview:finishTimeTitle];
    self.finishTimeLable.frame = CGRectMake(finishTimeTitle.right, finishTimeTitle.origin.y, APPScreenWidth, 13.0);
    self.finishTimeLable.text = self.redeenModel.done_deal_time;
    [whiteBcak addSubview:self.finishTimeLable];
    
    UILabel *guaranteeLableTitle = [[UILabel alloc]initWithFrame:CGRectMake(15, finishTimeTitle.bottom + 10, 4 * 13, 13.0)];
    guaranteeLableTitle.text = @"担保方:";
    guaranteeLableTitle.font = [UIFont systemFontOfSize:13.0];
    [whiteBcak addSubview:guaranteeLableTitle];
    self.guaranteeLable.frame = CGRectMake(guaranteeLableTitle.right, guaranteeLableTitle.origin.y, APPScreenWidth, 13.0);
    self.guaranteeLable.text = self.redeenModel.mcc_name;
    [whiteBcak addSubview:self.guaranteeLable];
    
    UILabel *projectTypeTitle = [[UILabel alloc]initWithFrame:CGRectMake(15, guaranteeLableTitle.bottom + 10, 5 * 13, 13)];
    projectTypeTitle.text = @"项目类型:";
    projectTypeTitle.font = [UIFont systemFontOfSize:13.0];
    [whiteBcak addSubview:projectTypeTitle];
    self.projectType.frame = CGRectMake(projectTypeTitle.right, projectTypeTitle.origin.y, APPScreenWidth, 13.0);
    self.projectType.text = self.redeenModel.pro_type;
    [whiteBcak addSubview:self.projectType];
    
    
    return headerView;
}


// 点击提前赎回按钮的操作
- (void)redeem
{
    RedeemViewController *redeemVC = [[RedeemViewController alloc]init];
    redeemVC.redeenModel = self.redeenModel;
    redeemVC.delegate = self;
    [self.navigationController pushViewController:redeemVC animated:YES];
}

- (void)selfDissMiss
{
    [self.delegate selfDissMiss];
}

- (UILabel *)allMoneyLable
{
    if (!_allMoneyLable) {
        _allMoneyLable = [[UILabel alloc]init];
        _allMoneyLable.font = [UIFont systemFontOfSize:13.0];
        _allMoneyLable.textColor = [UIColor jd_barTintColor];
    }
    return _allMoneyLable;
}

- (UILabel *)finishTimeLable
{
    if (!_finishTimeLable) {
        _finishTimeLable = [[UILabel alloc]init];
        _finishTimeLable.font = [UIFont systemFontOfSize:13.0];
        _finishTimeLable.textColor = [UIColor jd_barTintColor];
    }
    return _finishTimeLable;
}

- (UILabel *)guaranteeLable
{
    if (!_guaranteeLable) {
        _guaranteeLable = [[UILabel alloc]init];
        _guaranteeLable.font = [UIFont systemFontOfSize:13.0];
        _guaranteeLable.textColor = [UIColor jd_barTintColor];
    }
    return _guaranteeLable;
}

- (UILabel *)projectType
{
    if (!_projectType) {
        _projectType = [[UILabel alloc]init];
        _projectType.font = [UIFont systemFontOfSize:13.0];
        _projectType.textColor = [UIColor jd_barTintColor];
    }
    return _projectType;
}
@end
