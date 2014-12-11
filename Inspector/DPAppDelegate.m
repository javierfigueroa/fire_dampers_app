//
//  DPAppDelegate.m
//  Inspector
//
//  Created by Eddy Borja on 3/31/12.
//  Copyright (c) 2012 Badderjoy, LLC. All rights reserved.
//

#import "DPAppDelegate.h"
#import "DPApiClient.h"
#import "DPMasterViewController.h"
#import "DPLoginViewController.h"
#import "DPReachability.h"

@implementation DPAppDelegate

@synthesize window = _window;
@synthesize loginViewController = _loginViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [DPReachability sharedClient];
    
    // Override point for customization after application launch
    if (IPAD) {
        // iPad
        DPLoginViewController *loginViewController = [[DPLoginViewController alloc] initWithNibName:@"DPLoginViewController" bundle:nil];
        [self setLoginViewController:loginViewController];
    } else {
        // iPhone / iPod Touch
        DPLoginViewController *loginViewController = [[DPLoginViewController alloc] initWithNibName:@"DPLoginViewController_iPhone" bundle:nil];
        [self setLoginViewController:loginViewController];
    }
    
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"Inspector"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dismissLoginScreen) name:kUserDidLoginNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showLoginScreen) name:kUserDidLogoutNotification object:nil];
    
    return YES;
}

-(void)dismissLoginScreen{
    [self.loginViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)showLoginScreen{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"password"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.window.rootViewController presentViewController:self.loginViewController animated:YES completion:nil];
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [MagicalRecord cleanUp];
}

@end
