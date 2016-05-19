//
//  XMPPManager.m
//  GJXMPP
//
//  Created by 郭佳 on 16/5/14.
//  Copyright © 2016年 郭佳. All rights reserved.
//

#import "XMPPManager.h"
#import <Foundation/Foundation.h>
#import <XMPPRoster.h>
#import <XMPPRosterCoreDataStorage.h>
#import <XMPPReconnect.h>
#import <XMPPMessageArchivingCoreDataStorage.h>

//链接状态的属性枚举
typedef NS_ENUM(NSInteger, connenctToServerState) {
    connenctToServerStateLogin,
    connenctToServerStateRegister
    
};


@interface XMPPManager()

@property(nonatomic, strong)NSString *password;
//声明一个链接状态的属性
@property(nonatomic, assign)connenctToServerState connentToServerState;


@end

@implementation XMPPManager


+(instancetype)share{
    static XMPPManager *xmppMananger;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        xmppMananger = [[XMPPManager alloc] init];
    });
    return xmppMananger;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        //初始化通道
        self.xmppStream = [[XMPPStream alloc]init];
        //通信指定IP
        self.xmppStream.hostName = HOST;
        //给通信管道指定端口
//        self.xmppStream.hostPort = kHostPort;
        //添加代理
        [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        //初始化花名册
//        XMPPRosterCoreDataStorage *rosterCoreDataStorage = [XMPPRosterCoreDataStorage sharedInstance];
        XMPPRosterCoreDataStorage *rosterCoreDataStorage = [[XMPPRosterCoreDataStorage alloc]init];
        self.xmppRoster = [[XMPPRoster alloc]initWithRosterStorage:rosterCoreDataStorage];
        //添加代理
        [self.xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
        //通过管道激活花名册
        [self.xmppRoster activate:self.xmppStream];
        //添加好友
        [self.xmppRoster setAutoAcceptKnownPresenceSubscriptionRequests:YES];
        [self.xmppRoster setAutoFetchRoster:YES];
        self.xmppRosterManagedObjectContext = rosterCoreDataStorage.mainThreadManagedObjectContext;

        
        //初始化聊天对象
        XMPPMessageArchivingCoreDataStorage *messageArchivingCoreDataStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance] ;
        
        self.messageArchiving = [[XMPPMessageArchiving  alloc]initWithMessageArchivingStorage:messageArchivingCoreDataStorage dispatchQueue:dispatch_get_main_queue()];
        
        //获取聊天上下文
        self.managedObjectContext = messageArchivingCoreDataStorage.mainThreadManagedObjectContext;
        [self.messageArchiving activate:self.xmppStream];
        
    }
    
    return self;
}

//已经断开链接
-(void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    NSLog(@"已经断开链接%s__%d__| Error = %@", __FUNCTION__, __LINE__, error);
}

//登录失败
-(void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error
{
    [self.delegate loginResult:NO];
    NSLog(@"登录失败%s__%d__| Error = %@", __FUNCTION__, __LINE__, error);
}

//注册失败
-(void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error
{
    NSLog(@"注册失败%s__%d__| Error = %@", __FUNCTION__, __LINE__, error);
}

//注册
-(void)registerWithUserName:(NSString *)userName password:(NSString *)password
{
    self.password = password;
    self.connentToServerState = connenctToServerStateRegister;
    //创建账号链接服务器
    [self creatJidToConnectWithUserName:userName];
}

//登录
-(void)loginWithUserName:(NSString *)userName
                password:(NSString *)password
{
    self.password = password;
    self.connentToServerState = connenctToServerStateLogin;
    [self creatJidToConnectWithUserName:userName];
}

//创建jid并连接服务器
-(void) creatJidToConnectWithUserName:(NSString *)userName
{
    XMPPJID *jid = [XMPPJID jidWithUser:userName domain:HOST resource:RESOURCE];
    [self.xmppStream setMyJID:jid];
    
    [self connectToServer];
}

//连接服务器
-(void) connectToServer
{
    if([self.xmppStream isConnected])
    {
        [self.xmppStream disconnect];
    }
    NSError *error = nil;
    [self.xmppStream connectWithTimeout:10 error:&error];
    if (error) {
        NSLog(@"连接失败:%@",[error localizedDescription]);
    }
}

//断开服务器
- (void)disConnectToServer
{
    //离线
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [self.xmppStream sendElement:presence];
    [self.xmppStream disconnect];
    
}

//连接成功后回调
-(void)xmppStreamDidConnect:(XMPPStream *)sender
{
    switch (self.connentToServerState) {
            case connenctToServerStateLogin: {
                [sender authenticateWithPassword:self.password error:nil];
                break;
            }
            case connenctToServerStateRegister: {
                [sender registerWithPassword:self.password error:nil];
                break;
            }
            default:
                break;
    }
}

//登陆后改变状态
-(void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    //在线
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
    [sender sendElement:presence];
    
    [self.delegate loginResult:YES];
}

-(void)xmppAddFriend:(NSString *)name
{
    //创建用户jid
    XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",name,HOST]];
    
    //添加好友xmppRoster语法
    [self.xmppRoster subscribePresenceToUser:jid];
}

-(void)xmppDeleteFriend:(NSString *)name
{
    //创建用户jid
    XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",name,HOST]];
    
    //添加好友xmppRoster语法
    [self.xmppRoster removeUser:jid];
}

-(NSArray *) getFriends
{
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([XMPPUserCoreDataStorageObject class])];
    //添加排序规则
    NSSortDescriptor * sortD = [NSSortDescriptor sortDescriptorWithKey:@"jidStr" ascending:YES];
    [request setSortDescriptors:@[sortD]];

    return nil;
}




@end
