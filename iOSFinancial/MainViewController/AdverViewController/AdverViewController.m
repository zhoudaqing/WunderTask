
//
//  AdverViewController.m
//  iOSFinancial
//
//  Created by Mr.Yang on 15/6/9.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "AdverViewController.h"
#import "HTADScrollView.h"
#import "ActionsCell.h"
#import "FlipNumberCell.h"
#import "ActionWebViewController.h"
#import "UIView+NoneDataView.h"
#import "HTNavigationController.h"


@interface AdverViewController ()

@property (nonatomic, strong)   HTADScrollView *adScrollView;
@property (nonatomic, strong)   NSArray *loopImages;
@property (nonatomic, strong)   ActionsCell *actionCell;
@property (nonatomic, strong)   FlipNumberCell *flipNumCell;

@property (nonatomic, strong)   NSArray *activities;
@property (nonatomic, strong)   NSArray *news;

@end

@implementation AdverViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.showRefreshHeaderView = YES;
    
    self.tableView.tableFooterView = nil;
    self.tableView.showsVerticalScrollIndicator = NO;
    
    self.tableView.tableHeaderView = self.adScrollView;
    [self.adScrollView showNoneDataView];
    
    [self.refreshHeaderView beginRefreshing];
}

//  请求广告数据
- (void)requestAdverViewList
{
    HTBaseRequest *request = [HTBaseRequest requestWithURL:[NSString adveriseList]];
    
    [request setCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        
        [self endRefresh];
        [self.adScrollView removeNoneDataView];
        
        NSDictionary *result = [request.responseJSONObject dictionaryForKey:@"result"];
        
        if (result) {
            [self endRefresh];
            [self handleResponseAdverseList:result];
        }
        
    } failure:^(YTKBaseRequest *request) {
        [self endRefresh];
        [self showHudErrorView:PromptTypeError];
        
    }];
    
    [request start];
}

//  处理返回数据
- (void)handleResponseAdverseList:(NSDictionary *)dict
{
    _news = [dict arrayForKey:@"news"];
    _activities = [dict arrayForKey:@"activities"];

    NSString *key = @"3x";
    if (is35Inch || is4Inch) {
        key = @"1x";
    }else if (is47Inch) {
        key = @"2x";
    }
    
    NSMutableArray *images = [NSMutableArray array];
    for (NSDictionary *infoDic in _news) {
        NSDictionary *imageDic = [infoDic dictionaryForKey:@"img"];
        NSString *value = [imageDic stringForKey:key];
        if (value.length > 0) {
            [images addObject:value];
        }
    }
    
    [self.adScrollView refreshView:images titles:nil];
    
    NSMutableArray *actionImages = [NSMutableArray array];
    for (NSDictionary *infoDic in _activities) {
        NSDictionary *imageDic = [infoDic dictionaryForKey:@"img"];
        [actionImages addObject:[imageDic stringForKey:key]];
    }
    
    [_actionCell refreshImages:actionImages];
    
    NSDictionary *numberDic = [dict dictionaryForKey:@"statistics"];
    [_flipNumCell setRegisterNumb:[numberDic stringIntForKey:@"total_user_register"]];
    [_flipNumCell setInvestoreFree:[numberDic stringIntForKey:@"total_investor_fee"]];
    [_flipNumCell setTotalIncome:[numberDic stringIntForKey:@"total_income"]];
    
    [_flipNumCell startAnimation];
}

- (void)refreshViewBeginRefresh:(MJRefreshBaseView *)baseView
{
    [self requestAdverViewList];
}

//  广告试图单击的位置
- (void)adverViewTouchIndedIndex:(NSInteger)index
{
    NSDictionary *dict = [self.news objectAtIndex:index];
    NSString *urlStr = [dict stringForKey:@"herf"];
    
    if (isEmpty(urlStr)) {
        //  如果为空，则不做任何操作
        return;
    }
    
    if ([urlStr isEqualToString:@"com.yyyy.jdlc://project"]) {
        self.tabBarController.selectedIndex = 1;
        return;
    }
    
    ActionWebViewController *webVC = [[ActionWebViewController alloc] init];
    webVC.url = HTURL(urlStr);
    
    webVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webVC animated:YES];
}

// MARK:活动页的单击事件
- (void)actionTouchIndex:(NSInteger)index
{
    NSDictionary *dict = [self.activities objectAtIndex:index];
    NSString *urlStr = [dict stringForKey:@"herf"];
    ActionWebViewController *webVC = [[ActionWebViewController alloc] init];
    webVC.url = HTURL(urlStr);
    
    webVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webVC animated:YES];
}

//  MARK:广告滚动视图
- (HTADScrollView *)adScrollView
{
    if (!_adScrollView) {
        
        CGFloat height = 150.0f;
        if (is55Inch) {
            height = 166.0f;
        }
    
        _adScrollView = [[HTADScrollView alloc] initWithFrame:CGRectMake(0, 0, APPScreenWidth, height) images:nil andTitles:nil];
        
        __weakSelf;
        [_adScrollView setTouchBlock:^(NSInteger index) {
            [weakSelf adverViewTouchIndedIndex:index];
            
        }];
    }
    
    return _adScrollView;
}

//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
//{
//    [_flipNumCell startAnimation];
//}

#pragma mark -
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return [ActionsCell fixedHeight];
    }

    return [FlipNumberCell fixedHeight];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (cell == _flipNumCell) {
        [_flipNumCell startAnimation];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row == 0) {
        if (!_actionCell) {
            _actionCell = [ActionsCell newCell];
            _actionCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            __weakSelf;
            //  MARK:活动事件
            [_actionCell setTouchBlock:^(ActionsCell *action, NSInteger index) {
                
                [weakSelf actionTouchIndex:index];
            }];
        }
        
        cell = _actionCell;
        
    }else {
        
        if (!_flipNumCell) {
            _flipNumCell = [FlipNumberCell newCell];
            NSString *imageName = @"indexBottomImage1";
            
            if (is47Inch) {
                imageName = @"indexBottomImage";
            }
            
            _flipNumCell.backImageView.image = HTImage(imageName);
            
            _flipNumCell.selectionStyle = UITableViewCellSeparatorStyleNone;
        }
        
        cell = _flipNumCell;
    }
    
    return cell;
}


@end
