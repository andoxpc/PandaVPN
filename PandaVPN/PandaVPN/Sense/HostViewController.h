//
//  HostViewController.h
//  PandaVPN
//
//  Created by mac on 2017/4/12.
//  Copyright © 2017年 Andox. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HostModel.h"

typedef void(^hostSelectBlock) (HostModel*);

@interface HostViewController : UIViewController

@property (strong, nonatomic) NSMutableArray *hostArray;
@property (nonatomic, copy) hostSelectBlock block;

@end

@interface HostCell : UITableViewCell

@property (strong, nonatomic) HostModel *item;

@property (weak, nonatomic) IBOutlet UILabel *hostName;
@property (weak, nonatomic) IBOutlet UIImageView *selectedView;

@end
