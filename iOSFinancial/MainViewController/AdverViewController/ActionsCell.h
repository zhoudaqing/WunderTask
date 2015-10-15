//
//  ActionsCell.h
//  iOSFinancial
//
//  Created by Mr.Yang on 15/6/9.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "HTBaseCell.h"

@interface ActionsCell : HTBaseCell

@property (nonatomic, copy) void(^touchBlock)(ActionsCell *cell, NSInteger index);

- (void)refreshImages:(NSArray *)images;

@end
