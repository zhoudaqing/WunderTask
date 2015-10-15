//
//  AboutUsViewController.m
//  iOSFinancial
//
//  Created by Mr.Yan on 15/4/17.
//  Copyright (c) 2015年 Mr.Yang. All rights reserved.
//

#import "AboutUsViewController.h"
#import "HTVersionManager.h"
#import "HTBaseView.h"
#import "HTWebViewController.h"

@interface VersionView : HTBaseView

@property (nonatomic, strong)   IBOutlet UILabel *nameLabel;
@property (nonatomic, strong)   IBOutlet UILabel *versionLabel;
@property (nonatomic, strong)   IBOutlet UIImageView *imageView;

@end

@implementation VersionView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.nameLabel.textColor = [UIColor jd_globleTextColor];
    
    self.versionLabel.textColor = [UIColor jd_globleTextColor];
    self.imageView.layer.cornerRadius = 15.0f;
    self.imageView.layer.masksToBounds = YES;

    self.imageView.backgroundColor = HTRedColor;
    self.backgroundColor = HTClearColor;
}

@end


@interface AboutUsViewController ()
{
    
}

@property (nonatomic, strong) NSArray *functionTitle;

@property (nonatomic, strong) NSArray *functionDetail;

@end

@implementation AboutUsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _functionTitle = @[
                       @"官方网站",
                       @"官方微信",
                       @"客服电话"
                       ];
    
    _functionDetail = @[
                        kWebServiceURL_f,
                        kWeiChatPublic,
                        kServicePhone_f
                        ];

    
    VersionView *view = [VersionView xibView];
    view.versionLabel.text = HTSTR(@"V%@",[[HTVersionManager sharedManager] localVersion]);
    view.imageView.image = HTImage(@"app_icon");
    self.tableView.tableHeaderView = view;
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"aboutUsCellIdentifier";
    
    HTBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        cell = [[HTBaseCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
    }
    
    cell.textLabel.text = self.functionTitle[indexPath.row];
    
    cell.detailTextLabel.text = [self functionDetail:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger row = indexPath.row;
    
    if (row == 0) {
        HTWebViewController *webController = [[HTWebViewController alloc] init];
        webController.url = HTURL(kWebServiceURL);
        webController.title = @"简单理财网";
        webController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:webController animated:YES];
        
    }else if (row == 1) {
        UIPasteboard *board = [UIPasteboard generalPasteboard];
        board.string = _functionDetail[1];
        
        [self showAlert:HTSTR(@"已将[%@]复制到粘贴板,还请进入微信添加公众账号", _functionDetail[1])];
        
    }else if (row == 2) {
        NSString *telphone = HTSTR(@"telprompt://%@",kServicePhone);
        [[UIApplication sharedApplication] openURL:HTURL(telphone)];
    }
    
}

#pragma mark - Config

- (NSString *)functionDetail:(NSIndexPath *)indexPath
{
    if (indexPath.row == NSIntegerMax) {
        HTVersionManager *manager = [HTVersionManager sharedManager];
        if (manager.isNewest) {
            return @"已是最新版本";
        }else {
            return manager.localVersion;
        }
    }

    return self.functionDetail[indexPath.row];
}

@end
