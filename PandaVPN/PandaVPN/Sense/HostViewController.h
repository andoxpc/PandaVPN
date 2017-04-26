//
//  HostViewController.h
//  PandaVPN
//
//  Created by mac on 2017/4/12.
//  Copyright © 2017年 Andox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HostViewController : UIViewController

@end

@interface HostCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *hostName;
@property (weak, nonatomic) IBOutlet UIImageView *selectedView;

@end
