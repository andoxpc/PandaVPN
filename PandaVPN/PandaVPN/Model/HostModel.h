//
//  HostModel.h
//  PandaVPN
//
//  Created by mac on 2017/4/14.
//  Copyright © 2017年 Andox. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface HostModel : JSONModel

@property (strong, nonatomic) NSString *country;
@property (strong, nonatomic) NSString *city;


@end
