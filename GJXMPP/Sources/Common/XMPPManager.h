//
//  XMPPManager.h
//  GJXMPP
//
//  Created by 郭佳 on 16/5/14.
//  Copyright © 2016年 郭佳. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XMPPRoster.h>
#import <XMPPReconnect.h>
#import <XMPPMessageArchiving.h>
#import <XMPPRosterCoreDataStorage.h>

@protocol XMPPManagerDelegate
- (void)loginResult:(BOOL)flg;
@end

@interface XMPPManager : NSObject<XMPPStreamDelegate>

//流
@property (nonatomic, strong) XMPPStream             *xmppStream;
//好友花名册
@property (nonatomic, strong) XMPPRoster             *xmppRoster;
//获取上线文
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
//获取聊天消息内容
@property (nonatomic, strong) XMPPMessageArchiving   *messageArchiving;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) NSManagedObjectContext     *xmppRosterManagedObjectContext;

@property (nonatomic, strong) XMPPRosterCoreDataStorage  *xmppRosterStorage;

@property (nonatomic, weak  ) id<XMPPManagerDelegate>    delegate;

+(instancetype)share;  

//登录方法
- (void)loginWithUserName:(NSString *)userName
                 password:(NSString *)password;
//注册方法
- (void)registerWithUserName:(NSString *)userName password:(NSString *)password;
//添加好友
- (void)xmppAddFriend:(NSString *)name;
//删除好友
- (void)xmppDeleteFriend:(NSString *)name;
//断开服务器
- (void)disConnectToServer;


@end
