//
//  DetailViewController.m
//  Notesy
//
//  Created by Andy Appleton on 10/04/2014.
//  Copyright (c) 2014 Notesy.co. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (weak, nonatomic) IBOutlet UITextView *noteText;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noteTextBottomConstraint;
@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(Note *)newNote {
    if (_note != newNote) {
        _note = newNote;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.note) self.noteText.text = self.note.text;
    self.noteText.font = [UIFont fontWithName:@"SourceCodePro-Regular" size:17];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self observeKeyboard];
    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self unObserveKeyboard];
}

#pragma mark - Keyboard observer

- (void)observeKeyboard {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)unObserveKeyboard {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSValue *kbFrame = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];

    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
    UIViewAnimationOptions options = (curve << 16) | UIViewAnimationOptionBeginFromCurrentState;

    CGRect keyboardFrame = [kbFrame CGRectValue];
    CGRect finalKeyboardFrame = [self.view convertRect:keyboardFrame fromView:self.view.window];
    int kbHeight = finalKeyboardFrame.size.height;
    int height = kbHeight + self.noteTextBottomConstraint.constant;

    self.noteTextBottomConstraint.constant = height;

    [UIView animateWithDuration:duration delay:0.0 options:options animations:^{
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];

    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];

    self.noteTextBottomConstraint.constant = 10;

    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController {
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
