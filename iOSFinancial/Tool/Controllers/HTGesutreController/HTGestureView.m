//
//  HTGestureView.m
//  iOSFinancial
//
//  Created by Mr.Yang on 15/4/16.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "HTGestureView.h"
#import "HTGestureConfig.h"

@interface HTGestureView ()
{
    BOOL _isFinish;
    BOOL _isError;
    int _signList[9];
}

@property (nonatomic, strong)   NSMutableArray *signViews;
@property (nonatomic, strong)   NSMutableArray *selectSignViews;

@property (nonatomic, strong)   UIImageView *imageView;

@property (nonatomic, assign)   CGPoint startPoint;
@property (nonatomic, assign)   CGPoint movePoint;
@property (nonatomic, assign)   BOOL isFinish;

@end

@implementation HTGestureView

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _imageView = [[UIImageView alloc] init];
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.userInteractionEnabled = NO;
        
        [self generateView];
        
        [self addSubview:_imageView];
        
        memset(_signList, 0, sizeof(_signList));
        
    }
    
    return self;
}

- (void)resetState
{
    _isError = NO;
    _isFinish = NO;
    _gesturePass = @"";
    
    [self changeImageViewState:3];
    
    _selectSignViews = nil;
    
    self.imageView.image = nil;
    [self bringSubviewToFront:self.imageView];
    
    memset(_signList, 0, sizeof(_signList));
}

- (NSMutableArray *)signViews
{
    if (!_signViews) {
        _signViews = [NSMutableArray array];
    }
    
    return _signViews;
}

- (NSMutableArray *)selectSignViews
{
    if (!_selectSignViews) {
        _selectSignViews = [NSMutableArray array];
    }
    
    return _selectSignViews;
}

- (void)generateView
{
    CGFloat size = cirleSize;
    if (__is47Inch) {
        size = 70;
        margin = 18.0f;
    }else if (__is55Inch) {
        size = 80;
        margin = 20.0f;
    }else {
        size = cirleSize;
        margin = 21.0f;
    }

    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat edgeInteval = (width - 2 * margin - size * 3) / 2.0f;
    _edgeMargin = edgeInteval;
    
//    width = 2 * margin + size * 3;
//    edgeInteval = 0.0f;
    
    UIImage *image = [UIImage imageNamed:@"dotUnsel"];
    for (int i = 0; i < 9; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.tag = i;
        imageView.userInteractionEnabled = NO;
        NSInteger row = i / 3;
        NSInteger span = i % 3;
        CGFloat locationX = edgeInteval + row * (margin + size);
        CGFloat locationY = edgeInteval + span * (margin + size);
        
        imageView.frame = CGRectMake(locationX, locationY, size, size);
        [self addSubview:imageView];
        
        [self.signViews addObject:imageView];
    }
    
    self.frame = CGRectMake(0, 0,  width , width);
    _imageView.frame = self.bounds;
    [self bringSubviewToFront:_imageView];
}

- (void)bringButtonsToFront
{
    for (UIView *view in self.signViews) {
        [self addSubview:view];
    }
}

- (void)showErrorGestureView
{
    [self changeImageViewState:0];
    
    _isError = YES;
    [self refreshGenerateView];
}

- (void)changeImageViewState:(NSInteger)state
{
    NSString *imageName = nil;
    if (state == 0) {
        //  error
        imageName = @"error";
        
    }else if (state == 1) {
        //  成功
        imageName = @"dotSel";
        
    }else {
        //  Normal
        imageName = @"dotUnsel";
    }
    
    for (UIImageView *imageView in self.selectSignViews) {
        imageView.image = [UIImage imageNamed:imageName];
    }
}

- (void)refreshGenerateView
{
    UIImage *image = [self generateGestureImage];
    [self bringButtonsToFront];
    _imageView.image = image;
}

- (UIImage *)generateGestureImage
{
    if (_selectSignViews.count == 0) return nil;
        
    UIImage *image = _imageView.image;
    CGFloat lineWith = kLineWith;
    
    UIGraphicsBeginImageContext(_imageView.size);
    UIColor *color = _isError ? [UIColor colorWithHEX:0xff0000] : [UIColor colorWithHEX:0xedd2af] ;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, lineWith);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetStrokeColorWithColor(context, [color CGColor]);
    
    CGPoint center;
    for (UIButton *selView in self.selectSignViews) {
        int index = (int)[self.selectSignViews indexOfObject:selView];
        
        center = selView.center;
        
        if (index == 0) {
            CGContextMoveToPoint(context, center.x, center.y);
        }else {
            CGContextAddLineToPoint(context, center.x, center.y);
        }
    }
    
    if (!_isFinish) {
        CGContextAddLineToPoint(context, self.movePoint.x, self.movePoint.y);
    }
    
    CGContextStrokePath(context);
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - TouchEvent
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touche = [touches anyObject];
    
    [self addSignViewByTouch:touche];
    
    _isFinish = NO;
    
    [self refreshGenerateView];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touche = [touches anyObject];
    
    [self addSignViewByTouch:touche];
    
    [self refreshGenerateView];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    _isFinish = YES;
    [self refreshGenerateView];
    
    //  call delegate
    if (self.selectSignViews.count && _delegate && [_delegate respondsToSelector:@selector(gestureViewDidFinish:andPass:)]) {
        [_delegate gestureViewDidFinish:_signList andPass:_gesturePass];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    _isFinish = YES;
    [self refreshGenerateView];
    
    //  call delegate
    if (self.selectSignViews.count && _delegate && [_delegate respondsToSelector:@selector(gestureViewDidFinish:andPass:)]) {
        [_delegate gestureViewDidFinish:_signList andPass:_gesturePass];
    }
}

- (void)addSignViewByTouch:(UITouch *)touche
{
    CGPoint location = [touche locationInView:self];
    _movePoint = location;
    
    for (UIImageView *imageView in self.signViews) {
        
        if (CGRectContainsPoint(imageView.frame, location)) {
            if (![self.selectSignViews containsObject:imageView]) {
                
                NSInteger tag = imageView.tag;
                //  手势密码
                NSString *pass = [NSString stringWithFormat:@"%d", (int)tag];
                
                if (_gesturePass == nil) {
                    _gesturePass = @"";
                }
                
                _gesturePass = [_gesturePass stringByAppendingString:pass];
                
                _signList[tag] = 1;
                UIImage *image = [UIImage imageNamed:@"dotSel"];
                imageView.image = image;
                [self.selectSignViews addObject:imageView];
                
                //  call delegate
                if (_delegate && [_delegate respondsToSelector:@selector(gestureViewChanging:)]) {
                    [_delegate gestureViewChanging:_signList];
                }
            }
            
            break;
        }
    }
}

@end
