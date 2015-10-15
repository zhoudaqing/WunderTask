//
//  InvesetMoneyView.m
//  iOSFinancial
//
//  Created by Mr.Yang on 15/4/28.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "InvesetMoneyView.h"
#import "UIView+Animation.h"

@interface InvesetMoneyView ()

@property (nonatomic, strong)   IBOutlet UILabel *avaliableLabel;
@property (nonatomic, strong)   IBOutlet UILabel *willInComeLabel;
@property (nonatomic, strong)   IBOutlet UIView *backGroundView;

@property (nonatomic, strong)   IBOutlet UILabel *avaliableMoney;
@property (nonatomic, strong)   IBOutlet UILabel *willInComeMoney;

@property (nonatomic, strong)   IBOutlet UIButton *rechargeButton;

@property (nonatomic, strong)   UIActivityIndicatorView *indicatior;

@end

@implementation InvesetMoneyView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
    
    _avaliableLabel.textColor = [UIColor jd_globleTextColor];
    _willInComeLabel.textColor = [UIColor jd_globleTextColor];

    _investMoney.keyboardType = UIKeyboardTypeDecimalPad;
    _investMoney.returnKeyType = UIReturnKeyDone;
    
    [self.rechargeButton setTitleColor:[UIColor jd_settingDetailColor] forState:UIControlStateNormal];
    self.rechargeButton.titleLabel.textAlignment = NSTextAlignmentRight;
    
    self.backGroundView.backgroundColor = [UIColor whiteColor];
    self.backGroundView.layer.borderWidth  = .3f;
    self.backGroundView.layer.borderColor = [UIColor jd_lineColor].CGColor;
    self.backGroundView.layer.cornerRadius = 3.0f;
    
    [self addSubview:self.indicatior];
    
    [self setInCoMoney:@"0.00 "];
    [self setAvaMoney:nil];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.indicatior.left = CGRectGetMaxX(self.avaliableLabel.frame) + 3.0f;
    self.indicatior.top = CGRectGetMinY(self.avaliableLabel.frame);
}

//  设置可用金额
- (void)setAvaMoney:(NSString *)money
{
    if (money.length == 0) {
        [self.indicatior startAnimating];
        self.indicatior.hidden = NO;
        self.avaliableMoney.hidden = YES;
    }else {
        [self.indicatior stopAnimating];
        self.avaliableMoney.hidden = NO;
        self.indicatior.hidden = YES;
    }
    
    if (![[money stringByAppendingString:@"元"] isEqualToString:self.avaliableMoney.attributedText.string]) {
        [self.avaliableMoney flashAnimation];
    }
    
    self.avaliableMoney.attributedText = [self attributeStringWithText:money];
}

//  设置预期收益
- (void)setInCoMoney:(NSString *)money
{
    self.willInComeMoney.attributedText = [self attributeStringWithText:money];
}

- (NSMutableAttributedString *)attributeStringWithText:(NSString *)text
{
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:HTSTR(@"%@元",text)];
    [string addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14.0f] range:NSMakeRange(0, text.length)];
    [string addAttribute:NSForegroundColorAttributeName value:[UIColor jd_settingDetailColor] range:NSMakeRange(0, text.length)];
    
    return string;
}

- (IBAction)rechargeButtonClicked:(id)sender
{
    if (_rechargeBlock) {
        _rechargeBlock(self);
    }
}

- (UIActivityIndicatorView *)indicatior
{
    if (!_indicatior) {
        _indicatior = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    
    return _indicatior;
}

@end
