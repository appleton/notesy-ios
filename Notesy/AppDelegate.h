//
//  AppDelegate.h
//  Notesy
//
//  Created by Andy Appleton on 10/04/2014.
//  Copyright (c) 2014 Notesy.co. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CouchbaseLite/CouchbaseLite.h>

#define kAppEnteredForeground @"AppEnteredForeground"
#define kAppEnteredBackground @"AppEnteredBackground"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CBLDatabase *database;

@end
