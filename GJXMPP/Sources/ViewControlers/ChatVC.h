//
//  ChatVC.h
//  GJXMPP
//
//  Created by 郭佳 on 16/5/19.
//  Copyright © 2016年 郭佳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatVC : UIViewController

@property(nonatomic, strong) NSString *sendUserName;
@property(nonatomic, strong) NSString *jidStr;
@property(nonatomic, strong) XMPPJID *jid;


@end
