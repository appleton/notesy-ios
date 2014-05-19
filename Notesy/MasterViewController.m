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
#import "SettingsViewController.h"

@interface MasterViewController()
@property (strong, nonatomic) CBLDatabase* database;
@property (strong, nonatomic) CBLLiveQuery *tableQuery;
@property (strong, nonatomic) NSDictionary* userInfo;
@property (strong, nonatomic) CBLReplication *pull;
@property (strong, nonatomic) CBLReplication *push;
@property (nonatomic) IBOutlet NotesTableSource* delegate;
@property (strong, nonatomic) UISearchDisplayController *searchController;
@property (strong, nonatomic) UIBarButtonItem *addButton;
@property (strong, nonatomic) UIBarButtonItem *navButton;
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
    [self observeLogout];

    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];

    // Open login modal if not signed in
    if (!self.userInfo) [self performSegueWithIdentifier:@"loginModal" sender:self];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self replicateDb];
    [self loadNotes];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    [self insertNavButtons];
}

- (void) insertNavButtons {
    self.navigationItem.rightBarButtonItem = self.addButton;
    self.navigationItem.leftBarButtonItem = self.navButton;
}

-(void) initSearch {
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:self.tableView.tableHeaderView.frame];

    self.searchController = [[UISearchDisplayController alloc]
                                                    initWithSearchBar:searchBar
                                                   contentsController:self];
    self.searchController.delegate = self;
    self.searchController.searchResultsDataSource = self;
    self.searchController.searchResultsDelegate = self;

    searchBar.delegate = self;
    searchBar.searchBarStyle = UISearchBarStyleMinimal;

    self.navigationItem.titleView = searchBar;
    [searchBar sizeToFit];
}

- (void) segueToNavigation:(id)sender {
    [self performSegueWithIdentifier:@"showSettings" sender:self];
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

    self.tableQuery = [[Note allIn:self.database] asLiveQuery];

    self.delegate = [[NotesTableSource alloc] init];
    self.delegate.tableView = self.tableView;
    self.delegate.query = self.tableQuery;

    self.tableView.dataSource = self.delegate;
    self.tableView.delegate = self.delegate;
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

#pragma mark - Logout

- (void) observeLogout {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(logout)
                                                 name:kLogoutMessage
                                               object:nil];
}

- (void) logout {
    [self cancelDbReplication];

    self.push = nil;
    self.pull = nil;
    self.userInfo = nil;
    self.database = nil;
    self.delegate = nil;

    [JNKeychain deleteValueForKey:KEYCHAIN_KEY];
    [self performSegueWithIdentifier:@"loginModal" sender:self];
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

#pragma mark - Search

- (BOOL) searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = nil;

    if (!searchBar.showsCancelButton) [searchBar setShowsCancelButton:YES animated:YES];

    return YES;
}

- (BOOL) searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    if (![searchString isEqualToString:@""]) {
        self.delegate.query = [[Note searchIn:self.database forText:searchString] asLiveQuery];
    }
    return YES;
}

- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText isEqualToString:@""]) self.delegate.query = self.tableQuery;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    [searchBar resignFirstResponder];
    searchBar.text = @"";
    self.delegate.query = self.tableQuery;
    [self.searchController.searchBar setShowsCancelButton:NO animated:NO];
    [self insertNavButtons];
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

- (UIBarButtonItem *) addButton {
    if (!_addButton) {
        _addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                   target:self
                                                                   action:@selector(insertNewNote:)];
    }
    return _addButton;
}

- (UIBarButtonItem *) navButton {
    if (!_navButton) {
        _navButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu-icon"]
                                                      style:UIBarButtonItemStylePlain
                                                     target:self
                                                     action:@selector(segueToNavigation:)];
    }
    return _navButton;
}

@end
