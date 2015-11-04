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
#import "ToDoListDataService.h"
#import "NSString+Utils.h"

@interface NewListViewController () <UITableViewDataSource, UITabBarDelegate, UITextViewDelegate>
@property (nonatomic, strong) IBOutlet UIView *listTitleView;
@property (nonatomic, strong) IBOutlet UITableView *toDoListTable;
@property (nonatomic, strong) IBOutlet UITextView *titleTextView;
@property (nonatomic, strong) NSMutableArray *listHeights, *toDoListItems;
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
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupViewToHideKeyboard: self.toDoListTable];
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
    return [self.listHeights[indexPath.row] doubleValue];
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
    
    cell.itemText.tag = indexPath.row;
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITextViewDelegate methods

- (void)textViewDidChange:(UITextView *)textView
{
    self.listEdited = YES;
}

@end
