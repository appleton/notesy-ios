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

@interface MasterViewController()
@property (strong, nonatomic) AppDelegate* app;
@property (strong, nonatomic) CBLDatabase* database;
@property (strong, nonatomic) NSMutableArray* notes;
@property (strong, nonatomic) NSDictionary* userInfo;
@end

static NSString* CellIdentifier = @"CellIdentifier";

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
    // [JNKeychain deleteValueForKey:KEYCHAIN_KEY];

    // Set up UI
    self.title = @"Notes";
    self.navigationItem.titleView = [[UIView alloc] init];

    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
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

// TODO: convert this to use a live query
- (void) loadNotes {
    CBLQuery* query = [Note allIn:self.database];
    CBLQueryEnumerator *rowEnum = [query run:nil];

    for (CBLQueryRow* row in rowEnum) [self.notes addObject:[Note modelForDocument:[row document]]];
}

- (void)insertNewObject:(id)sender {
    [self.notes insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.notes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NoteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                            forIndexPath:indexPath];

    Note *note = self.notes[indexPath.row];
    cell.titleLabel.text = [note trimmedTextAtLine:0];
    cell.subtitleLabel.text = [note trimmedTextAtLine:1];
    cell.timeLabel.text = [note formattedUpdatedAt];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.notes removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        Note *note = self.notes[indexPath.row];
        self.detailViewController.note = note;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Note *note = self.notes[indexPath.row];
        [[segue destinationViewController] setNote:note];
    }
}

#pragma mark - Getters

- (NSMutableArray *)notes {
    if (!_notes) _notes = [[NSMutableArray alloc] init];
    return _notes;
}

- (NSDictionary *)userInfo {
    if (!_userInfo) _userInfo = [JNKeychain loadValueForKey:KEYCHAIN_KEY];
    return _userInfo;
}

- (CBLDatabase *)database {
    if (!_database && self.userInfo) self.database = [Note dbInstanceFor:self.userInfo[@"notesDb"]];
    return _database;
}

@end
