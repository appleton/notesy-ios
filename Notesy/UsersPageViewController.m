//
//  UsersPageViewController.m
//  Notesy
//
//  Created by Andy Appleton on 17/05/2014.
//  Copyright (c) 2014 Notesy.co. All rights reserved.
//

#import "UsersPageViewController.h"

@interface UsersPageViewController ()
@property (strong, nonatomic) NSArray *pages;
@end

@implementation UsersPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.pages = @[@"loginViewController", @"signupViewController"];
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"usersPageViewController"];
    self.pageViewController.dataSource = self;

    NSArray *viewControllers = @[[self viewControllerAtIndex:0]];
    [self.pageViewController setViewControllers:viewControllers
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:NO
                                     completion:nil];

    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);

    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];

    [self initObservers];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) initObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showSignupPage)
                                                 name:kShowSignupMessage
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showLoginPage)
                                                 name:kShowLoginMessage
                                               object:nil];
}

- (void) showSignupPage {
    NSArray *viewControllers = @[[self viewControllerAtIndex:1]];
    [self.pageViewController setViewControllers:viewControllers
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:YES
                                     completion:nil];
}

- (void) showLoginPage {
    NSArray *viewControllers = @[[self viewControllerAtIndex:0]];
    [self.pageViewController setViewControllers:viewControllers
                                      direction:UIPageViewControllerNavigationDirectionReverse
                                       animated:YES
                                     completion:nil];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController {
    NSInteger index = [self.pages indexOfObject:viewController.restorationIdentifier];

    if (index == 0) return nil;
    index--;

    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController {
    NSInteger index = [self.pages indexOfObject:viewController.restorationIdentifier];

    if (index >= ([self.pages count] - 1)) return nil;
    index++;

    return [self viewControllerAtIndex:index];
}

- (UIViewController *)viewControllerAtIndex:(NSUInteger)index {
    return [self.storyboard instantiateViewControllerWithIdentifier:[self.pages objectAtIndex:index]];
}

@end
