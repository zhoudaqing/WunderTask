//
//  InvitationFriednTableViewCell.h
//  iOSFinancial
//
//  Created by Mr.Yan on 15/5/11.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InvitationFriednTableViewCell : UITableViewCell

@property (nonatomic) NSString *myInvitationFriendS;

@property (nonatomic) NSString *rechargeFriends;

@property (nonatomic) NSString *investFriends;

@property (nonatomic) NSString *getRedEnvelope;

@property (nonatomic) NSString *getedAwards;

- (void)layoutCellSubviews;

@end
