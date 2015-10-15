//
//  WeixinImageVIew.m
//  iOSFinancial
//
//  Created by Mr.Yang on 15/5/26.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#define __LABEL_HEIGHT  14.0f
#define __Back_View_Height  56.0f

#import "WeiXinImageView.h"

@interface WeiXinImageView ()

@property (nonatomic, strong)   UILabel *titleLabel;

@end

@implementation WeiXinImageView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self addSubview:self.titleLabel];
    
    self.titleLabel.frame = CGRectMake(0, self.height / 2.0f - __LABEL_HEIGHT, self.width, __LABEL_HEIGHT);
    
    self.titleLabel.height = __LABEL_HEIGHT;
    self.titleLabel.top = self.height / 2.0f - __LABEL_HEIGHT / 2.0f;
    CGFloat width = sqrt(2 * (__Back_View_Height * __Back_View_Height));
    self.titleLabel.left = (__Back_View_Height - width) / 2.0f;
    self.titleLabel.width = width;
    
    _titleLabel.layer.anchorPoint = CGPointMake(.5, 1);
    _titleLabel.layer.transform = CATransform3DMakeRotation(M_PI_4, 0, 0, 1);
    
}

- (void)setTitleSring:(NSString *)title
{
    self.titleLabel.text = title;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = HTFont(10.0f);
    }
    
    return _titleLabel;
}

@end
