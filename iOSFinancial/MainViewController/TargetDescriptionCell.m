//
//  TargetDescriptionCell.m
//  iOSFinancial
//
//  Created by Mr.Yang on 15/4/28.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "TargetDescriptionCell.h"
#import "NSString+Size.h"


@interface TargetDescriptionCell ()

@property (nonatomic, strong)   IBOutlet UIView *lineView;

@end

@implementation TargetDescriptionCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.lineView.backgroundColor = [UIColor jd_settingDetailColor];
    self.backgroundColor = [UIColor clearColor];
    
    self.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    self.titleLabel.textColor = [UIColor jd_darkBlackTextColor];
    
    self.promptLabel.textColor = [UIColor jd_globleTextColor];
    
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.promptLabel.backgroundColor = [UIColor clearColor];
}

- (void)setPrompt:(NSString *)prompt
{
    _prompt = prompt;
    
    self.promptLabel.text = _prompt;
    [self layoutIfNeeded];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [_promptLabel sizeToFit];
    
    _promptLabel.size = [_promptLabel sizeThatFits:CGSizeMake(APPScreenWidth - 30, NSIntegerMax)];
    
}

+ (CGFloat)heightForText:(NSAttributedString *)text
{
    CGSize size = [self attributeSizeWithSize:CGSizeMake(APPScreenWidth - 30, NSIntegerMax) andAttributeString:text];
    
    return size.height + 66.0f;
}

+ (CGSize)attributeSizeWithSize:(CGSize)size andAttributeString:(NSAttributedString *)string
{
    return [string boundingRectWithSize:size
                              options:NSStringDrawingUsesLineFragmentOrigin
                              context:nil
            ].size;
}

@end
