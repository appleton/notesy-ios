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
@property (strong, nonatomic) CBLDatabase* database;
@property (strong, nonatomic) NSDictionary* userInfo;
@property (strong, nonatomic) CBLReplication *pull;
@property (strong, nonatomic) CBLReplication *push;
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

    [self initNav];
    [self initSearch];

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
    self.database = nil;
    self.userInfo = nil;
}

#pragma mark - UI Setup

- (void) initNav {
    self.title = @"Notes";
    self.navigationItem.titleView = [[UIView alloc] init];

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                  target:self
                                  action:@selector(insertNewNote:)];
    self.navigationItem.rightBarButtonItem = addButton;
}

-(void) initSearch {
    UISearchBar *sb = [[UISearchBar alloc] initWithFrame:self.tableView.tableHeaderView.frame];
    sb.delegate = self;
    self.navigationItem.titleView = sb;
    [sb sizeToFit];
}

#pragma mark - Replication

- (void) initReplication {
    NSString *userSegment = [NSString stringWithFormat:@"%@:%@",
                             [FormattingHelpers urlEncode:self.userInfo[@"username"]],
                             self.userInfo[@"password"]];

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@@%@%@", PROTOCOL, userSegment,
                                       COUCH_URL, self.userInfo[@"notesDb"]]];

    self.push = [self.database createPushReplication:url];
    self.pull = [self.database createPullReplication:url];

    // TODO: Is this bad for battery?
    self.push.continuous = YES;
    self.pull.continuous = YES;

    [self.push addObserver:self forKeyPath:@"completedChangesCount" options:0 context:nil];
    [self.pull addObserver:self forKeyPath:@"completedChangesCount" options:0 context:nil];
}

- (void) replicateDb {
    if (!self.database) return;
    if (!self.pull || !self.push) [self initReplication];

    [self.push start];
    [self.pull start];
}

- (void) cancelDbReplication {
    [self.push removeObserver:self forKeyPath:@"completedChangesCount"];
    [self.pull removeObserver:self forKeyPath:@"completedChangesCount"];

    [self.push stop];
    [self.pull stop];
}

- (void) observeValueForKeyPath:(NSString *)keyPath
                       ofObject:(id)object
                         change:(NSDictionary *)change
                        context:(void *)context {

    if (object != self.pull && object != self.push) return;

    unsigned completed = self.pull.completedChangesCount + self.push.completedChangesCount;
    unsigned total = self.pull.changesCount + self.push.changesCount;

    BOOL showSpinner = (total > 0 && completed < total);

    [UIApplication sharedApplication].networkActivityIndicatorVisible = showSpinner;
}

#pragma mark - Manage notes

- (void) loadNotes {
    if (self.delegate) return;

    CBLQuery* query = [Note allIn:self.database];

    self.delegate = [[NotesTableSource alloc] init];
    self.delegate.tableView = self.tableView;
    self.delegate.query = query.asLiveQuery;

    [self.tableView setDataSource:self.delegate];
    [self.tableView setDelegate:self.delegate];
}

- (void)insertNewNote:(id)sender {
    Note *note = [[Note alloc] initWithNewDocumentInDatabase:self.database];
    [note save:nil];

    note.autosaves = YES;

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    DetailViewController *detail = [storyboard instantiateViewControllerWithIdentifier:@"DetailView"];
    detail.note = note;

    [self.navigationController pushViewController:detail animated:YES];
}

#pragma mark - Table View

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        CBLQueryRow *row = [self.delegate rowAtIndex:indexPath.row];
        Note *note = [Note modelForDocument: row.document];
        note.autosaves = YES;

        self.detailViewController.note = note;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        CBLQueryRow *row = [self.delegate rowAtIndex:indexPath.row];
        Note *note = [Note modelForDocument: row.document];
        note.autosaves = YES;

        [[segue destinationViewController] setNote:note];
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

#pragma mark - Temporary

- (IBAction)logoutButton:(id)sender {
    [self cancelDbReplication];

    self.push = nil;
    self.pull = nil;
    self.userInfo = nil;
    self.database = nil;
    self.delegate = nil;

    [JNKeychain deleteValueForKey:KEYCHAIN_KEY];
    [self performSegueWithIdentifier:@"loginModal" sender:self];
}

@end
