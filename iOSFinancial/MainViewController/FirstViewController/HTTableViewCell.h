//
//  HTTableViewCell.h
//  iOSFinancial
//
//  Created by Mr.Yang on 15/4/1.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "HTBaseCell.h"
#import "HTBaseSource.h"

@interface TableViewSource : HTBaseSource

@property (nonatomic, copy) NSString *subTitle;

@end

@interface HTTableViewCell : HTBaseCell


@end

