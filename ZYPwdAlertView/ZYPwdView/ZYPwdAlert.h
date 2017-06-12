//
//  ZYPwdAlert.h
//  ZYPwdAlertView
//
//  Created by yao on 2017/6/10.
//  Copyright © 2017年 yao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZYPwdInputView : UIView
/**
 密码可见标识
 */
@property (assign, nonatomic) BOOL visibleFlage;
/**
 支付密码长度
 */
@property (assign, nonatomic) NSUInteger length;
/**
 输入完成回调
 */
@property (copy, nonatomic) void (^inputDidCompletion)(NSString *pwd);
@end




@interface ZYPwdAlert : UIView
/**
 标题
 */
@property (copy, nonatomic) NSString *title;
/**
 密码长度
 */
@property (assign, nonatomic) NSUInteger length;
/**
 回调 Block
 */
@property (copy, nonatomic) void (^completeAction)(NSString *text);
/**
 输入完成回调
 */
- (void)showView:(UIView *)fatherView;
@end
