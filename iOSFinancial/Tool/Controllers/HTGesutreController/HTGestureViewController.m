//
//  HTGestureViewController.m
//  iOSFinancial
//
//  Created by Mr.Yang on 15/4/17.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "HTGestureViewController.h"
#import "HTGestureView.h"
#import "HTGestureInditaor.h"
#import "HTGestureConfig.h"
#import "LogOrRegViewController.h"



@interface HTGestureViewController () <HTGestureViewProtocal>

@property (nonatomic, assign) GestureType gestureType;
@property (nonatomic, strong)   HTGestureView *gesutreView;
@property (nonatomic, strong)   HTGestureInditaor *indicator;
@property (nonatomic, strong)   UILabel *nameLabel;

@property (nonatomic, strong)   UILabel *prompt;

//  重新设置的Button
@property (nonatomic, strong)   UIButton *reloginButton;
@property (nonatomic, strong)   UIButton *forgotButton;
@property (nonatomic, strong)   UIBarButtonItem *resetBarbutton;

//  第一次输入的密码
@property (nonatomic, copy)     NSString *firstPass;

//  重试的次数
@property (nonatomic, assign)  NSInteger retryCount;

//  保存的密码
@property (nonatomic, copy) NSString *userGesturePass;

//  显示的是登陆对话框
@property (nonatomic, assign) BOOL isShowLogin;

@end

@implementation HTGestureViewController

+ (BOOL)isHaveSetGesturePass
{
    NSString *gesutre = [self readGesturePass];
    
    return gesutre.length > 0;
}

+ (BOOL)clearGesturePass
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setValue:@"" forKey:kUserInputGesturePass];
    
   return [defaults synchronize];
}

+ (NSString *)readGesturePass
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *gesturePass = [defaults valueForKey:kUserInputGesturePass];
    
    return gesturePass;
}

+ (BOOL)saveGesturePass:(NSString *)string
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setValue:string forKey:kUserInputGesturePass];
    
   return [defaults synchronize];
}

- (id)init
{
    self = [super init];
    
    if (self) {
        _shouldCancel = YES;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *backImageView = [[UIImageView alloc] initWithImage:HTImage(@"backImageVIew")];
    backImageView.frame = self.view.bounds;
    [self.view addSubview:backImageView];
    
    self.view.backgroundColor = [UIColor jd_accountBackColor];
    
    [self.view addSubview:self.prompt];
    [self.view addSubview:self.gesutreView];
    
    self.gestureType = [HTGestureViewController isHaveSetGesturePass] ? GestureTypeInputPass : GestureTypeSetPass;
    
    if (_gestureType == GestureTypeSetPass) {
        self.prompt.text = @"请绘制解锁图案";
        _shouldCancel = NO;
    }else {
        
        self.prompt.text = @"请输入解锁图案";
        _userGesturePass = [HTGestureViewController readGesturePass];
        [self.view addSubview:self.reloginButton];
        [self.view addSubview:self.forgotButton];
    }
    
    self.shouldCancel = _shouldCancel;
    
    [self setUserName:[Sundry nameWithString:[User sharedUser].userNickName]];
    
    [self changeStateBarStyleLight:YES];
};

- (void)setShouldCancel:(BOOL)shouldCancel
{
    _shouldCancel = shouldCancel;
    
    if (_shouldCancel) {
        [self addCloseBarbutton];
    }else {
        self.navigationItem.leftBarButtonItem = nil;
    }
}

//  设置用户名
- (void)setUserName:(NSString *)userName
{
    if (![_userName isEqualToString:userName]) {
        _userName = userName;
        self.nameLabel.text = [NSString stringWithFormat:@"%@", _userName];
        [self.nameLabel sizeToFit];
        [self layoutSubView];
    }
}

- (void)dismissViewController
{
    [self dismissViewControllerAnimated:YES completion:^ {
        
    }];
}

#pragma mark - LazyLoad

- (void)setGestureType:(GestureType)gestureType
{
    if (_gestureType != gestureType) {
        _gestureType = gestureType;
        [self layoutSubView];
        [self refresTitle];
    }
}

- (void)refresTitle
{
    if (_gestureType == GestureTypeSetPass) {
        self.title = @"请绘制解锁图案";
    }else {
        self.title = @"请输入解锁图案";
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (_isShowLogin) {
        //  显示的时登陆界面的话，则跳过
        return;
    }
    
    [self layoutSubView];
}

//  设置界面布局
- (void)layoutSubView
{
    CGRect screenFrame = [[UIScreen mainScreen] bounds];
    
    //  手势视图
    CGRect frame = self.gesutreView.frame;
    frame.origin.x = (CGRectGetWidth(screenFrame) - CGRectGetWidth(frame)) / 2.0f;
    
    CGFloat subtractY, psubtractY;
    if (is35Inch) {
         subtractY = 60;
         psubtractY = 0;
    }else
    {
         subtractY = 20;
         psubtractY = 30;
    }
    
    frame.origin.y = CGRectGetHeight(self.view.frame) / 2.0f -  self.gesutreView.edgeMargin * 2 - subtractY;
    self.gesutreView.frame = frame;
    
    //  提示框
    frame = self.prompt.frame;
    frame.size.height = 20.0f;
    frame.size.width = CGRectGetWidth(self.view.frame);
    frame.origin.x = 0;
    frame.origin.y = CGRectGetMinY(self.gesutreView.frame) + self.gesutreView.edgeMargin / 2.0f - CGRectGetHeight(self.prompt.frame) - psubtractY;
    self.prompt.frame = frame;
    [self.view addSubview:self.prompt];
    
    
    //  设置密码
    if (_gestureType == GestureTypeSetPass) {
        [_nameLabel removeFromSuperview];
        _nameLabel = nil;
        
        [self.view addSubview:self.indicator];
        
        frame = self.indicator.frame;
        frame.origin.x = (CGRectGetWidth(screenFrame) - CGRectGetWidth(frame)) / 2.0f;
        frame.origin.y = CGRectGetMinY(self.prompt.frame) - CGRectGetHeight(self.indicator.frame) - 20.0f;
        self.indicator.frame = frame;
        
    }else {
        //  输入密码
        [_indicator removeFromSuperview];
        _indicator = nil;
        
        [self.view addSubview:self.nameLabel];
        
        frame = self.nameLabel.frame;
        frame.origin.x = (CGRectGetWidth(screenFrame) - CGRectGetWidth(frame)) / 2.0f;
        frame.origin.y = CGRectGetMinY(self.prompt.frame) - 30.0f;
        self.nameLabel.frame = frame;
        
        frame = self.forgotButton.frame;
        frame.origin.x = 30.0f;
        frame.origin.y = CGRectGetHeight(self.view.frame) - CGRectGetHeight(frame) - 30.0f;
        self.forgotButton.frame = frame;
        
        frame = self.reloginButton.frame;
        frame.origin.x = CGRectGetWidth(self.view.frame) - CGRectGetWidth(frame) - 30.0f;
        frame.origin.y = CGRectGetHeight(self.view.frame) - CGRectGetHeight(frame) - 30.0f;
        self.reloginButton.frame = frame;
    }
    
}

#pragma mark - ResetButtonClick

- (void)resetButtonClicked:(UIButton *)button
{
    [self prompt:4 animate:NO];
    
    [self resetState];
}

#pragma mark - ReloginButtonClicked
- (void)reloginButtonClicked:(UIButton *)button
{
    [self showUserLoginView];
}

//  MARK:忘记密码
- (void)forgotButtonClicked:(UIButton *)button
{
    [self showUserLoginView];
}

#pragma mark - ResetState

- (void)resetState
{
    _retryCount = 0;
    _firstPass = nil;
    _reloginButton.hidden = YES;
    self.navigationItem.rightBarButtonItem = nil;
    _prompt.textColor = [UIColor whiteColor];
    
    [self resetGestureView];
}

- (void)resetGestureView
{
    [_gesutreView resetState];
    [_indicator resetSignViewState];
}

- (void)resetOnlyGestureView
{
    [_gesutreView resetState];
}

#pragma mark - GestureViewProtocal

- (void)gestureViewDidFinish:(int *)list andPass:(NSString *)pass
{
    if (_gestureType == GestureTypeSetPass) {
        //  设置密码
        [self changeSignListView:list andPass:pass];
        
    }else {
        //  登陆
        [self judgeInputUserGesture:list andPass:pass];
    }
}

- (void)gestureViewChanging:(int *)list
{
    if (_gestureType == GestureTypeSetPass) {
        if (!_firstPass) {
            [_indicator refreshSignList:list];
        }
    }
}

#pragma mark - End

//  MARK:检测手势密码输入
- (void)judgeInputUserGesture:(int *)list andPass:(NSString *)pass
{
    if (pass.length < 4) {
        
        [self prompt:0 animate:YES];
        
        [_gesutreView showErrorGestureView];
        
        if (isEmpty(_firstPass)) {
            [self performSelector:@selector(resetGestureView) withObject:nil afterDelay:.25f];
        }else {
            [self performSelector:@selector(resetOnlyGestureView) withObject:nil afterDelay:.25f];
        }
        
    }else if ([pass isEqualToString:self.userGesturePass]) {
        //  验证成功
        
        [[NSNotificationCenter defaultCenter] postNotificationName:__USER_INPUT_GESURE_SUCCESS object:nil];
        
        [self showHudSuccessView:@"验证成功"];
        
        //  更改Tabbar的位置
        [self changeTabbarIndex];
        
        [self performSelector:@selector(dismissViewController) withObject:nil afterDelay:1.0f];
        
    }else {
        //  两次输入的密码不相同
        _retryCount++;
        
        if (_retryCount > 1) {
            
            if (_retryCount == kRetryCount) {
                //  已经没有重试的次数
                [self showUserLoginView];
                return;
                
            }else {
                [self animateLayer:self.forgotButton.layer];
                [self prompt:3 animate:NO];
            }
        }else {
            
            [self prompt:3 animate:YES];
        }
        
        [_gesutreView showErrorGestureView];
        [self performSelector:@selector(resetOnlyGestureView) withObject:nil afterDelay:.25f];
    }
}

//  MARK:检测手势设置
- (void)changeSignListView:(int *)list andPass:(NSString *)pass
{
    if (pass.length < 4) {
        
        [self prompt:0 animate:YES];
        
        [_gesutreView showErrorGestureView];
        
        if (isEmpty(_firstPass)) {
            [self performSelector:@selector(resetGestureView) withObject:nil afterDelay:.25f];
        }else {
            [self performSelector:@selector(resetOnlyGestureView) withObject:nil afterDelay:.25f];
        }
        
    }else {
        
        if (!_firstPass || _firstPass.length == 0) {
            
            //  第一次输入
            _firstPass = pass;
            [_indicator refreshSignList:list];
            
            [self prompt:5 animate:NO];
            
            [_gesutreView resetState];
            
        }else if ([_firstPass isEqualToString:pass]) {
            // 成功
            
            [self showHudSuccessView:@"设置成功"];
            //  存储密码
            [HTGestureViewController saveGesturePass:pass];
            
            [self prompt:NSIntegerMax animate:NO];
            
            //  设置手势成功
            [[NSNotificationCenter defaultCenter] postNotificationName:__USER_SET_GESTURE_SUCCESS object:nil];
            
            [self performSelector:@selector(dismissViewController) withObject:nil afterDelay:1.0f];
            
        }else {
            
            //  两次输入的密码不相同
            _retryCount++;
            
            self.navigationItem.rightBarButtonItem = self.resetBarbutton;

            if (_retryCount > 1) {
                [self shadowAnimateLayer:self.resetBarbutton.customView.layer];
                [self prompt:2 animate:NO];
                
            }else {
                [self prompt:2 animate:YES];
            }
            
            [_gesutreView showErrorGestureView];
            [self performSelector:@selector(resetOnlyGestureView) withObject:nil afterDelay:.25f];
        }
    }
}

//  显示用户密码登陆页面
- (void)showUserLoginView
{
    //  手势验证失败，重新登陆
    [[User sharedUser] doLoginOut];
    
    self.isShowLogin = YES;
    
    LogOrRegViewController *loginVC = [[LogOrRegViewController alloc] init];
    [loginVC addHeadBtnType:Login];
    
    CATransition *transition = [CATransition animation];
    transition.type = @"oglFlip";
    transition.subtype = kCATransitionFromLeft;
    transition.duration = .8;
    transition.timingFunction = UIViewAnimationCurveEaseInOut;
    
    [self addChildViewController:loginVC];
    [self.view addSubview:loginVC.view];
    loginVC.view.frame = self.view.bounds;
    [self.view.layer addAnimation:transition forKey:@"flip"];
}

- (void)prompt:(NSInteger)code animate:(BOOL)animate
{
    self.prompt.textColor = code > 4 ? [UIColor whiteColor] : [UIColor whiteColor];
    self.prompt.text = [self showPromptString:code];
    
    if (animate) {
        [self animateLayer:self.prompt.layer];
    }
}

//  状态码
- (NSString *)showPromptString:(NSInteger)code
{
    switch (code) {
            
        case 0:return @"至少连接4个点";
        case 5:return @"再次绘制解锁图案";
        case 2:return @"两次绘制的图案不一样,请重新绘制";
        case 3:return [NSString stringWithFormat:@"密码错误,还有%ld次机会", (long)(kRetryCount - _retryCount)];
        case 4:return @"请重新绘制";
        default:
            return @"输入成功";
    }
    
    return [NSString stringWithFormat:@"~~Error:%ld", (long)code];
}

- (void)animateLayer:(CALayer *)layer
{
    CGPoint position = [layer position];
    CGPoint y = CGPointMake(position.x - 5, position.y);
    CGPoint x = CGPointMake(position.x + 5, position.y);
    
    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setTimingFunction:[CAMediaTimingFunction
                                  functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    [animation setFromValue:[NSValue valueWithCGPoint:x]];
    [animation setToValue:[NSValue valueWithCGPoint:y]];
    [animation setAutoreverses:YES];
    [animation setDuration:0.08];
    [animation setRepeatCount:3];
    
    [layer addAnimation:animation forKey:nil];
}

- (void)shadowAnimateLayer:(CALayer *)layer
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.fromValue = @(1.0f);
    animation.toValue = @(.5f);
    animation.autoreverses = YES;
    animation.duration = .1;
    animation.repeatCount = 3;
    
    [layer addAnimation:animation forKey:@"shadowAnimate"];
}

- (UILabel *)prompt
{
    if (!_prompt) {
        _prompt = [[UILabel alloc] init];
        //[UIColor colorWithHEX:0x666666]
        _prompt.textColor = [UIColor whiteColor];
        _prompt.font = [UIFont systemFontOfSize:14.0f];
        _prompt.textAlignment = NSTextAlignmentCenter;
    }
    
    return _prompt;
}

- (UILabel *)nameLabel
{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.font = [UIFont systemFontOfSize:14.0f];
    }
    
    return _nameLabel;
}

- (HTGestureView *)gesutreView
{
    if (!_gesutreView) {
        _gesutreView = [[HTGestureView alloc] init];
        _gesutreView.delegate = self;
    }
    
    return _gesutreView;
}

- (HTGestureInditaor *)indicator
{
    if (!_indicator) {
        _indicator = [[HTGestureInditaor alloc] init];
    }
    
    return _indicator;
}

- (UIButton *)reloginButton
{
    if (!_reloginButton) {
        _reloginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_reloginButton setTitle:@"登录其它账户" forState:UIControlStateNormal];
        [_reloginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _reloginButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [_reloginButton addTarget:self action:@selector(reloginButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_reloginButton sizeToFit];
    }
    
    return _reloginButton;
}

- (UIButton *)forgotButton
{
    if (!_forgotButton) {
        _forgotButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_forgotButton setTitle:@"忘记手势密码" forState:UIControlStateNormal];
        [_forgotButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _forgotButton.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [_forgotButton addTarget:self action:@selector(forgotButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_forgotButton sizeToFit];
    }
    
    return _forgotButton;
}

- (UIBarButtonItem *)resetBarbutton
{
    if (!_resetBarbutton) {
        UIButton *resetButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [resetButton setFrame:CGRectMake(0, 0, 33, 26)];
        [resetButton setTitle:@"重设" forState:UIControlStateNormal];
        [resetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        resetButton.titleLabel.font = [UIFont systemFontOfSize:16.0f];
        [resetButton addTarget:self action:@selector(resetButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        _resetBarbutton = [[UIBarButtonItem alloc] initWithCustomView:resetButton];
    }
    
    return _resetBarbutton;
}

@end
