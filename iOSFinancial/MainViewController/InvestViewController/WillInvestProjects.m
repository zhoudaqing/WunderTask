//
//  WillInvestProjects.m
//  iOSFinancial
//
//  Created by Mr.Yang on 15/5/7.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "WillInvestProjects.h"
#import "TargetDescriptionCell.h"
#import "ProjectView.h"
#import "NSString+Size.h"
@interface WillInvestProjects ()

@property (nonatomic, strong)   UIScrollView *contentScrollView;
@property (nonatomic, assign)   LoanType loanType;

@end

@implementation WillInvestProjects

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _loanType = LoanTypeAnXin;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    __weakSelf;
    [self.loadingStateView setTouchBlock:^(LoadingStateView *view, LoadingState state) {
        [weakSelf requestAnXinList];
    }];
    
    [self requestAnXinList];
}

- (void)requestAnXinList
{
    [self showLoadingViewWithState:LoadingStateLoading];
    HTBaseRequest *request = [HTBaseRequest requestWithURL:[NSString investWillInvestList]];
    
    [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        [self removeLoadingView];
        
        NSArray *result = [request.responseJSONObject arrayForKey:@"result"];
        if (result) {
            [self handleResponseDic:result];
        }
        
    } failure:^(YTKBaseRequest *request) {
        [self showLoadingViewWithState:LoadingStateNetworkError];
        [self showHudErrorView:PromptTypeError];
    }];
}

- (void)handleResponseDic:(NSArray *)result
{
    if (result.count == 0) {
        [self showLoadingViewWithState:LoadingStateNoneData];
    }else {
        [self createScrollView:result];
    }
}

- (void)willChangePromptView
{
    self.loadingStateView.promptStr = @"暂无录入数据";
}

- (UIScrollView *)contentScrollView
{
    if (!_contentScrollView) {
        CGFloat height = self.view.height - self.tableView.contentSize.height - 64;
        _contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, height)];
    }
    
    return _contentScrollView;
}

- (void)createScrollView:(NSArray *)array
{
    ProjectView *view;
    for (NSDictionary *dict in array) {
        NSInteger index = [array indexOfObject:dict];
        view = [ProjectView xibView];
        view.projectType = _loanType;
        CGFloat width = (APPScreenWidth - 45) / 2.0f;
        CGFloat locationX = 15.0f + index % 2 * (width + 15);
        CGFloat locationY = 15.0f + index / 2 * (61 + 15.0f);
        view.frame = CGRectMake(locationX, locationY, width, 61);
        [_contentScrollView addSubview:view];
        
        NSString *projectId = [dict stringIntForKey:@"pid"];
        NSString *money = [dict stringFloatForKey:@"money_unfinish"];
        
        view.titleLabel.text = HTSTR(@"%@号", projectId);
        view.detailLabel.attributedText = [self handleAttrateMoney:money];
    }
    
    CGFloat height = view.bottom + 15.0f;
    self.contentScrollView.contentSize = CGSizeMake(APPScreenWidth, height);
    self.contentScrollView.height = height;
    
    self.tableView.tableFooterView = self.contentScrollView;
}

- (NSMutableAttributedString *)handleAttrateMoney:(NSString *)money
{
    NSString *moneyStr = HTSTR(@"余额：%@元", [money formatNumberString]);
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:moneyStr];
    [string addAttribute:NSFontAttributeName value:HTFont(15.0f) range:NSMakeRange(3, money.length)];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor jd_settingDetailColor] range:NSMakeRange(3, money.length+1)];
    
    return string;
}

#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return .01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [TargetDescriptionCell heightForText:[self detailText]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TargetDescriptionCell *targetMoreCell = [TargetDescriptionCell newCell];
    targetMoreCell.selectionStyle = UITableViewCellSelectionStyleNone;
    targetMoreCell.titleLabel.attributedText = [self formatString:@"温馨提示:"];
    targetMoreCell.promptLabel.attributedText = [self detailText];
    
    CGFloat height = [TargetDescriptionCell heightForText:[self detailText]] - 1;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(15.0f, height, APPScreenWidth - 30.0f, 1)];
    view.backgroundColor = [UIColor jd_lineColor];
    
    [targetMoreCell addSubview:view];
    
    return targetMoreCell;
}

- (NSAttributedString *)detailText
{
    NSString *projectStr = @"";
    
    switch (_loanType) {
        case LoanTypeAnXin:projectStr = @"安心"; break;
        case LoanTypeDongXin:projectStr = @"动心"; break;
        case LoanTypeShengXin:projectStr = @"省心"; break;
        case LoanTypeYinQi:projectStr = @"银企桥接"; break;
        default:
            break;
    }
    
    NSString *message = HTSTR(@"您好，您的投资总金额，会随机分散投资到以下几个%@项目中，以更加提升您的投资安全度。“不要把所有的鸡蛋放到一个篮子里”，正是此道理", projectStr);
    
    NSAttributedString *string = [self getParamStyleDetailText:message];
    
    return string;
}

- (NSAttributedString *)getParamStyleDetailText:(NSString *)detail
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineSpacing = 6;
    NSMutableAttributedString *detailStr = [[NSMutableAttributedString alloc] initWithString:detail];
    [detailStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, detailStr.length)];
    [detailStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14.0f] range:NSMakeRange(0, detail.length)];
    [detailStr addAttribute:NSForegroundColorAttributeName value:[UIColor jd_globleTextColor] range:NSMakeRange(0, detail.length)];
    
    return detailStr;
}

- (NSMutableAttributedString *)formatString:(NSString *)text
{
    UIFont *blodFont = [UIFont boldSystemFontOfSize:16.0f];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text];
    [string addAttribute:NSFontAttributeName value:blodFont range:NSMakeRange(0, text.length)];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor jd_settingDetailColor] range:NSMakeRange(0, text.length)];
    
    return string;
}



@end
