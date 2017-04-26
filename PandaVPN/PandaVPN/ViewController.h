//
//  ViewController.h
//  PandaVPN
//
//  Created by mac on 2017/4/12.
//  Copyright © 2017年 Andox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VPNConnectionManager.h"

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *listView;

@end

@interface PandaConnectCell : UITableViewCell<VPNConnectionDelegate>

@property (weak, nonatomic) IBOutlet UIButton *connectButton;

/// VPN 连接工具
@property (nonatomic, strong) VPNConnectionManager *connectionManager;

/// VPN 连接信息
@property (nonatomic, strong) VPNInfo *vpnInfo;

@end

@interface PandaCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end

@interface PandaGrayCell : UITableViewCell

@end
