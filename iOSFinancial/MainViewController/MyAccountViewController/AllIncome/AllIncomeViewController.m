//
//  AllIncomeViewController.m
//  iOSFinancial
//
//  Created by Mr.Yan on 15/5/8.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "AllIncomeViewController.h"
#import "ProgressView.h"

@interface AllIncomeViewController ()

@property (nonatomic) NSDictionary *dict;

@end

@implementation AllIncomeViewController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    __weakSelf;
    [self.loadingStateView setTouchBlock:^(LoadingStateView *view, LoadingState state){
        [weakSelf requestallIncome];
    }];
    
    [self showLoadingViewWithState:LoadingStateLoading];
    [self requestallIncome];
    
}

// MARK: 请求累计收益接口
- (void)requestallIncome
{
    
    HTBaseRequest *request = [[HTBaseRequest alloc] initWithURL:[NSString allIncome]];
    
    [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        [self removeLoadingView];
        NSDictionary *error = [request.responseJSONObject dictionaryForKey:@"error"];
        if (error) {
            NSString *message = [error stringForKey:@"message"];
            [self showHudErrorView:message];
            
        }else {
            self.dict = [request.responseJSONObject dictionaryForKey:@"result"];
            
            [self loadsubViews];
            
        }
        
    } failure:^(YTKBaseRequest *request) {
        [self showLoadingViewWithState:LoadingStateNetworkError];
    }];
}

// MARK: 调整布局
- (void)loadsubViews
{

    UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(0, 44, APPScreenWidth, 15)];
    lable.font = [UIFont systemFontOfSize:15.0];
    lable.textColor = [UIColor jd_darkBlackTextColor];
    lable.textAlignment = NSTextAlignmentCenter;
    lable.text = @"累计总收益(元)";
    [self.view addSubview:lable];
    
    UILabel *net_incomeLable = [[UILabel alloc]initWithFrame:CGRectMake(0, lable.bottom + 15, APPScreenWidth, 22.5)];
    net_incomeLable.font = [UIFont systemFontOfSize:22.5];
    net_incomeLable.textColor  = [UIColor jd_settingDetailColor];
    net_incomeLable.textAlignment = NSTextAlignmentCenter;
    net_incomeLable.text  = [self.dict stringFloatForKey:@"net_income"];
    [self.view addSubview:net_incomeLable];
    
    
    for (int i = 0;i < 4; i ++) {
        ProgressView *progressView = [[ProgressView alloc]initWithFrame:CGRectMake(i%2 * 120 + (APPScreenWidth - 240)/3.0 * (i%2+1) , net_incomeLable.bottom +40 + i / 2 * (180), 120, 120)];
        
        UILabel *moneyLable = [[UILabel alloc]initWithFrame:CGRectMake(progressView.origin.x, progressView.bottom + 10, progressView.width, 12.5)];
        moneyLable.font = [UIFont systemFontOfSize:12.5 ];
        moneyLable.textColor  = [UIColor jd_darkBlackTextColor];
        moneyLable.textAlignment = NSTextAlignmentCenter;
        
        switch (i) {
            case 0:
            {
                progressView.progress = [self progressViewWith:self.dict[@"investor_income"]];
                progressView.lineColor = [UIColor colorWithHEX:0x1ebaba];
                progressView.detailLable.text = @"投资总收益";
                moneyLable.text = [NSString stringWithFormat:@"%@元",[self.dict stringFloatForKey:@"investor_income"]];
            }
                break;
            case 1:
            {
                progressView.progress = [self progressViewWith:self.dict[@"balance_income"]];
                progressView.lineColor = [UIColor colorWithHEX:0xb0d02a];
                progressView.detailLable.text = @"余额生息收益";
                moneyLable.text = [NSString stringWithFormat:@"%@元",[self.dict stringFloatForKey:@"balance_income"]];
            }
                break;
            case 2:
            {
                progressView.progress = [self progressViewWith:self.dict[@"cashgift_unlocked"]];
                progressView.lineColor = [UIColor colorWithHEX:0xe94e1e];
                progressView.detailLable.text = @"红包解锁收益";
                moneyLable.text = [NSString stringWithFormat:@"%@元",[self.dict stringFloatForKey:@"cashgift_unlocked"]];
            }
                break;
            default:
            {
                progressView.progress = [self progressViewWith:self.dict[@"other_income"]];
                progressView.lineColor = [UIColor colorWithHEX:0xfe8f28];
                progressView.detailLable.text = @"其他收益";
                moneyLable.text = [NSString stringWithFormat:@"%@元",[self.dict stringFloatForKey:@"other_income"]];

            }
                break;
        }
        
        [self.view addSubview:moneyLable];
        [self.view addSubview:progressView];
    }
    
}

// MARK: 返回百分比数值
- (CGFloat )progressViewWith:(id)sender
{
    CGFloat all = [[self.dict stringFloatForKey:@"net_income"] doubleValue];
    if ( all > 0) {
        CGFloat income = [sender doubleValue];
        return income / all;
    }
    return 0.00001;
}

@end
