
//
//  ActionsCell.m
//  iOSFinancial
//
//  Created by Mr.Yang on 15/6/9.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "ActionsCell.h"
#import <SDWebImage/UIButton+WebCache.h>
#import "UIView+Layer.h"
#import "UIView+NoneDataView.h"

@interface ActionsCell ()

@property (nonatomic, strong)   IBOutlet UIButton *button1;
@property (nonatomic, strong)   IBOutlet UIButton *button2;
@property (nonatomic, strong)   IBOutlet UIButton *button3;
@property (nonatomic, strong)   IBOutlet UIButton *button4;

@end

@implementation ActionsCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [_button1 cornerRadius5];
    [_button2 cornerRadius5];
    [_button3 cornerRadius5];
    [_button4 cornerRadius5];
    
    /*
    [_button1 setBackgroundImage:HTImage(@"loadingWating2")forState:UIControlStateNormal];
    [_button2 setBackgroundImage:HTImage(@"loadingWating2") forState:UIControlStateNormal];
    [_button3 setBackgroundImage:HTImage(@"loadingWating2") forState:UIControlStateNormal];
    [_button4 setBackgroundImage:HTImage(@"loadingWating2") forState:UIControlStateNormal];
    */
    
    [_button1 showNoneDataView];
    [_button2 showNoneDataView];
    [_button3 showNoneDataView];
    [_button4 showNoneDataView];
    
}

+ (CGFloat)fixedHeight
{
    if (is55Inch) {
        return 260.0f;
    }
    
    return 270.0f;
}

- (void)refreshImages:(NSArray *)images
{
    for (NSInteger i = 0; i < images.count; i++) {
        
        NSString *imageStr = [images objectAtIndex:i];
        UIButton *button;
        switch (i) {
            case 0:button = _button1;break;
            case 1:button = _button2;break;
            case 2:button = _button3;break;
            case 3:button = _button4;break;
            default:
                button = nil;
                break;
        }
        
        __weak UIButton *weakButton = button;
        [button sd_setBackgroundImageWithURL:HTURL(imageStr)forState:UIControlStateNormal placeholderImage:HTImage(@"loadingWating2") completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (!error) {
                [weakButton removeNoneDataView];
            }
        }];
    }
}

- (IBAction)buttonClicked:(UIButton *)sender
{
    if (_touchBlock) {
        _touchBlock (self, sender.tag);
    }
    
}

@end
