//
//  HTTableViewCell.m
//  iOSFinancial
//
//  Created by Mr.Yang on 15/4/1.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "HTTableViewCell.h"


@implementation TableViewSource

+ (Class)cellClass
{
    return [HTTableViewCell class];
}

@end

@implementation HTTableViewCell

+ (CGFloat)fixedHeight
{
    return 30.0f;
}

+ (BOOL)isNib
{
    return NO;
}

+ (UITableViewCellStyle)tableViewCellStyle
{
    return UITableViewCellStyleDefault;
}

- (void)configWithSource:(id)source
{
    if ([source isKindOfClass:[TableViewSource class]]) {
        TableViewSource *tableSource = (TableViewSource *)source;
        
        self.textLabel.text = tableSource.title;
        self.detailTextLabel.text = tableSource.subTitle;
    }
}

@end



