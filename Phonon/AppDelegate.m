//
//  AppDelegate.m
//  Phonon
//
//  Created by Carl Pan on 2/27/16.
//  Copyright © 2016 Carl Pan. All rights reserved.
//

#import "AppDelegate.h"
#import "PhotoViewController.h"
#import "LoginViewController.h"
#import <SimpleAuth/SimpleAuth.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [NSThread sleepForTimeInterval:1.5];
    
    [Fabric with:@[[Crashlytics class]]];
    
    
    // Simple Auth for Instagram
    SimpleAuth.configuration[@"instagram"] = @{
        @"client_id" : @"1ceeccc66bbe479abd39798f27ac3ab8",
        SimpleAuthRedirectURIKey : @"photocrawler://auth/instagram"
    };
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Check for user default access token
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *accessToken = [userDefaults objectForKey:@"accessToken"];
    
    if (accessToken == nil) {
        LoginViewController *loginViewController = [[LoginViewController alloc] init];
        self.window.rootViewController = loginViewController;
        self.window.backgroundColor = [UIColor whiteColor];
        [self.window makeKeyAndVisible];
    } else {
        // Make navigation controller to be initial
        PhotoViewController *photoViewController = [[PhotoViewController alloc] init];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:photoViewController];
        self.window.rootViewController = navController;
                
        // Set Navigation bar style
        navController.navigationBar.barTintColor = [UIColor colorWithRed:0.61 green:0.17 blue:0.88 alpha:1.0];
        navController.navigationBar.barStyle = UIBarStyleBlackOpaque;
        self.window.backgroundColor = [UIColor whiteColor];
        [self.window makeKeyAndVisible];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Private methods

- (void)customizeUserInterface {
    // Custom nav bar
    UIColor *navBarColor = [UIColor colorWithRed:0.61 green:0.17 blue:0.88 alpha:1.0]; // #9B2BE0
    [[UINavigationBar appearance] setBarTintColor:navBarColor];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlackOpaque];
}

@end
