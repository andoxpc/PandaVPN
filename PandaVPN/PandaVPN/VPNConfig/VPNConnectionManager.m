//
//  VPNConnectionManager.m
//  PandaVPN
//
//  Created by mac on 2017/4/12.
//  Copyright © 2017年 Andox. All rights reserved.
//

#import "VPNConnectionManager.h"
#import <NetworkExtension/NetworkExtension.h>

@interface VPNConnectionManager ()

@property (nonatomic, strong) NEVPNManager *vpnManager;

@end

@implementation VPNConnectionManager

+ (instancetype)VPNConnection {
    
    VPNConnectionManager *manager = [[VPNConnectionManager alloc] init];
    manager.vpnManager = [NEVPNManager sharedManager];
    // 监听 VPN 连接状态
    [[NSNotificationCenter defaultCenter] addObserver:manager
                                             selector:@selector(vpnStatusDidChanged:)
                                                 name:NEVPNStatusDidChangeNotification
                                               object:nil];
    return manager;
}


#pragma mark - 检查，创建和删除 VPN 配置

- (void)checkVPNPreferenceSuccess:(void (^)(BOOL isInstalled))successBlock {
    
    [_vpnManager loadFromPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            //加载 VPN 偏好设置失败
            if ([self.delegate respondsToSelector:@selector(vpnConnectionDidRecieveError:)]) {
                [self.delegate vpnConnectionDidRecieveError:VpnConnectorErrorLoadPrefrence];
            }
        } else {
            if ([[NSString stringWithFormat:@"%@", _vpnManager.protocolConfiguration] rangeOfString:@"persistentReference"].location != NSNotFound) {
                successBlock ? successBlock(YES) : 0;
            } else {
                // 不存在
                successBlock ? successBlock(NO) : 0;
            }
        }
    }];
}

- (void)createVPNPreferenceWithData:(id)data success:(void (^)())successBlock {
    
    VPNInfo *vpnInfo = [VPNInfo infoWithData:data];
    [_vpnManager loadFromPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            //加载 VPN 偏好设置失败
            if ([self.delegate respondsToSelector:@selector(vpnConnectionDidRecieveError:)]) {
                [self.delegate vpnConnectionDidRecieveError:VpnConnectorErrorLoadPrefrence];
            }
        } else {
            NEVPNProtocolIKEv2 *protocol = [[NEVPNProtocolIKEv2 alloc] init];
            protocol.serverAddress = vpnInfo.serverAddress;
            protocol.remoteIdentifier = vpnInfo.remoteID;
            protocol.username = vpnInfo.username;
            
            // 设置密码
            static NSString *passwordKey = @"k_VPN_Password";
            [self setKeychainWithString:vpnInfo.password forIdentifier:passwordKey];
            protocol.passwordReference = [self getDataReferenceInKeychainFromIdentifier:passwordKey];
            
            // 如果你的 VPN 服务器是使用密码和共享密码进行双向认证，则使用以下代码
            // 共享密码
            static NSString *sharedSecretKey = @"k_VPN_sharedSecret";
            [self setKeychainWithString:vpnInfo.sharedSecret forIdentifier:sharedSecretKey];
            protocol.sharedSecretReference = [self getDataReferenceInKeychainFromIdentifier:sharedSecretKey];
            
            // 其他配置
            protocol.authenticationMethod = NEVPNIKEAuthenticationMethodNone;
            
            /*
             // 如果你的 VPN 服务器是只需要用户名，然后使用 CA 证书进行认证，则使用以下代码
             // 设置认证方式为使用证书
             protocol.authenticationMethod = NEVPNIKEAuthenticationMethodCertificate;
             // 安装证书代码自己在合适的地方编写，一般使用 Safari 进行安装
             // [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"xxxx.ca.cert.pem"]];
             */
            
            protocol.useExtendedAuthentication = YES;
            protocol.disconnectOnSleep = NO;
            
            _vpnManager.protocolConfiguration = protocol;
            _vpnManager.onDemandEnabled = YES;
            _vpnManager.localizedDescription = vpnInfo.preferenceTitle;
            _vpnManager.enabled = YES;
            
            [_vpnManager saveToPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
                if (error) {
                    //保存 VPN 偏好设置失败
                    if ([self.delegate respondsToSelector:@selector(vpnConnectionDidRecieveError:)]) {
                        [self.delegate vpnConnectionDidRecieveError:VpnConnectorErrorSavePrefrence];
                    }
                } else {
                    [self checkVPNPreferenceSuccess:^(BOOL isInstalled) {
                        if (isInstalled) {
                            successBlock ? successBlock() : 0;
                        }
                    }];
                }
            }];
        }
    }];
}

- (void)removeVPNPreferenceSuccess:(void (^)())successBlock {
    
    [_vpnManager loadFromPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            //加载 VPN 偏好设置失败
            if ([self.delegate respondsToSelector:@selector(vpnConnectionDidRecieveError:)]) {
                [self.delegate vpnConnectionDidRecieveError:VpnConnectorErrorLoadPrefrence];
            }
        } else {
            [_vpnManager removeFromPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
                if (error) {
                    //删除 VPN 偏好设置失败
                    if ([self.delegate respondsToSelector:@selector(vpnConnectionDidRecieveError:)]) {
                        [self.delegate vpnConnectionDidRecieveError:VpnConnectorErrorRemovePrefrence];
                    }
                } else {
                    _vpnManager.protocolConfiguration = nil;
                    successBlock ? successBlock() : 0;
                }
            }];
        }
    }];
}

- (void)modifyVPNPreferenceWithData:(id)data success:(void (^)())successBlock {
    
    [self createVPNPreferenceWithData:data success:^{
        successBlock ? successBlock() : 0;
    }];
}


#pragma mark - 开始和断开连接

- (void)startVPNConnectSuccess:(void (^)())successBlock {
    
    [_vpnManager loadFromPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            //加载 VPN 偏好设置失败
            if ([self.delegate respondsToSelector:@selector(vpnConnectionDidRecieveError:)]) {
                [self.delegate vpnConnectionDidRecieveError:VpnConnectorErrorLoadPrefrence];
            }
        } else {
            NSError *returnError;
            [_vpnManager.connection startVPNTunnelAndReturnError:&returnError];
            if (returnError) {
                //启动 VPN 失败
                if ([self.delegate respondsToSelector:@selector(vpnConnectionDidRecieveError:)]) {
                    [self.delegate vpnConnectionDidRecieveError:VpnConnectorErrorStartVPNConnect];
                }
            } else {
                successBlock ? successBlock() : 0;
            }
        }
    }];
}

- (void)stopVPNConnectSuccess:(void (^)())successBlock {
    
    [_vpnManager loadFromPreferencesWithCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            //加载 VPN 偏好设置失败
            if ([self.delegate respondsToSelector:@selector(vpnConnectionDidRecieveError:)]) {
                [self.delegate vpnConnectionDidRecieveError:VpnConnectorErrorLoadPrefrence];
            }
        } else {
            [_vpnManager.connection stopVPNTunnel];
            successBlock ? successBlock() : 0;
        }
    }];
}


#pragma mark - 获取当前 VPN 信息

- (VPNInfo *)getCurrentVPNInfo {
    
    VPNInfo *vpnInfo = [[VPNInfo alloc] init];
    NEVPNProtocolIKEv2 *protocol = (NEVPNProtocolIKEv2 *)_vpnManager.protocolConfiguration;
    vpnInfo.serverAddress = protocol.serverAddress;
    vpnInfo.remoteID = protocol.remoteIdentifier;
    vpnInfo.username = protocol.username;
    return vpnInfo;
}

- (VPNStatus)getCurrentStatus {
    
    NEVPNStatus status = _vpnManager.connection.status;
    switch (status) {
        case NEVPNStatusInvalid:
            return VPNStatusInvalid;
            break;
        case NEVPNStatusDisconnected:
            return VPNStatusDisconnected;
            break;
        case NEVPNStatusConnecting:
            return VPNStatusConnecting;
            break;
        case NEVPNStatusConnected:
            return VPNStatusConnected;
            break;
        case NEVPNStatusDisconnecting:
            return VPNStatusDisconnecting;
            break;
        default:
            return VPNStatusInvalid;
            break;
    }
}

#pragma mark - Notification

- (void)vpnStatusDidChanged:(NSNotification *)notification {
    
    if ([self.delegate respondsToSelector:@selector(vpnStatusDidChange:)]) {
        [self.delegate vpnStatusDidChange:[self getCurrentStatus]];
    }
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Keychain

#define kKeychainServiceID @"com.Andox.PandaVPN.keychain.library"

- (NSMutableDictionary *)buildDefaultDictionaryForIdentity:(NSString*)identifier {
    
    NSMutableDictionary *searchDictionary = [[NSMutableDictionary alloc] init];
    NSData *encodedIdentifier = [identifier dataUsingEncoding:NSUTF8StringEncoding];
    searchDictionary[(__bridge id)kSecClass] = (__bridge id)kSecClassGenericPassword;
    searchDictionary[(__bridge id)kSecAttrGeneric] = encodedIdentifier;
    searchDictionary[(__bridge id)kSecAttrAccount] = encodedIdentifier;
    searchDictionary[(__bridge id)kSecAttrService] = kKeychainServiceID;
    
    return searchDictionary;
}

// 根据 identifier 获取钥匙串中的数据
- (NSData *)getDataInKeychainFromIdentifier:(NSString *)identifier returnReference:(BOOL)referenceOnly {
    
    // get default dictionary
    NSMutableDictionary *dict = [self buildDefaultDictionaryForIdentity:identifier];
    
    // set for searching
    dict[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;
    
    // need reference
    if (referenceOnly) {
        dict[(__bridge id)kSecReturnPersistentRef] = @YES;
    } else {
        dict[(__bridge id)kSecReturnData] = @YES;
    }
    
    // create result object
    CFTypeRef result = NULL;
    
    // Get result
    SecItemCopyMatching((__bridge CFDictionaryRef)dict, &result);
    
    // return result
    return (__bridge_transfer NSData *)result;
}

// 根据 identifier 获取钥匙串中的字符串数据
- (NSString*)getStringInKeychainFromIdentifier:(NSString*)identifier {
    
    NSData *keychainData = [self getDataInKeychainFromIdentifier:identifier returnReference:NO];
    return [[NSString alloc] initWithData:keychainData encoding:NSUTF8StringEncoding];
}

// 根据 identifier 获取钥匙串中的二进制数据
- (NSData *)getDataReferenceInKeychainFromIdentifier:(NSString *)identifier {
    
    return [self getDataInKeychainFromIdentifier:identifier returnReference:YES];
}

/// 设置钥匙串中的数据
- (BOOL)setKeychainWithString:(NSString*)string forIdentifier:(NSString*)identifier {
    
    NSMutableDictionary *searchDictionary = [self buildDefaultDictionaryForIdentity:identifier];
    NSData *keychainValue = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    if ([self getDataReferenceInKeychainFromIdentifier:identifier] == nil) {
        [searchDictionary setObject:keychainValue forKey:(__bridge id)kSecValueData];
        OSStatus status = SecItemAdd((__bridge CFDictionaryRef)searchDictionary, NULL);
        if (status == errSecSuccess) {
            return YES;
        } else {
            return NO;
        }
    } else {
        NSMutableDictionary *updateDictionary = [[NSMutableDictionary alloc] init];
        [updateDictionary setObject:keychainValue forKey:(__bridge id)kSecValueData];
        OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)searchDictionary, (__bridge CFDictionaryRef)updateDictionary);
        if (status == errSecSuccess) {
            return YES;
        } else {
            return NO;
        }
    }
}

@end
