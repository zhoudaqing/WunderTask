//
//  CustomerCell.m
//  iOSFinancial
//
//  Created by Mr.Yang on 15/4/1.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "CustomerCell.h"

@implementation CustomerCellSource

- (CGFloat)height
{
    return 74.0f;
}

+ (Class)cellClass
{
    return [CustomerCell class];
}

@end

@implementation CustomerCell

- (void)configWithSource:(id)source
{
    CustomerCellSource *cellSource = (CustomerCellSource *)source;
    
    self.titleLabel1.text = cellSource.title;

}

- (IBAction)buttonClicked:(id)sender
{
    if (self.actions.detailAction) {
        self.actions.detailAction (nil, self, nil);
    }
}

@end
