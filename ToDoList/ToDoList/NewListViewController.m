//
//  NewListViewController.m
//  ToDoList
//
//  Created by Rameez Hussain on 03/11/15.
//  Copyright © 2015 Rameez Hussain. All rights reserved.
//

#import "NewListViewController.h"
#import "ToDoListItemTableViewCell.h"
#import "ToDoList.h"
#import "ToDoListItem.h"
#import "ToDoListDataService.h"
#import "NSString+Utils.h"
#import "NewListItemViewController.h"
#import "RootNavViewController.h"
#import "Globals.h"

@interface NewListViewController () <UITableViewDataSource, UITabBarDelegate, UITextViewDelegate>
@property (nonatomic, strong) IBOutlet UIView *listTitleView;
@property (nonatomic, strong) IBOutlet UITableView *toDoListTable;
@property (nonatomic, strong) IBOutlet UITextView *titleTextView;
@property (nonatomic, strong) NSMutableArray *toDoListItems;
@property BOOL listEdited;
@end

@implementation NewListViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    self.title = (!self.toDoList || [self.toDoList.listName isEqualToString:@""]) ? @"New list" : self.toDoList.listName;
    self.toDoListTable.tableHeaderView = self.listTitleView;
    [self.titleTextView setDelegate:self];
    if (self.toDoList && ![self.toDoList.listName isEqualToString:@""]) {
        [self.titleTextView setText: self.toDoList.listName];
    }
    
    self.listEdited = NO;
    [self setupAddNewItemButton];
    [self refreshTable];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupViewToHideKeyboard: self.toDoListTable];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(databaseOperationEnded:)
                                                 name:kDatabaseOperationEndedNotification
                                               object:nil];
    [self refreshTable];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)databaseOperationEnded: (NSNotification *) notification {
    [self performSelectorOnMainThread:@selector(refreshTable) withObject:nil waitUntilDone:YES];
}

- (void) refreshTable {
    @try {
        self.toDoListItems = [NSMutableArray arrayWithArray:[self getSortedArrayByDate:[[ToDoListDataService sharedService] getToDoListForListId:self.toDoList.listId]]];
        [self.toDoListTable reloadData];
    }
    @catch (NSException *exception) {
        NSLog(@"Error. %@", exception.debugDescription);
    }
    @finally {
    }
}

- (NSArray *) getSortedArrayByDate: (NSArray *) array {
    array = [array sortedArrayUsingComparator:^NSComparisonResult(ToDoListItem *a, ToDoListItem *b) {
        NSDate *first = a.created;
        NSDate *second = b.created;
        return [first compare:second];
    }];
    return array;
}


- (void) setupAddNewItemButton {
    UIBarButtonItem *addNewListItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewListItem)];
    self.navigationItem.rightBarButtonItem = addNewListItem;
}

- (void) addNewListItem {
    ToDoListItem *listItem = [ToDoListItem new];
    listItem.itemText = @"";
    listItem.listId = self.toDoList.listId;
    [[ToDoListDataService sharedService] addListItem:listItem];
    [self openNewListItemControllerForItem:listItem];
}

- (void) openNewListItemControllerForItem: (ToDoListItem *) listItem {
    NewListItemViewController *nlvc = [[NewListItemViewController alloc] initWithNibName:@"NewListItemViewController" bundle:nil];
    nlvc.toDoListItem = listItem;
    RootNavViewController *navCtrl = [RootNavViewController new];
    [navCtrl setViewControllers:@[nlvc]];
    [self presentViewController:navCtrl animated:YES completion:nil];
}

- (void) saveListChanges {
    if ([self.toDoList.listName isEmpty] && [self.titleTextView.text isEmpty]) {
        [self.toDoList deleteItem];
    } else if (![self.titleTextView.text isEmpty] && self.listEdited) {
        self.toDoList.listName = self.titleTextView.text;
        [self.toDoList save];
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self saveListChanges];
}

- (void) setDoneButtonOnNavBar {
    UIBarButtonItem *addList = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(handleListEditingDone)];
    self.navigationItem.rightBarButtonItem = addList;
}

- (void) handleListEditingDone {
    [self hideKeyboard];
    [self clearNavBarRightItems];
}

- (void) clearNavBarRightItems {
    self.navigationItem.rightBarButtonItems = nil;
}

#pragma mark - Notifications.

- (void) setupViewToHideKeyboard: (UIView *) view {
    UITapGestureRecognizer *hideKeyboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [hideKeyboard setCancelsTouchesInView:NO];
    [view addGestureRecognizer:hideKeyboard];
}

- (void) hideKeyboard {
    [self.view endEditing:YES];
}

- (void)keyboardDidShow: (NSNotification *) notification{
    [self setDoneButtonOnNavBar];
    NSDictionary* info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [self updateContentScrollViewSize: keyboardSize];
}

- (void)keyboardWillHide: (NSNotification *) notification{
    [self setDefaultScrollViewContentSize];
}

- (void) updateContentScrollViewSize: (CGSize) keyboardSize {
    [self.toDoListTable setContentSize:[self getContentScrollViewSizeToBeSet:keyboardSize]];
}

- (void) updateContentScrollViewSize {
    [self setDefaultScrollViewContentSize];
}

- (void) setDefaultScrollViewContentSize {
    CGSize defaultSize = [self getTableContentSize];
    [self.toDoListTable setContentSize:defaultSize];
    CGPoint bottomOffset = CGPointMake(0, 0);
    [self.toDoListTable setContentOffset:bottomOffset animated:NO];
}

- (CGSize) getContentScrollViewSizeToBeSet: (CGSize) keyboardSize {
    CGSize targetSize = [self getTableContentSize];
    targetSize.height += keyboardSize.height;
    return targetSize;
}

- (CGSize) getTableContentSize {
    CGSize tableContentSize = self.toDoListTable.contentSize;
    tableContentSize.height = 80 * [self.toDoListTable numberOfRowsInSection:0];
    return tableContentSize;
}

#pragma mark - UITableViewDelegate methods.

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;//[self.listHeights[indexPath.row] doubleValue];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.toDoListItems.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"ToDoListItemTableViewCell";
    ToDoListItemTableViewCell *cell = (ToDoListItemTableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    ToDoListItem *item = (ToDoListItem *) self.toDoListItems[indexPath.row];
    cell.itemText.text = item.itemText;
    cell.checkBox.tag = indexPath.row;
    [cell.checkBox setSelected:item.checked];
    [cell.checkBox addTarget:self action:@selector(handleCheckboxSelection:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void) handleCheckboxSelection: (id) sender {
    UIButton *button = (UIButton *) sender;
    ToDoListItem *item = (ToDoListItem *) self.toDoListItems[button.tag];
    item.checked = !item.checked;
    [item save];
    [self.toDoListTable reloadData];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ToDoListItem *item = (ToDoListItem *) self.toDoListItems[indexPath.row];
    [self openNewListItemControllerForItem:item];
}

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        ToDoListItem *item = (ToDoListItem *) self.toDoListItems[indexPath.row];
        [item deleteItem];
        [self.toDoListItems removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        NSLog(@"Unhandled editing style! %ld", (long)editingStyle);
    }
}


#pragma mark - UITextViewDelegate methods

- (void)textViewDidChange:(UITextView *)textView
{
    self.listEdited = YES;
}

@end
