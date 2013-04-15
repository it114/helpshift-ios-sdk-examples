//
//  HSDAppDelegate.m
//  UA Notification
//
//  Created by Suman Raj on 11/04/13.
//  Copyright (c) 2013 Helpshift, Inc.,. All rights reserved.
//

#import "HSDAppDelegate.h"
#import "HSDViewController.h"

#import "Helpshift.h"

#import "UAirship.h"
#import "UAPush.h"

@implementation HSDAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    //Helpshift::Initialize Helpshift by calling the installForAppID:domainName:apiKey: method inside application:didFinishLaunchingWithOptions: method [http://www.helpshift.com/docs/howto/ios/v2.x/#authentication]
    //[Helpshift installForAppID:@"<YOUR_APP_ID>"  domainName:@"<YOUR_COMPANY>.helpshift.com" apiKey:@"<YOUR_API_KEY>"];
    
    //Create Airship options dictionary and add the required UIApplication launchOptions
    NSMutableDictionary *takeOffOptions = [NSMutableDictionary dictionary];
    [takeOffOptions setValue:launchOptions forKey:UAirshipTakeOffOptionsLaunchOptionsKey];
    
    // Call takeOff (which creates the UAirship singleton), passing in the launch options so the
    // library can properly record when the app is launched from a push notification. This call is
    // required.
    //
    // Populate AirshipConfig.plist with your app's info from https://go.urbanairship.com
    [UAirship takeOff:takeOffOptions];
    
    // Set the icon badge to zero on startup (optional)
    [[UAPush shared] resetBadge];
    
    // Register for remote notfications with the UA Library. This call is required.
    [[UAPush shared] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                         UIRemoteNotificationTypeSound |
                                                         UIRemoteNotificationTypeAlert)];


    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[[HSDViewController alloc] initWithNibName:@"HSDViewController_iPhone" bundle:nil] autorelease];
    } else {
        self.viewController = [[[HSDViewController alloc] initWithNibName:@"HSDViewController_iPad" bundle:nil] autorelease];
    }
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

//Integrating Urban Airship for Helpshift Notifications [http://www.helpshift.com/docs/howto/ios/v2.x/#urban-airship]
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{

    //UA::register device token
    [[UAPush shared] registerDeviceToken:deviceToken];
    
    //Helpshift::register device token
    [[Helpshift sharedInstance] registerDeviceToken:deviceToken];

}

- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    //Helpshift::handle notification
    if ([[userInfo objectForKey:@"origin"] isEqualToString:@"helpshift"]) {
        [[Helpshift sharedInstance] handleNotification:userInfo withController:self.window.rootViewController];
    }
}

- (void) application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Error::%@", error.localizedDescription);
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
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
     [UAirship land];
}

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

@end
