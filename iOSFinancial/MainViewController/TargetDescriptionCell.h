//
//  TargetDescriptionCell.h
//  iOSFinancial
//
//  Created by Mr.Yang on 15/4/28.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

///

#import "HTBaseCell.h"

@interface TargetDescriptionCell : HTBaseCell


@property (nonatomic, strong)   IBOutlet UILabel *titleLabel;
@property (nonatomic, strong)   IBOutlet UILabel *promptLabel;
@property (nonatomic, copy) NSString *prompt;


+ (CGFloat)heightForText:(NSAttributedString *)text;

@end
