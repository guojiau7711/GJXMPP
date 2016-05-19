//
//  FriendsVC.m
//  GJXMPP
//
//  Created by 郭佳 on 16/5/15.
//  Copyright © 2016年 郭佳. All rights reserved.
//

#import "FriendsVC.h"
#import <XMPPUserCoreDataStorageObject.h>
#import <XMPPRoster.h>
#import <XMPPRosterCoreDataStorage.h>
#import "ChatVC.h"

@interface FriendsVC ()<XMPPStreamDelegate,NSFetchedResultsControllerDelegate>
//从数据库中获取发送内容的xmppManagedObjectContext
@property(nonatomic,strong)NSManagedObjectContext *xmppRosterManagedObjectContext;
//显示在tableView上
@property(nonatomic,strong)NSFetchedResultsController *fetchedResultsController;

@property(nonatomic,strong)NSMutableArray *rosters;

@property(strong,nonatomic) XMPPRosterCoreDataStorage * rosterStorage;//花名册存储
@property(strong,nonatomic) XMPPRoster * rosterModule;//花名册模块
//@property(strong,nonatomic) XMPPMessageArchivingCoreDataStorage *msgStorage;//消息存储
@property(strong,nonatomic) XMPPMessageArchiving * msgModule;//消息模块
@property(strong,nonatomic) NSFetchedResultsController *fetFriend;//查询好友的Fetch
@property(strong,nonatomic) NSFetchedResultsController *fetMsgRecord;//查询消息的Fetch
@end

@implementation FriendsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.xmppRosterManagedObjectContext = [XMPPManager share].xmppRosterManagedObjectContext;;
    
    //从CoreData中获取数据
    //通过实体获取FetchRequest实体
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([XMPPUserCoreDataStorageObject class])];
    
//    NSString *jid = @"mayan";
//    NSPredicate *pre = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@",jid];
//    request.predicate = pre;
    
    //添加排序规则
    NSSortDescriptor * sortD = [NSSortDescriptor sortDescriptorWithKey:@"jidStr" ascending:YES];
    [request setSortDescriptors:@[sortD]];
    
    //获取FRC
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.xmppRosterManagedObjectContext sectionNameKeyPath:nil cacheName:nil];
    self.fetchedResultsController.delegate = self;
    
    //获取内容
    
    
    NSError * error;
    if (![self.fetchedResultsController performFetch:&error])
    {
        NSLog(@"%s  %@",__FUNCTION__,[error localizedDescription]);
    }
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSArray *sections = [self.fetchedResultsController sections];
    NSLog(@"section.count:%ld", sections.count);
    return sections.count;}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sectoins = [self.fetchedResultsController sections];
    id<NSFetchedResultsSectionInfo> sectionInfo = sectoins[section];
    
    NSLog(@"%ld", [sectionInfo numberOfObjects]);
    return [sectionInfo numberOfObjects];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    //获取数据
    XMPPUserCoreDataStorageObject *roster = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"123" forIndexPath:indexPath];
    UITableViewCell *cell = [[UITableViewCell alloc]init];

    cell.textLabel.text = roster.nickname;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XMPPUserCoreDataStorageObject *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    ChatVC *nextVC = [[ChatVC alloc]init];
    
    [nextVC setValue:user.nickname forKey:@"sendUserName"];
    [nextVC setValue:user.jidStr forKey:@"jidStr"];
    
    [self.navigationController pushViewController:nextVC animated:YES];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UITableViewCell *cell = (UITableViewCell *)sender;
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    XMPPUserCoreDataStorageObject *user = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    UIViewController *nextVC = [segue destinationViewController];
    
    [nextVC setValue:user.nickname forKey:@"sendUserName"];
    [nextVC setValue:user.jidStr forKey:@"jidStr"];
    
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
            case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            default:
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
            case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
            case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
            case NSFetchedResultsChangeUpdate:
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
            case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

@end
