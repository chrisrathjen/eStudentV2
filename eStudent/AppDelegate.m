//
//  AppDelegate.m
//  eStudent
//
//  Created by Nicolas Autzen on 17.11.12.
//  Copyright (c) 2012 eStudent. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "HomeScreenViewController.h"
#import "EinstellungenViewController.h"
#import "CoreDataDataManager.h"
#import "ESRemindersDataManager.h"

@interface AppDelegate ()
{
    EinstellungenViewController *svc;
}

@end

@implementation AppDelegate

@synthesize hsvc;
@synthesize animation;
@synthesize settingsIsVisible;

//Lädt den Homescreen.
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    svc = [[EinstellungenViewController alloc] initWithNibName:@"Einstellungen" bundle:nil];
    snc = [[UINavigationController alloc] initWithRootViewController:svc];
    snc.navigationBar.tintColor = [UIColor colorWithRed:.15 green:.15 blue:.15 alpha:1.0];//[UIColor colorWithPatternImage:[UIImage imageNamed:@"settings_background"]];
    
    hsvc = [[HomeScreenViewController alloc] initWithNibName:@"HomeScreen" bundle:nil];
    hsvc.view.frame = [[UIScreen mainScreen] applicationFrame];
    
    hsnc = [[UINavigationController alloc] initWithRootViewController:hsvc];
    hsnc.navigationBar.tintColor = [UIColor colorWithRed:.25 green:.51 blue:.77 alpha:1.0]; //setzt die NavigationBar auf das Uni-Blau
    
    UIImage *settingsImage = [UIImage imageNamed:@"settings-icon"];
    UIBarButtonItem *bi = [[UIBarButtonItem alloc] initWithImage:settingsImage landscapeImagePhone:settingsImage style:UIBarButtonItemStylePlain target:self action:@selector(toggleSettings:)];
    hsnc.navigationBar.topItem.leftBarButtonItem = bi;
    
    [snc.view addSubview:hsnc.view];
    
    self.window.rootViewController = snc;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [CoreDataDataManager sharedInstance]; //Not needed in Version 2.0
    [self resetCachedData];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    
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
    [hsvc refreshMensaData];
//    if ([[ESRemindersDataManager sharedInstance] remindersAccessible]) {
//        if ([[ESRemindersDataManager sharedInstance] remindersInUse]) {
//            [[ESRemindersDataManager sharedInstance] syncronizeAllLinkedReminders];
//            if (kDEBUG) {
//                NSLog(@"Sync Kriterien mit der Reminders App");
//            }
//        }
//    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - HomeScreen Animation

/* Slidet den HomeSreen zur rechten Seite weg und präsentiert die darunterliegenden Einstellungen */
- (IBAction)toggleSettings:(id)sender
{
    if (!animation)
    {
        animation = [CABasicAnimation animationWithKeyPath:@"position.x"]; //definiert die Animation als BasicAnimation
    }
    animation.duration = .25;
    CAMediaTimingFunction *tf = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]; //sorgt für einen sanften Ausgang der Animation
    animation.timingFunction = tf;
    animation.removedOnCompletion = NO; //wird für sauberen Übergang der Animation benötigt
    animation.fillMode = kCAFillModeForwards; //wird für sauberen Übergang der Animation benötigt
    animation.delegate = self; //ruft am Ende den Selector animationDidStop:finished: auf
    
    if (!settingsIsVisible) //sind die Einstellungen nicht sichtbar, dann wird der HomeScreen nach rechts geslidet
    {
        originalPosition = hsnc.view.layer.position;
        float width = [[UIScreen mainScreen] applicationFrame].size.width - 50.0;
        animation.toValue = [NSNumber numberWithFloat:(hsnc.view.layer.position.x + width)];
        [hsnc.view.layer addAnimation:animation forKey:@"showSettings"];
        [svc viewWillAppear:NO];
    }
    else //andernfalls wird der HomeScreen zurückgeslidet
    {
        animation.toValue = [NSNumber numberWithFloat:originalPosition.x];
        [hsnc.view.layer addAnimation:animation forKey:@"hideSettings"];
        [hsvc refreshMensaData];
    }
}

/* Wird aufgerufen, wenn die Animation endet -> die neuen Koordinaten des HomeScreens werden festgesetzt, andernfalls würde die Animation wieder in die Ursprungslage zurückfallen */
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag)
    {
        if (!settingsIsVisible)
        {
            float width = [[UIScreen mainScreen] applicationFrame].size.width - 50.0;
            hsnc.view.layer.position = CGPointMake(hsnc.view.layer.position.x + width, hsnc.view.layer.position.y);
            settingsIsVisible = YES;
        }
        else
        {
            hsnc.view.layer.position = originalPosition;
            settingsIsVisible = NO;
        }
        ((HomeScreenViewController *)[hsnc.viewControllers objectAtIndex:0]).settingsIsVisible = settingsIsVisible;
    }
}
//Loescht Poi und MensaDaten Caches.
- (void)resetCachedData
{
    NSString *filePath = [[[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:kSavedPoiDataFileName] stringByExpandingTildeInPath];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLastCampusPOIRefresh];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    [ESMensaDataManager resetCache];
}

@end
