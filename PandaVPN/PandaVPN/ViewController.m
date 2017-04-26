//
//  ViewController.m
//  PandaVPN
//
//  Created by mac on 2017/4/12.
//  Copyright © 2017年 Andox. All rights reserved.
//

#import "ViewController.h"
#import "UIView+YGPulseView.h"
#import "HostViewController.h"
#import "InformationViewController.h"
#import "DurationViewController.h"
#import "ServiceViewController.h"
#import "AboutViewController.h"

@interface ViewController ()

@property (strong, nonatomic) NSArray *stringArray;
@property (strong, nonatomic) NSArray *statusArray;
@property (strong, nonatomic) NSArray *iconArray;

@property (nonatomic, strong) VPNInfo *vpnConfig;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.stringArray = [[NSArray alloc]initWithObjects:@"选择线路", @"账户信息", @"有效时间", @"", @"联系客服", @"关于PandaVPN", nil];
    self.statusArray = [[NSArray alloc]initWithObjects:@"线路1", @"Andox", @"无限制", @"", @"", @"", nil];
    self.iconArray = [[NSArray alloc]initWithObjects:@"Icon_host", @"Icon_account", @"Icon_clock", @"", @"Icon_headphone", @"Icon_info", nil];
    
    ///vpn配置
    self.vpnConfig = [[VPNInfo alloc] init];
    self.vpnConfig.serverAddress = @"45.77.29.224";
    self.vpnConfig.remoteID = @"45.77.29.224";
    self.vpnConfig.username = @"myUserName";
    self.vpnConfig.password = @"myUserPass";
    self.vpnConfig.sharedSecret = @"myPSKkey";
    self.vpnConfig.preferenceTitle = @"PandaVPN";
    
}

#pragma mark tableViewDelegate DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.stringArray.count+1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 280;
    }
    if (indexPath.row == 4) {
        return 10;
    }
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.row == 0) {
        PandaConnectCell *_cell = [tableView dequeueReusableCellWithIdentifier:@"PandaConnectCell"];
        _cell.selectionStyle = UITableViewCellSelectionStyleNone;
        _cell.vpnInfo = self.vpnConfig;
        cell = _cell;
    }
    else if (indexPath.row == 4) {
        PandaGrayCell *_cell = [tableView dequeueReusableCellWithIdentifier:@"PandaGrayCell"];
        _cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell = _cell;
    }
    else {
        PandaCell *_cell = [tableView dequeueReusableCellWithIdentifier:@"PandaCell"];
        _cell.titleLabel.text = [self.stringArray objectAtIndex:indexPath.row-1];
        _cell.statusLabel.text = [self.statusArray objectAtIndex:indexPath.row-1];
        _cell.iconView.image = [[UIImage imageNamed:[self.iconArray objectAtIndex:indexPath.row-1]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell = _cell;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc;
    switch (indexPath.row) {
        case 1:
            vc = [sb instantiateViewControllerWithIdentifier:@"HostViewController"];
            break;
        case 2:
            vc = [sb instantiateViewControllerWithIdentifier:@"InformationViewController"];
            break;
        case 3:
            vc = [sb instantiateViewControllerWithIdentifier:@"DurationViewController"];
            break;
        case 5:
            vc = [sb instantiateViewControllerWithIdentifier:@"ServiceViewController"];
            break;
        case 6:
            vc = [sb instantiateViewControllerWithIdentifier:@"AboutViewController"];
            break;
        default:
            break;
    }
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

@implementation PandaConnectCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.connectButton.layer.cornerRadius = 60;
    
    self.connectionManager = [VPNConnectionManager VPNConnection];
    self.connectionManager.delegate = self;
}

- (IBAction)connect:(id)sender {
    [self.connectButton startPulseWithColor:[UIColor colorWithRed:0/255.0 green:151/155.0 blue:245/255.0 alpha:1.0] animation:YGPulseViewAnimationTypeRadarPulsing];
    self.connectButton.userInteractionEnabled = NO;
    
    if (_vpnInfo.serverAddress.length < 1) {
        //VPN 信息不完整
        return ;
    }
    
    [_connectionManager checkVPNPreferenceSuccess:^(BOOL isInstalled) {
        if (isInstalled) {
            // 判断当前连接状态是否为正在连接，或者已连接上
            VPNStatus status = [_connectionManager getCurrentStatus];
            if (status == VPNStatusConnecting || status == VPNStatusConnected) {
                // 断开 VPN 连接
                [_connectionManager stopVPNConnectSuccess:^{
                    
                }];
            } else {
                // 开始之前刷新一下信息
                [_connectionManager modifyVPNPreferenceWithData:_vpnInfo success:^{
                    [_connectionManager startVPNConnectSuccess:^{
                        
                    }];
                }];
            }
        } else {
            // 安装 VPN 配置
            [_connectionManager createVPNPreferenceWithData:_vpnInfo success:^{
                // 安装完成之后，开始连接 VPN
                [_connectionManager startVPNConnectSuccess:^{
                    
                }];
            }];
        }
    }];
}

#pragma mark - VPNConnectionDelegate
- (void)vpnConnectionDidRecieveError:(VpnConnectorError)error {
    switch (error) {
        case VpnConnectorErrorNone:
            break;
        case VpnConnectorErrorLoadPrefrence:
            break;
        case VpnConnectorErrorSavePrefrence:
            break;
        case VpnConnectorErrorRemovePrefrence:
            break;
        case VpnConnectorErrorStartVPNConnect:
            break;
        default:
            break;
    }
}

#pragma mark - Notification
- (void)vpnStatusDidChange:(VPNStatus)status {
    switch (status) {
        case VPNStatusInvalid:
            break;
        case VPNStatusConnected:
        {
            [self.connectButton stopPulse];
            self.connectButton.userInteractionEnabled = YES;
            [self.connectButton setTitle:@"Stop" forState:UIControlStateNormal];
        }
            break;
        case VPNStatusDisconnected:
        {
            [self.connectButton stopPulse];
            self.connectButton.userInteractionEnabled = YES;
            [self.connectButton setTitle:@"Connect" forState:UIControlStateNormal];
        }
            break;
        case VPNStatusConnecting:
            [self.connectButton setTitle:@"Connecting" forState:UIControlStateNormal];
            break;
        case VPNStatusDisconnecting:
            [self.connectButton setTitle:@"Stopping" forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

@end

@implementation PandaCell

@end

@implementation PandaGrayCell

@end
