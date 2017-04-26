//
//  VPNConnectionManager.h
//  PandaVPN
//
//  Created by mac on 2017/4/12.
//  Copyright © 2017年 Andox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VPNInfo.h"

typedef NS_ENUM(NSInteger, VPNStatus) {
    VPNStatusInvalid,                     // VPN 不可用
    VPNStatusDisconnected,                // VPN 未连接
    VPNStatusConnecting,                  // VPN 连接中
    VPNStatusConnected,                   // VPN 已连接上
    VPNStatusDisconnecting,               // VPN 断开连接中
};

typedef NS_ENUM(NSUInteger, VpnConnectorError) {
    VpnConnectorErrorNone,                // None
    VpnConnectorErrorLoadPrefrence,       // 加载偏好设置失败
    VpnConnectorErrorSavePrefrence,       // 保存偏好设置失败
    VpnConnectorErrorRemovePrefrence,     // 移除偏好设置失败
    VpnConnectorErrorStartVPNConnect      // 启动 VPN 失败
};

@protocol VPNConnectionDelegate <NSObject>

// VPN 连接发生错误
- (void)vpnConnectionDidRecieveError:(VpnConnectorError)error;
// VPN 状态发生改变
- (void)vpnStatusDidChange:(VPNStatus)status;

@end


@interface VPNConnectionManager : NSObject

/// 代理
@property (nonatomic, weak) id<VPNConnectionDelegate> delegate;

/// 实例化
+ (instancetype)VPNConnection;


#pragma mark - 检查，创建和删除 VPN 配置

- (void)checkVPNPreferenceSuccess:(void (^)(BOOL isInstalled))successBlock;                             ///< 检查 VPN 配置是否存在
- (void)createVPNPreferenceWithData:(id)data success:(void (^)())successBlock;                          ///< 根据传入的 VPN 配置信息，创建 VPN 配置
- (void)removeVPNPreferenceSuccess:(void (^)())successBlock;                                            ///< 删除 VPN 配置
- (void)modifyVPNPreferenceWithData:(id)data success:(void (^)())successBlock;                          ///< 修改 VPN 配置


#pragma mark - 开始和断开连接

- (void)startVPNConnectSuccess:(void (^)())successBlock;    ///< 开始连接
- (void)stopVPNConnectSuccess:(void (^)())successBlock;     ///< 断开连接


#pragma mark - 获取当前 VPN 信息

- (VPNInfo *)getCurrentVPNInfo;                           ///< 获取当前 VPN 配置信息，返回数据不包含密码
- (VPNStatus)getCurrentStatus;                            ///< 获取当前 VPN 状态信息

@end
