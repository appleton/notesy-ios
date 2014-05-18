//
//  UsersPageViewController.h
//  Notesy
//
//  Created by Andy Appleton on 17/05/2014.
//  Copyright (c) 2014 Notesy.co. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kShowSignupMessage @"ShowSignupPage"
#define kShowLoginMessage @"ShowLoginPage"

@interface UsersPageViewController : UIPageViewController <UIPageViewControllerDataSource>
@property (strong, nonatomic) UIPageViewController *pageViewController;
@end
