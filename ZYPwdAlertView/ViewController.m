//
//  ViewController.m
//  ZYPwdAlertView
//
//  Created by yao on 2017/6/10.
//  Copyright © 2017年 yao. All rights reserved.
//

#import "ViewController.h"
#import "ZYPwdAlert.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIButton *showBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    showBtn.frame = CGRectMake(0, 0, 100, 40);
    [showBtn setTitle:@"show" forState:UIControlStateNormal];
    [showBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [showBtn setBackgroundColor:[UIColor blackColor]];
    [showBtn addTarget:self action:@selector(showAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:showBtn];
    showBtn.center = self.view.center;
}

- (void)showAction:(id)sender {
    ZYPwdAlert *pwdAlert = [[ZYPwdAlert alloc] init];
    pwdAlert.title = @"直播加密";
    pwdAlert.completeAction = ^(NSString *pwd){
        NSLog(@"pwd:%@", pwd);
    };
    [pwdAlert showView:self.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
