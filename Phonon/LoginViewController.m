//
//  LoginViewController.m
//  Phonon
//
//  Created by Carl Pan on 3/7/16.
//  Copyright © 2016 Carl Pan. All rights reserved.
//

#import "LoginViewController.h"
#import <SimpleAuth/SimpleAuth.h>

@interface LoginViewController ()

@property (strong, nonatomic) NSUserDefaults *userDefaults;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSLog(@"login view");
    // Addig login button
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    loginButton.backgroundColor = [UIColor yellowColor];
    loginButton.frame = CGRectMake(0, 0, 320, 40);
    loginButton.center = self.view.center;
    [loginButton setTitle:@"Login with Instagram" forState:UIControlStateNormal];
    
    // Adding action on button
    [loginButton addTarget:self action:@selector(loginPressed) forControlEvents:UIControlEventTouchUpInside];
    
    // Add button to the view
    [self.view addSubview:loginButton];
    
    self.userDefaults = [NSUserDefaults standardUserDefaults];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setHidden:YES];
    //if ([self.userDefaults objectForKey:@"accessToken"] != nil) {
    //[self.navigationController popToRootViewControllerAnimated:YES];
    //}
    //[self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)loginPressed {
    [SimpleAuth authorize:@"instagram" options:@{@"scope": @[@"public_content", @"follower_list"]} completion:^(NSDictionary *responseObject, NSError *error) {
        
        // Get access token
        NSString *accessToken = responseObject[@"credentials"][@"token"];
        
        [self.userDefaults setObject:accessToken forKey:@"accessToken"];
        [self.userDefaults synchronize];
    }];
}


@end
