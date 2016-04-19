//
//  LoginViewController.m
//  Phonon
//
//  Created by Carl Pan on 3/7/16.
//  Copyright © 2016 Carl Pan. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "PhotoViewController.h"
#import <SimpleAuth/SimpleAuth.h>

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Set view background color
    self.view.backgroundColor = [UIColor colorWithRed:0.61 green:0.17 blue:0.88 alpha:1.0];
    
    // Addig login button
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    loginButton.layer.cornerRadius = 5;
    loginButton.backgroundColor = [UIColor whiteColor];
    loginButton.frame = CGRectMake(0, 0, 320, 40);
    loginButton.center = self.view.center;
    [loginButton setTitle:@"Login with Instagram" forState:UIControlStateNormal];
    [loginButton setTitleColor:[UIColor colorWithRed:0.61 green:0.17 blue:0.88 alpha:1.0] forState:UIControlStateNormal];
    
    // Adding action on button
    [loginButton addTarget:self action:@selector(loginPressed) forControlEvents:UIControlEventTouchUpInside];
    
    // Add button to the view
    [self.view addSubview:loginButton];
    
    // Status bar text color
    [self setNeedsStatusBarAppearanceUpdate];
    
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)loginPressed {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [SimpleAuth authorize:@"instagram" options:@{@"scope": @[@"public_content", @"follower_list"]} completion:^(NSDictionary *responseObject, NSError *error) {
        
        // Get access token
        NSString *accessToken = responseObject[@"credentials"][@"token"];
        
        [userDefaults setObject:accessToken forKey:@"accessToken"];
        [userDefaults synchronize];
        
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        PhotoViewController *photoViewController = [[PhotoViewController alloc] init];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:photoViewController];
        appDelegate.window.rootViewController = navController;
        
        // Set Navigation bar style
        navController.navigationBar.barTintColor = [UIColor colorWithRed:0.61 green:0.17 blue:0.88 alpha:1.0];
        navController.navigationBar.barStyle = UIBarStyleBlackOpaque;
        
        appDelegate.window.backgroundColor = [UIColor whiteColor];
        [appDelegate.window makeKeyAndVisible];
    }];
}

@end
