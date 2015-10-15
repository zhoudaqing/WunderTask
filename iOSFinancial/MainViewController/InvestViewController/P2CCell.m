
//
//  P2CCell.m
//  iOSFinancial
//
//  Created by Mr.Yang on 15/4/26.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "P2CCell.h"
#import "P2CDataSource.h"
#import "HTCircleView.h"
#import "NSString+Size.h"
#import "WeiXinImageView.h"

@interface P2CCell ()

@property (nonatomic, strong)   HTCircleView *circleView;
//  专项标记
@property (nonatomic, strong)   WeiXinImageView *weiXinView;
//  分割线视图
@property (nonatomic, strong)   IBOutlet UIView *lineView;
//  年化收益标签
@property (nonatomic, strong)   IBOutlet UILabel *annualizeLabel;
//  期限标签
@property (nonatomic, strong)   IBOutlet UILabel *returnCyleLabel;

@property (nonatomic, strong)   IBOutlet NSLayoutConstraint *constraint;

@property (nonatomic, strong)   UIImageView *isRedeemImage;

@end


@implementation P2CCell

+ (BOOL)isNib
{
    return YES;
}

+ (CGFloat)fixedHeight
{
    return 168.0f;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    UIColor *fontColor = [UIColor jd_globleTextColor];
    
    self.contentView.backgroundColor = [UIColor jd_backgroudColor];
    
    self.backView.backgroundColor = [UIColor whiteColor];
    self.backView.layer.borderWidth = .3f;
    self.backView.layer.borderColor = [UIColor jd_lineColor].CGColor;
    self.backView.layer.cornerRadius = 3.0f;
    
    self.lineView.backgroundColor = [UIColor jd_lineColor];
    
    self.returnCyleLabel.textColor = fontColor;
    self.annualizeLabel.textColor = fontColor;
    self.annualize.textColor = fontColor;
    self.returnCycle.textColor = fontColor;
    
    self.titleLabel.textColor = fontColor;
    self.warrentLabel.textColor = fontColor;
    self.warrentState.textColor = fontColor;

    //  add CircleView
    [self addSubview:self.circleView];
    
    __weakSelf;
    [self.circleView setTouchBlock:^(HTCircleView *view) {
        if (weakSelf.actions.tailAction) {
            weakSelf.actions.tailAction (weakSelf, view, nil);
        }
    }];
    
    [self.backView addSubview:self.weiXinView];
    
    [self setNeedsUpdateConstraints];
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    if (is47Inch) {
        self.constraint.constant = 43.0f;
    }else if (is55Inch) {
        self.constraint.constant = 80.0f;
    }else {
        self.constraint.constant = 30.0f;
    }
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.circleView.right = self.width - 35.0f;
    self.circleView.top = self.titleLabel.bottom;
    
    self.weiXinView.right = APPScreenWidth - 20;
}

- (void)configWithSource:(id)source
{
    P2CDataSource * dataSource = (P2CDataSource *)source;
    
    P2CCellModel *model = dataSource.p2cModel;
    
    self.titleLabel.text = [model projectTitle];
    
    self.annualize.text = model.annualize;

    self.warrentLabel.text = model.warrent;
    
    self.circleView.persent = model.invesetPersent;
    
    [self changeStateWithModel:model andDataSource:dataSource];
    
}

- (void)changeStateWithModel:(P2CCellModel *)model andDataSource:(P2CDataSource *)source
{
    UIColor *textColor = [UIColor jd_settingDetailColor];
    
    //  专享标记
    if (!isEmpty(model.channel_display_msg)) {
        self.weiXinView.hidden = NO;
        [self.weiXinView setTitleSring:model.channel_display_msg];
    }else {
        self.weiXinView.hidden = YES;
    }
    
    //  是否可投
    if (model.invesetPersent == 1.0f) {
        self.warrentState.text = @"投资结束";
        self.warrentImageView.highlighted = YES;
        
        textColor = [UIColor jd_darkBlackTextColor];
        
    }else {
        self.warrentState.attributedText = [self unfinishMoneyFormat:model.unfinishMoney];
        self.warrentImageView.highlighted = NO;
    }
    
    //  项目年化收益
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:model.annualize];
    UIFont *systemFont = [UIFont systemFontOfSize:25.0f];
    [string addAttribute:NSFontAttributeName value:systemFont range:NSMakeRange(0, 2)];
    UIColor *color = textColor;
    NSInteger length = string.length;
    [string addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, length - 1)];
    color = [UIColor jd_globleTextColor];
    [string addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(length - 1, 1)];
    
    self.annualize.attributedText = string;
    
    //  项目期限
    if (source.isRedeem) {
        
        [self addSubview:self.isRedeemImage];
        
        NSMutableAttributedString *monthStr = [self stringWithRedeemReturnCyle:model.leftMonth andTextColor:textColor];
        
        if (monthStr.string.length > 0) {
            [monthStr appendAttributedString:[self normalAttributeString16:@"个月 "]];
            
            NSInteger days = [model.leftDays integerValue];
            
            if (days) {
                NSMutableAttributedString * dayStr = [self normalAttributeString16:HTSTR(@"%@天",model.leftDays)];
                [monthStr appendAttributedString:dayStr];
            }

            string = monthStr;
            
        }else {
            
            NSMutableAttributedString *dayStr = [self stringWithRedeemReturnCyle:model.leftDays andTextColor:textColor];
            [dayStr appendAttributedString:[self normalAttributeString16:@"天"]];
            
            string = dayStr;
        }
        
    }else {
        
        string = [[NSMutableAttributedString alloc] initWithString:model.returnCycleDescription];
        length = string.length;
        NSInteger num = 2;
        if (model.returnCyleType == ReturnCyleTypeDay) {
            num = 1;
        }
        [string addAttribute:NSFontAttributeName value:systemFont range:NSMakeRange(0, length - num)];
        [string addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, length - num)];
        
    }
    
    self.returnCycle.attributedText = string;
}

- (NSMutableAttributedString *)stringWithRedeemReturnCyle:(NSString *)returnCyle andTextColor:(UIColor *)textColor
{
    if ([returnCyle integerValue] == 0) {
        return [[NSMutableAttributedString alloc] init];
    }
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:returnCyle];
    [string addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:25.0f] range:NSMakeRange(0, returnCyle.length)];
    [string addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, returnCyle.length)];
    
    return string;
}

- (NSAttributedString *)unfinishMoneyFormat:(NSString *)string
{
    string = [string formatNumberString];
    NSMutableAttributedString *mutStr = [[NSMutableAttributedString alloc] initWithString:string];
    [mutStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14.0f] range:NSMakeRange(0, string.length)];
    [mutStr addAttribute:NSForegroundColorAttributeName value:[UIColor jd_settingDetailColor] range:NSMakeRange(0, string.length)];
    
    NSMutableAttributedString *prompt = [self normalAttributeString14:@"可投金额:"];
    [prompt appendAttributedString:mutStr];
    [prompt appendAttributedString:[self normalAttributeString14:@"元"]];
    
    return prompt;
}

- (NSMutableAttributedString *)normalAttributeString14:(NSString *)string
{
    return [self normalAttributeString:string withFontSize:14.0f];
}

- (NSMutableAttributedString *)normalAttributeString16:(NSString *)string
{
    return [self normalAttributeString:string withFontSize:16.0f];
}

- (NSMutableAttributedString *)normalAttributeString:(NSString *)string withFontSize:(CGFloat)fontSize
{
    NSMutableAttributedString *mutStr = [[NSMutableAttributedString alloc] initWithString:string];
    [mutStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:fontSize] range:NSMakeRange(0, string.length)];
    [mutStr addAttribute:NSForegroundColorAttributeName value:[UIColor jd_globleTextColor] range:NSMakeRange(0, string.length)];
    
    return mutStr;
}


+ (NSString*)formateNumShort:(int64_t)lNum
{
    NSString* szFormat = nil;
    double dbNum = (double)lNum;
    // 单位:亿
    if(dbNum > (double)10000000.0)
    {
        szFormat = @"%0.01f亿";
        dbNum /= (double)100000000.0;
    }
    // 单位:万
    else if(dbNum > (double)1000.0)
    {
        szFormat = @"%0.01f万";
        dbNum /= (double)10000.0;
    }
    else
    {
        szFormat = @"%0.0f";
    }
    
    return [NSString stringWithFormat:szFormat,dbNum];
}

- (HTCircleView *)circleView
{
    if (!_circleView) {
        _circleView = [[HTCircleView alloc] initWithFrame:CGRectMake(0, 0, 66, 66)];
        _circleView.tintColor = [UIColor jd_settingDetailColor];
    }

    return _circleView;
}

- (WeiXinImageView *)weiXinView
{
    if (!_weiXinView) {
        _weiXinView = [WeiXinImageView xibView];
        _weiXinView.hidden = YES;
    }
    
    return _weiXinView;
}

- (UIImageView *)isRedeemImage
{
    if (!_isRedeemImage) {
        _isRedeemImage = [[UIImageView alloc]initWithFrame:CGRectMake(self.titleLabel.right + 16, 22, 13, 13)];
        [_isRedeemImage setImage:[UIImage imageNamed:@"transer"]];
    }
    return _isRedeemImage;
}

@end
