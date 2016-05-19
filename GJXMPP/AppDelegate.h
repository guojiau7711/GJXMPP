//
//  AppDelegate.h
//  GJXMPP
//
//  Created by 郭佳 on 16/5/16.
//  Copyright © 2016年 郭佳. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <XMPPRosterCoreDataStorage.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

//流
@property (nonatomic, strong) XMPPStream             *xmppStream;
//好友花名册
@property (nonatomic, strong) XMPPRoster             *xmppRoster;
//获取上线文
//@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
//获取聊天消息内容
@property (nonatomic, strong) XMPPMessageArchiving   *messageArchiving;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, strong) NSManagedObjectContext     *xmppRosterManagedObjectContext;

@property (nonatomic, strong) XMPPRosterCoreDataStorage  *xmppRosterStorage;

@property (nonatomic, weak)   id<XMPPManagerDelegate> delegate;

@end

