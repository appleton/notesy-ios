//
//  MasterViewController.m
//  Notesy
//
//  Created by Andy Appleton on 10/04/2014.
//  Copyright (c) 2014 Notesy.co. All rights reserved.
//

#import "AppDelegate.h"
#import "MasterViewController.h"
#import "DetailViewController.h"
#import "Constants.h"
#import "JNKeychain.h"
#import "Note.h"
#import "CouchbaseLite.h"
#import "NoteTableViewCell.h"
#import "FormattingHelpers.h"
#import "NotesTableSource.h"

@interface MasterViewController()
@property (strong, nonatomic) AppDelegate* app;
@property (strong, nonatomic) CBLDatabase* database;
@property (strong, nonatomic) NSDictionary* userInfo;
@property (nonatomic) IBOutlet NotesTableSource* delegate;
@end

@implementation MasterViewController

- (void)awakeFromNib {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // TODO: remove this
//    [JNKeychain deleteValueForKey:KEYCHAIN_KEY];

    // Set up UI
    self.title = @"Notes";
    self.navigationItem.titleView = [[UIView alloc] init];

    self.navigationItem.leftBarButtonItem = self.editButtonItem;

//    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
//    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];

    // Open login modal if not signed in
    if (!self.userInfo) [self performSegueWithIdentifier:@"loginModal" sender:self];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self replicateDb];
    [self loadNotes];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) replicateDb {
    if (!self.database) return;

    NSString *userSegment = [NSString stringWithFormat:@"%@:%@",
                             [FormattingHelpers urlEncode:self.userInfo[@"username"]],
                             self.userInfo[@"password"]];

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@@%@%@", PROTOCOL, userSegment,
                                       COUCH_URL, self.userInfo[@"notesDb"]]];

    CBLReplication *push = [self.database createPushReplication:url];
    CBLReplication *pull = [self.database createPullReplication:url];

    [push start];
    [pull start];
}

- (void) loadNotes {
    CBLQuery* query = [Note allIn:self.database];

    self.delegate = [[NotesTableSource alloc] init];
    self.delegate.tableView = self.tableView;
    self.delegate.query = query.asLiveQuery;

    [self.tableView setDataSource:self.delegate];
    [self.tableView setDelegate:self.delegate];
}

//- (void)insertNewObject:(id)sender {
//    [self.notes insertObject:[NSDate date] atIndex:0];
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//}

#pragma mark - Table View

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return [self.notes count];
//}
//

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        [self.notes removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//        Note *note = self.notes[indexPath.row];
        self.detailViewController.note = nil;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
//        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//        Note *note = self.notes[indexPath.row];
        [[segue destinationViewController] setNote:nil];
    }
}

#pragma mark - Getters

- (NSDictionary *)userInfo {
    if (!_userInfo) _userInfo = [JNKeychain loadValueForKey:KEYCHAIN_KEY];
    return _userInfo;
}

- (CBLDatabase *)database {
    if (!_database && self.userInfo) self.database = [Note dbInstanceFor:self.userInfo[@"notesDb"]];
    return _database;
}

@end
