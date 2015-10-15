//
//  CustomerCell.h
//  iOSFinancial
//
//  Created by Mr.Yang on 15/4/1.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "HTBaseCell.h"
#import "HTBaseSource.h"


@interface CustomerCellSource : HTBaseSource

//@property (nonatomic, copy) NSString *title;

@end

@interface CustomerCell : HTBaseCell

@property (nonatomic, weak) IBOutlet UILabel *titleLabel1;
@property (nonatomic, weak) IBOutlet UIButton *button;

@end
