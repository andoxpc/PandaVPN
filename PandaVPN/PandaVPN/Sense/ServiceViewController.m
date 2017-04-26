//
//  ServiceViewController.m
//  PandaVPN
//
//  Created by mac on 2017/4/12.
//  Copyright © 2017年 Andox. All rights reserved.
//

#import "ServiceViewController.h"

@interface ServiceViewController ()

@property (strong, nonatomic) UIWebView *webView;

@end

@implementation ServiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.serviceButton.layer.cornerRadius = 16;
    self.webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.webView];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"mqq://"]]) {
        self.serviceButton.hidden = NO;
    }
    else {
        self.serviceButton.hidden = YES;
    }
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)popViewController:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)consult:(id)sender {
    NSURL *url = [NSURL URLWithString:@"mqq://im/chat?chat_type=wpa&uin=184910639&version=1&src_type=web"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
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
