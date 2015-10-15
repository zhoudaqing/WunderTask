//
//  InvestShareViewController.m
//  iOSFinancial
//
//  Created by Mr.Yan on 15/7/22.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "InvestShareViewController.h"
#import "UMSocial.h"
#import "UMSocialQQHandler.h"
#import "UMSocialWechatHandler.h"

@interface InvestShareViewController ()<UMSocialUIDelegate>

@property (nonatomic ,strong)NSDictionary *dict;

@end

@implementation InvestShareViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"投资项目";
    [self loadSubViews];
}

- (UILabel *)contentLableWihtContet:(NSString *)content wihtY:(CGFloat)contentLabeY;
{
    UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(0, contentLabeY, APPScreenWidth, 13)];
    lable.text = content;
    lable.textAlignment = NSTextAlignmentCenter;
    lable.font = [UIFont systemFontOfSize:13.0];
    lable.textColor = [UIColor jd_globleTextColor];
    return lable;
}

- (void)fatherVcDissMiss
{
    [self dismissViewControllerAnimated:NO complainBlock:nil];
    [self.delegate selfDissmiss];
}

- (void)dismissViewController
{
    [self dismissViewControllerAnimated:YES complainBlock:nil];
    [self.delegate selfDissmiss];

}

- (void)loadSubViews
{
    UIImageView *shareImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"investShare"]];
    shareImage.frame = CGRectMake((APPScreenWidth - shareImage.width)/2.0, 38, shareImage.width, shareImage.height);
    [self.view addSubview:shareImage];
    
    UILabel *titleLable = [[UILabel alloc]initWithFrame:CGRectMake(0, shareImage.bottom + 30 , APPScreenWidth, 18)];
    titleLable.text = @"恭喜您获得一次分享得返现的机会";
    titleLable.textAlignment = NSTextAlignmentCenter;
    titleLable.textColor = [UIColor jd_barTintColor];
    [self.view addSubview:titleLable];
    
    UILabel *content1Lable = [self contentLableWihtContet:@"点击下方【分享给好友】按钮" wihtY:titleLable.bottom+ 15];
    [self.view addSubview:content1Lable];
    
    UILabel *content2Lable = [self contentLableWihtContet:@"将“简单理财网”分享给好友可立即获得0.5元现金" wihtY:content1Lable.bottom + 8];
    [self.view addSubview:content2Lable];
    
    UILabel *content3Lable = [self contentLableWihtContet:@"分享成功后前往账户余额中查收" wihtY:content2Lable.bottom + 8];
    [self.view addSubview:content3Lable];
    
    UIButton *shareBtn = [Sundry BigBtnWithHihtY:content3Lable.bottom + 33 withTitle:@"分享给好友"];
    [shareBtn addTarget:self action:@selector(successShare) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shareBtn];
    
    UIButton *giveUpBtn = [Sundry BigBtnWithHihtY:shareBtn.bottom + 10 withTitle:@"放弃分享"];
    [giveUpBtn setBackgroundColor:[UIColor jd_BigButtonDisabledColor]];
    [giveUpBtn addTarget:self action:@selector(fatherVcDissMiss) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:giveUpBtn];

}


- (void)successShare
{
    //设置微信AppId、appSecret，分享url
    [UMSocialWechatHandler setWXAppId:WeiXinAppKey appSecret:WeiXinAppSecreat url:self.url];
    
    //设置分享到QQ/Qzone的应用Id，和分享url 链接
    [UMSocialQQHandler setQQWithAppId:QQAppId appKey:QQAppKey url:self.url];
    
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:UMengShareAppKey
                                      shareText:[NSString stringWithFormat:@"我在简单理财网投资理财项目，央企全额本息担保，超高年化收益率，100元超低认购起点，平安保险保驾护航，兴业银行资金监管。注册就送50元红包，还能拥有只属于你的高收益项目，还等什么，快来赚钱吧！"]
                                     shareImage:[UIImage imageNamed:@"shareImage"]
                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina,UMShareToWechatSession,UMShareToWechatTimeline,UMShareToQQ,nil]
                                       delegate:self];
    // 设置微博分享内容
    [UMSocialData defaultData].extConfig.sinaData.shareText = [NSString stringWithFormat:@"我在简单理财网投资理财项目，央企全额本息担保，超高年化收益率，100元超低认购起点，平安保险保驾护航，兴业银行资金监管。注册就送50元红包，还能拥有只属于你的高收益项目，还等什么，快来赚钱吧！%@",self.url];
    // 设置微信朋友圈分享内容
    [UMSocialData defaultData].extConfig.wechatTimelineData.shareText = @"简单理财网，让理财简单一点";
}

-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    NSLog(@"%u",response.responseCode);//UMSResponseCodeSuccess 分享成功
    if (response.responseCode == UMSResponseCodeSuccess) {
        
        HTBaseRequest *request = [HTBaseRequest requestWithURL:[NSString sharedAward]];
        [request setPostRequestParam:self.ShareDict];
        [self showHudWaitingView:PromptTypeWating];
        [request startWithCompletionBlockWithSuccess:^(YTKBaseRequest *request) {
            
            NSDictionary *result = [request.responseJSONObject dictionaryForKey:@"error"];
            if (!result) {
                //  发送账户刷新的通知, 刷新余额
                [[NSNotificationCenter defaultCenter] postNotificationName:__USER_ACCOUNT_REFRESH_NOTIFACTION object:nil];
                
                [self showHudSuccessView:@"分享成功，您获得分享红包(账户余额可查询)。"];
                [self performSelector:@selector(dismissViewController) withObject:nil afterDelay:1.2f];
            }else
                [self showHudAuto:result[@"message"]];
            
        }];

    }
}

@end
