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
@property (strong, nonatomic) UITextView *noteText;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noteTextBottomConstraint;
@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void) configureView {
    [self initTextField];
    [self initNavigation];
}

- (void) viewDidLoad {
    [super viewDidLoad];

    if ([self.note.text length] == 0) [self.noteText becomeFirstResponder];
    [self observeKeyboard];
    [self observeTextField];
    [self configureView];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self removeObservers];
    [self saveNote];
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
}

- (void) initNavigation {
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc]
                                     initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                     target:self
                                     action:@selector(showDeletePopover)];
    self.navigationItem.rightBarButtonItem = deleteButton;
}

#pragma mark - Managing Note

- (void) initTextField {
    if (!self.note) return;

    // Makes autolayout not thow a fit when showing keyboard ¯\_(ツ)_/¯
    self.noteText.translatesAutoresizingMaskIntoConstraints = NO;
    self.noteText.delegate = self;

    // Set the contents of the text field
    [self.noteText.textStorage replaceCharactersInRange:NSMakeRange(0, self.noteText.text.length)
                                             withString:self.note.text];
    self.noteText.textContainerInset = UIEdgeInsetsMake(20, 5, 20, 20);

    // The second part of the hack in - [MarkdownTextStorage initWithString:]. Remove the space
    // inserted to force indentation to be applied.
    if ([self.noteText.textStorage.string isEqualToString:@" "]) {
        [self.noteText.textStorage deleteCharactersInRange:NSMakeRange(0, 1)];
    }
}

- (void) observeTextField {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(saveNote)
                                                 name:UITextViewTextDidChangeNotification
                                               object:nil];
}

- (void) saveNote {
    if (self.note.text && ![self.note.text isEqualToString:self.noteText.text]) {
        self.note.text = self.noteText.text;
    }
}

- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    [self.noteText scrollRangeToVisible:range];

    if ([text isEqualToString:@"\n"]) {
        [UIView animateWithDuration:0.1 animations:^{
            [self.noteText setContentOffset:CGPointMake(self.noteText.contentOffset.x, self.noteText.contentOffset.y + 40)];
        }];
    }

    return YES;
}

#pragma mark Delete

- (void)deleteNote {
    [self.noteText resignFirstResponder];
    [self.note deleteDocument:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)showDeletePopover {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Delete Note"
                                                    otherButtonTitles:nil];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Delete Note"]) {
        [self deleteNote];
    }
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

    self.noteTextBottomConstraint.constant = 0;

    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController
     willHideViewController:(UIViewController *)viewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)popoverController {
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController
     willShowViewController:(UIViewController *)viewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

#pragma mark - Setters

- (void)setNote:(Note *)note {
    if (_note != note) {
        _note = note;
        [self configureView];
    }

    if (self.masterPopoverController) [self.masterPopoverController dismissPopoverAnimated:YES];
}

@end
