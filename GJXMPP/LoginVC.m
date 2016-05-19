//
//  ViewController.m
//  GJXMPP
//
//  Created by 郭佳 on 16/5/13.
//  Copyright © 2016年 郭佳. All rights reserved.
//

#import "LoginVC.h"
#import "XMPPManager.h"
#import <XMPPReconnect.h>

@interface LoginVC ()<XMPPStreamDelegate,XMPPManagerDelegate>

@property (nonatomic,strong) XMPPStream *xmppStream;

@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [XMPPManager share].delegate = self;
}
- (IBAction)tapLogin:(UIButton *)sender {
    [[XMPPManager share] loginWithUserName:@"mayan" password:@"mayan"];
}


// 实现协议
-(void) loginResult:(BOOL)flg
{
    if (flg) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"MainVC"];
        [self presentViewController:vc animated:YES completion:^{
        }];
    }else{
        NSLog(@"login fail");
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
