//
//  InvitationFriendViewController.m
//  iOSFinancial
//
//  Created by Mr.Yan on 15/5/11.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "InvitationFriendViewController.h"
#import "InvitationFriednTableViewCell.h"
#import "UMSocial.h"
#import "UMSocialQQHandler.h"
#import "UMSocialWechatHandler.h"

@interface InvitationFriendViewController ()

@property (nonatomic) NSDictionary *dict;

@end

@implementation InvitationFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView removeFromSuperview];
    
    __weakSelf;
    [self.loadingStateView setTouchBlock:^(LoadingStateView *view, LoadingState state){
        [weakSelf requestFriend];
    }];
    
    [self showLoadingViewWithState:LoadingStateLoading];
    [self requestFriend];
    
}

// MARK: 请求好友分享接口
- (void)requestFriend
{
    
    HTBaseRequest *request = [[HTBaseRequest alloc] initWithURL:[NSString inviteInfo]];
    
    [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
        [self removeLoadingView];
        NSDictionary *error = [request.responseJSONObject dictionaryForKey:@"error"];
        if (error) {
            NSString *message = [error stringForKey:@"message"];
            [self showHudErrorView:message];
            
        }else {
            self.dict = [request.responseJSONObject dictionaryForKey:@"result"];
            [self.view addSubview:self.tableView];
            [self.tableView  reloadData];
        }
        
    } failure:^(YTKBaseRequest *request) {
        [self showLoadingViewWithState:LoadingStateNetworkError];
        [self showHudErrorView:PromptTypeError];
    }];
}

// MARK: 点击分享好友按钮
- (void)clickInvitationBtn
{
    
    //设置微信AppId、appSecret，分享url
    [UMSocialWechatHandler setWXAppId:WeiXinAppKey appSecret:WeiXinAppSecreat url:[self.dict stringForKey:@"url"]];
    
    //设置分享到QQ/Qzone的应用Id，和分享url 链接
    [UMSocialQQHandler setQQWithAppId:QQAppId appKey:QQAppKey url:[self.dict stringForKey:@"url"]];
    [UMSocialData defaultData].extConfig.title = @"简单理财网";
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:UMengShareAppKey
                                      shareText:[NSString stringWithFormat:@"我在简单理财网投资理财项目，央企全额本息担保，超高年化收益率，100元超低认购起点，平安保险保驾护航，兴业银行资金监管。注册就送50元红包，还能拥有只属于你的高收益项目，还等什么，快来赚钱吧！"]
                                     shareImage:[UIImage imageNamed:@"shareImage"]
                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina,UMShareToWechatSession,UMShareToWechatTimeline,UMShareToQQ,nil]
                                       delegate:nil];
    // 设置微博分享内容
    [UMSocialData defaultData].extConfig.sinaData.shareText = [NSString stringWithFormat:@"我在简单理财网投资理财项目，央企全额本息担保，超高年化收益率，100元超低认购起点，平安保险保驾护航，兴业银行资金监管。注册就送50元红包，还能拥有只属于你的高收益项目，还等什么，快来赚钱吧！%@",[self.dict stringForKey:@"url"]];
    // 设置微信朋友圈分享内容
    [UMSocialData defaultData].extConfig.wechatTimelineData.shareText = @"简单理财网，让理财简单一点";
    
}


#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    InvitationFriednTableViewCell *cell  = [[InvitationFriednTableViewCell  alloc]init];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.myInvitationFriendS = [self.dict stringIntForKey:@"invited_friends"];
    cell.rechargeFriends = [self.dict stringIntForKey:@"charged_friends"];
    cell.investFriends = [self.dict stringIntForKey:@"invested_friends"];
    cell.getRedEnvelope = [self.dict stringFloatForKey:@"total_cash_gift"];
    cell.getedAwards = [self.dict stringFloatForKey:@"total_award"];
    
    [cell layoutCellSubviews];
    
    return cell;
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
    return 91.5*2.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 320;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, APPScreenWidth, APPScreenHeight)];
    
    UIButton *invitationBtn = [Sundry BigBtnWithHihtY:10 withTitle:@"立即邀请好友"];
    [invitationBtn addTarget:self action:@selector(clickInvitationBtn) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:invitationBtn];
    
    UILabel *titleLable = [[UILabel alloc]initWithFrame:CGRectMake(20, invitationBtn.bottom + 20, APPScreenWidth, 15)];
    titleLable.text = @"规则说明";
    titleLable.font = [UIFont systemFontOfSize:15.0];
    [view addSubview:titleLable];
    
  
    UILabel *contentLable = [[UILabel alloc]initWithFrame:CGRectMake(20, titleLable.bottom + 10, APPScreenWidth - 40,0)];
    contentLable.font = [UIFont systemFontOfSize:13.0];
    contentLable.numberOfLines = 0;
    contentLable.text = @"1. 只有您的好友通过推荐链接注册，您才能获得红包哦 \n2. 建议复制链接分享到各种论坛、社区、QQ 群等地方，可能会收到意想不到的惊喜\n3. 每成功邀请一位好友注册且充值投资，即可获得50元红包。邀请多多，红包多多，而且没有上限！";
    contentLable.textColor = [UIColor jd_globleTextColor];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:contentLable.text];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    [paragraphStyle setLineSpacing:4];//调整行间距
    
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [contentLable.text length])];
    contentLable.attributedText = attributedString;
    
    [view addSubview:contentLable];
    [contentLable sizeToFit];
    
    UILabel *explainLable = [[UILabel alloc]initWithFrame:CGRectMake(20, contentLable.bottom + 8, APPScreenWidth, 12)];
    explainLable.text = @"* 本规则的最终解释权归简单理财网所有";
    explainLable.font = [UIFont systemFontOfSize:12.0];
    explainLable.textColor = [UIColor jd_barTintColor];
    [view addSubview:explainLable];
    
    return view;
}

- (NSString *)title
{
    return @"邀请好友";
}

@end
