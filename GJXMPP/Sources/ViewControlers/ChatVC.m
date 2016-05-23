//
//  ChatVC.m
//  GJXMPP
//
//  Created by 郭佳 on 16/5/19.
//  Copyright © 2016年 郭佳. All rights reserved.
//

#import "ChatVC.h"

@interface ChatVC ()<UITextViewDelegate,XMPPStreamDelegate,NSFetchedResultsControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *inputView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (strong, nonatomic) IBOutlet UIView *myView;

@end

@implementation ChatVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 监听键盘变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChanged:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    [[XMPPManager share].xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChanged) name:UIKeyboardDidChangeFrameNotification object:nil];
}

#pragma mark - ******************** 监听键盘弹出的方法
- (void)keyboardChanged:(NSNotification *)notification {
    // 先打印
    // UIKeyboardFrameEndUserInfoKey ＝》将要变化的大小
    CGRect keyboardRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    // 设置约束
//    self.inputView. = ([UIScreen mainScreen].bounds.size.height - keyboardRect.origin.y);
    
    [self.inputView setFrame:CGRectMake(0, SCREEN_HEIGHT-266-44, SCREEN_WIDTH, SCREEN_HEIGHT)];
    
    
    
    NSTimeInterval time = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    
    [UIView animateWithDuration:time animations:^{
        [self.view layoutIfNeeded];
    }];
    
}


-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        
        NSString *str = textView.text;
        
        [self sendMessage:str];
        
        [textView resignFirstResponder];
        return NO;
    }
    
    
    
    return YES;
}

#pragma mark - ******************** 发送消息方法
/** 发送信息 */
- (void)sendMessage:(NSString *)message
{
//    XMPPJID *jid =[XMPPJID  jidWithUser:self.sendUserName domain:HOST resource:@"iPhone"];
    
    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.jid];
    
    [msg addBody:message];
    
    [[XMPPManager share].xmppStream sendElement:msg];
}

/** 发送二进制文件 */
- (void)sendMessageWithData:(NSData *)data bodyName:(NSString *)name
{
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:[XMPPJID  jidWithUser:self.sendUserName domain:HOST resource:@"iPhone"]];
    
    [message addBody:name];
    
    // 转换成base64的编码
    NSString *base64str = [data base64EncodedStringWithOptions:0];
    
    // 设置节点内容
    XMPPElement *attachment = [XMPPElement elementWithName:@"attachment" stringValue:base64str];
    
    // 包含子节点
    [message addChild:attachment];
    
    // 发送消息
    [[XMPPManager share].xmppStream sendElement:message];
}


-(void) controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    
}

-(void) xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    self.textView.text = message.body;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
