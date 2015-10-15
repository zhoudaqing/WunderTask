//
//  InvitationFriednTableViewCell.m
//  iOSFinancial
//
//  Created by Mr.Yan on 15/5/11.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "InvitationFriednTableViewCell.h"

@interface InvitationFriednTableViewCell ()

@property (nonatomic) NSArray *bottom1Title;

@property (nonatomic) NSArray *bottom2Title;

@property (nonatomic) NSArray *top1Title;

@property (nonatomic) NSArray *top2Title;

@end



@implementation InvitationFriednTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

//  MARK:布局子图标的位置
- (void)layoutCellSubviews
{
    UIView *HorizontalRimeLine = [Sundry  rimLine];
    HorizontalRimeLine.frame = CGRectMake(27.0, 91.5, APPScreenWidth - 27*2, .5);
    [self addSubview:HorizontalRimeLine];
    
    for (int i = 0; i <3; i ++) {
        if (i > 0) {
            UIView *rimeline = [Sundry  rimLine];
            rimeline.frame = CGRectMake(i*APPScreenWidth/3.0, (91.5 - 53)*.5, .5, 53);
            [self addSubview:rimeline];
        }
        
        UILabel *bottom1Lable = [self bottomLableStyleWithNumber:i withTitleArray:self.bottom1Title];
        [self addSubview:bottom1Lable];
        
        UILabel *top1Lable = [self topLableStyleWithNumber:i withTitleArray:self.top1Title];
        [self addSubview:top1Lable];
        
        
    }
    
    UIView *verticalRimeLine = [Sundry rimLine];
    verticalRimeLine.frame = CGRectMake(APPScreenWidth*.5, 91.5 + 19.25, .5, 53);
    [self addSubview:verticalRimeLine];
    
    for (int i = 0; i < 2; i++) {
        UILabel *bottom2Lable = [self bottomLableStyleWithNumber:i withTitleArray:self.bottom2Title];
        bottom2Lable.center = CGPointMake(bottom2Lable.centerX, bottom2Lable.centerY + 91.5);
        [self addSubview:bottom2Lable];
        
        
        UILabel *top2Lable = [self topLableStyleWithNumber:i withTitleArray:self.top2Title];
        top2Lable.center = CGPointMake(top2Lable.centerX, top2Lable.centerY + 91.5);
        [self addSubview:top2Lable];
        
    }
    
}





- (UILabel *)topLableStyleWithNumber:(int)i withTitleArray:(NSArray *)array
{
    UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(i*APPScreenWidth/array.count, 22.5, APPScreenWidth/array.count, 17.0)];
    lable.font = [UIFont systemFontOfSize:17.0];
    lable.textColor = [UIColor jd_barTintColor];
    lable.textAlignment = NSTextAlignmentCenter;
    lable.text = array[i];
    return lable;
    
}

- (UILabel *)bottomLableStyleWithNumber:(int)i withTitleArray:(NSArray *)array
{
    UILabel *lable = [[UILabel alloc]initWithFrame:CGRectMake(i*APPScreenWidth/array.count, 59.5, APPScreenWidth/array.count, 12.0)];
    lable.font = [UIFont systemFontOfSize:12.0];
    lable.textColor = [UIColor jd_darkBlackTextColor];
    lable.textAlignment = NSTextAlignmentCenter;
    lable.text = array[i];
    return lable;
}

- (NSArray *)bottom1Title
{
    if (!_bottom1Title) {
        _bottom1Title = @[@"我邀请的用户(位)",@"充值用户(位)",@"投资用户(位)"];
    }
    return _bottom1Title;
}

- (NSArray *)bottom2Title
{
    if (!_bottom2Title) {
        _bottom2Title = @[@"已获红包合计(元)",@"已获奖励合计(元)"];
    }
    return _bottom2Title;
}

- (NSArray *)top1Title
{
    if (!_top1Title) {
        _top1Title = @[self.myInvitationFriendS, self.rechargeFriends, self.investFriends];
        }
    return _top1Title;
}

- (NSArray *)top2Title
{
    if (!_top2Title) {
        _top2Title = @[self.getRedEnvelope, self.getedAwards];
    }
    return _top2Title;
}

- (NSString *)myInvitationFriendS
{
    if (!_myInvitationFriendS) {
        _myInvitationFriendS = @"0";
    }
    return _myInvitationFriendS;
}

- (NSString *)rechargeFriends
{
    if (!_rechargeFriends) {
        _rechargeFriends = @"0";
    }
    return _rechargeFriends;
}

- (NSString *)investFriends
{
    if (!_investFriends) {
        _investFriends = @"0";
    }
    return _investFriends;
}

- (NSString *)getRedEnvelope
{
    if (!_getRedEnvelope) {
        _getRedEnvelope = @"0.00";
    }
    return _getRedEnvelope;
}

- (NSString *)getedAwards
{
    if (!_getedAwards) {
        _getedAwards = @"0.00";
    }
    return _getedAwards;
}
@end
