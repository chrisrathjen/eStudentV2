//
//  AppDelegate.h
//  eStudent
//
//  Created by Nicolas Autzen on 17.11.12.
//  Copyright (c) 2012 eStudent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
@class HomeScreenViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    UINavigationController *snc; //NavigationController für die Einstellungen -> muss geändert werden, falls wir hier keinen NC nutzen wollen
    UINavigationController *hsnc; //NavigationController für den HomeScreen
    HomeScreenViewController *hsvc; //Der Homescreen
    
    /* dienen der Animation des HomeScreens */
    CABasicAnimation *animation;
    
    CGPoint originalPosition;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) HomeScreenViewController *hsvc;
@property (nonatomic) CABasicAnimation *animation;
@property (nonatomic) BOOL settingsIsVisible;


- (IBAction)toggleSettings:(id)sender;

@end
