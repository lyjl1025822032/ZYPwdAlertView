//
//  AppDelegate.h
//  ZYPwdAlertView
//
//  Created by yao on 2017/6/10.
//  Copyright © 2017年 yao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

