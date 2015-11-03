//
//  HomeViewController.m
//  ToDoList
//
//  Created by Rameez Hussain on 28/10/15.
//  Copyright © 2015 Rameez Hussain. All rights reserved.
//

#import "HomeViewController.h"
#import "ToDoList.h"
#import "Globals.h"
#import "ToDoListDataService.h"
#import "ListItemTableViewCell.h"
#import "UIViewController+CommonOperations.h"
#import "NewListViewController.h"
#import "NSMutableArray+Reverse.h"

@interface HomeViewController () <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>
@property (nonatomic, strong) IBOutlet UITableView *toDoListTable;
@property (nonatomic, strong) NSMutableArray *toDoLists;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"All lists";
    self.toDoLists = [NSMutableArray new];
    [self.toDoListTable reloadData];
    [self setupAddNewListButton];
}

- (void) setupAddNewListButton {
    UIBarButtonItem *addNewListItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewList)];
    self.navigationItem.rightBarButtonItem = addNewListItem;
}

- (void) addNewList {
    ToDoList *list = [ToDoList new];
    list.listName = @"";
    [[ToDoListDataService sharedService] addNewList:list];
    [self openNewListControllerForList:list];
}

- (void) openNewListControllerForList: (ToDoList *) list {
    NewListViewController *nlvc = [[NewListViewController alloc] initWithNibName:@"NewListViewController" bundle:nil];
    nlvc.toDoList = list;
    [self.navigationController pushViewController:nlvc animated:YES];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(databaseOperationEnded:)
                                                 name:kDatabaseOperationEndedNotification
                                               object:nil];
}

- (void) refreshTable {
    self.toDoLists = [NSMutableArray arrayWithArray:[[ToDoListDataService sharedService] getAllLists]];
    [self.toDoLists reverse];
    [self.toDoListTable reloadData];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self refreshTable];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *) stringFromDate: (NSDate *) date {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"hh:mm, MMM d"];
    return [dateFormat stringFromDate:date];
}

- (void)databaseOperationEnded: (NSNotification *) notification {
    [self refreshTable];
}

#pragma mark - UITableViewDelegate methods.

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.toDoLists.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"ListItemTableViewCell";
    ListItemTableViewCell *cell = (ListItemTableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }

    @try {
        [cell.lastModified setHidden:NO];
        ToDoList *list = self.toDoLists[indexPath.row];
        cell.listItemText.text = list.listName;
        cell.listItemText.tag = indexPath.row;
        cell.lastModified.text = [self stringFromDate:list.lastModified];
    }
    @catch (NSException *exception) {
    }
    @finally {
        
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NewListViewController *nlvc = [[NewListViewController alloc] initWithNibName:@"NewListViewController" bundle:nil];
    nlvc.toDoList = self.toDoLists[indexPath.row];
    [self.navigationController pushViewController:nlvc animated:YES];
}

//- (NSString *) tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return @"Delete";
//}
@end
