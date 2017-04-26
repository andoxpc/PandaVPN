//
//  VPNInfo.m
//  PandaVPN
//
//  Created by mac on 2017/4/12.
//  Copyright © 2017年 Andox. All rights reserved.
//

#import "VPNInfo.h"

@implementation VPNInfo

+ (instancetype)infoWithData:(id)data {
    
    VPNInfo *vpnInfo = [[VPNInfo alloc] init];
    if ([data isKindOfClass:[NSDictionary class]]) {
        data[@"serverAddress"] ? vpnInfo.serverAddress = data[@"serverAddress"] : 0;
        data[@"remoteID"] ? vpnInfo.remoteID = data[@"remoteID"] : 0;
        data[@"username"] ? vpnInfo.username = data[@"username"] : 0;
        data[@"password"] ? vpnInfo.password = data[@"password"] : 0;
        data[@"sharedSecret"] ? vpnInfo.sharedSecret = data[@"sharedSecret"] : 0;
        data[@"preferenceTitle"] ? vpnInfo.preferenceTitle = data[@"preferenceTitle"] : 0;
    } else if ([data isKindOfClass:[self class]]) {
        vpnInfo = data;
    }
    return vpnInfo;
}

@end
