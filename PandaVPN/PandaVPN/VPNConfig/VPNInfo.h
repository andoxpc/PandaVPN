//
//  VPNInfo.h
//  PandaVPN
//
//  Created by mac on 2017/4/12.
//  Copyright © 2017年 Andox. All rights reserved.
//

#import <Foundation/Foundation.h>

///vpn 配置信息

@interface VPNInfo : NSObject

@property (nonatomic, strong) NSString *serverAddress;      ///< 服务器地址
@property (nonatomic, strong) NSString *remoteID;           ///< 远程 ID
@property (nonatomic, strong) NSString *username;           ///< 用户名
@property (nonatomic, strong) NSString *password;           ///< 密码
@property (nonatomic, strong) NSString *sharedSecret;       ///< 共享密码
@property (nonatomic, strong) NSString *preferenceTitle;    ///< vpn 配置标题

+ (instancetype)infoWithData:(id)data;

@end
