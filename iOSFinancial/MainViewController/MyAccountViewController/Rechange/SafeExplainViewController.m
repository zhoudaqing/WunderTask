//
//  SafeExplainViewController.m
//  iOSFinancial
//
//  Created by Mr.Yan on 15/5/27.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "SafeExplainViewController.h"
#import "CardNumController.h"
@interface SafeExplainViewController ()
{
    UIButton *_nextBtn;
}
@end

@implementation SafeExplainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addcontentView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addNextBtn
{
    UIButton *nextBtn = [Sundry BigBtnWithHihtY:300 withTitle:@"下一步"];
    [nextBtn addTarget:self action:@selector(setCardNumCtr) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:nextBtn];
}
- (void)setCardNumCtr
{
    CardNumController *cardNum = [[CardNumController alloc]init];
    cardNum.title = @"设置银行卡号";
    cardNum.mDict = self.dict;
    cardNum.popVC = self.popVC;
    [self.navigationController pushViewController:cardNum animated:YES];
}

- (void)addcontentView
{
    UIScrollView *view = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, APPScreenWidth,APPScreenHeight - 44)];
    UILabel *contentLable = [[UILabel alloc]initWithFrame:CGRectMake(15, 15, APPScreenWidth - 30, 0)];
    
    contentLable.font = [UIFont systemFontOfSize:13.0];
    contentLable.numberOfLines = 0;
    contentLable.text = @"为保证您的账户资金在简单理财网的安全性，特推出“安全卡”，每一个用户只能绑定一张卡作为快捷支付方式。“安全卡”是您支付资金的唯一通道，在资金支付便捷的同时保证资金安全，避免盗卡、诈骗等风险。";
    contentLable.textColor = [UIColor jd_globleTextColor];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:contentLable.text];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    [paragraphStyle setLineSpacing:4];//调整行间距
    
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [contentLable.text length])];
    contentLable.attributedText = attributedString;
    [contentLable sizeToFit];
    [view addSubview:contentLable];
    
    UILabel *titleLable = [[UILabel alloc]initWithFrame:CGRectMake(15, contentLable.bottom + 18, APPScreenWidth, 15)];
    titleLable.text = @"绑定说明";
    titleLable.font = [UIFont systemFontOfSize:15.0];
    titleLable.textColor = [UIColor jd_darkBlackTextColor];
    [view addSubview:titleLable];
    
    UILabel *contentLable2 = [[UILabel alloc]initWithFrame:CGRectMake(15, titleLable.bottom + 4, APPScreenWidth - 30, 0)];
    
    contentLable2.font = [UIFont systemFontOfSize:13.0];
    contentLable2.numberOfLines = 0;
    contentLable2.text = @"· 通过简单理财网PC端网站进行网银充值不受影响。\n· 但一经绑定“安全卡”，PC端与移动端提现，默认只能同步提现到此“安全卡”上。\n· “安全卡”信息唯一，一经绑定，其余提现银行卡自动解绑。\n· 变更“安全卡”需经过人工审核，如有需要请联系简单理财网客服，同时也请您选择常用银行卡作为“安全卡”。\n· “安全卡”信息经银行及简单理财网认证，目前支持14家银行，分别为：农业银行，工商银行，招商银行，中国银行，建设银行，光大银行，华夏银行，中信银行，兴业银行，邮储银行，平安银行，浦发银行，广发银行，民生银行。";
    contentLable2.textColor = [UIColor jd_globleTextColor];
    
    NSMutableAttributedString *attributedString2 = [[NSMutableAttributedString alloc] initWithString:contentLable2.text];
    NSMutableParagraphStyle *paragraphStyle2 = [[NSMutableParagraphStyle alloc] init];
    
    [paragraphStyle2 setLineSpacing:4];//调整行间距
    
    [attributedString2 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle2 range:NSMakeRange(0, [contentLable2.text length])];
    contentLable2.attributedText = attributedString2;
    
    [contentLable2 sizeToFit];
    [view addSubview:contentLable2];
    
    [self.view addSubview:view];
    
    UIButton *checkbtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 22, 22)];
    [checkbtn setImage:[UIImage imageNamed:@"checkBox"] forState:UIControlStateNormal];
    [checkbtn  setImage:[UIImage imageNamed:@"checkBoxSelected"] forState:UIControlStateSelected];
    [checkbtn addTarget:self action:@selector(clickCheckBtn:) forControlEvents:UIControlEventTouchDown];
    checkbtn.selected = NO;
    
    UILabel *checklable = [[UILabel alloc]initWithFrame:CGRectMake(22, 0, 132, 22)];
    checklable.textColor = [UIColor jd_darkBlackTextColor];
    checklable.font = [UIFont systemFontOfSize:12.0];
    checklable.text = @"我已经阅读并同意次说明";
    
    UIView *checkBoxView = [[UIView alloc]initWithFrame:CGRectMake((APPScreenWidth - 154)*.5, contentLable2.bottom + 10, 154, 22)];
    [checkBoxView addSubview:checkbtn];
    [checkBoxView addSubview:checklable];
    
    [view addSubview:checkBoxView];
    
    _nextBtn = [Sundry BigBtnWithHihtY:checkBoxView.bottom +10 withTitle:@"下一步"];
    [_nextBtn addTarget:self action:@selector(setCardNumCtr) forControlEvents:UIControlEventTouchDown];
    _nextBtn.enabled = NO;
    [view addSubview:_nextBtn];
    
    view.contentSize = CGSizeMake(APPScreenWidth, _nextBtn.bottom + 10);

}

- (void)clickCheckBtn:(UIButton *)btn
{
    if (btn.selected == YES) {
        btn.selected = NO;
        _nextBtn.enabled = NO;
    }else
    {
        btn.selected = YES;
        _nextBtn.enabled = YES;
    }
}

@end
