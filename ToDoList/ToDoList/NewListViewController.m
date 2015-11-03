//
//  NewListViewController.m
//  ToDoList
//
//  Created by Rameez Hussain on 03/11/15.
//  Copyright © 2015 Rameez Hussain. All rights reserved.
//

#import "NewListViewController.h"
#import "ListItemTableViewCell.h"
#import "ToDoList.h"
#import "ToDoListDataService.h"

@interface NewListViewController () <UITableViewDataSource, UITabBarDelegate, UITextViewDelegate>
@property (nonatomic, strong) IBOutlet UIView *listTitleView;
@property (nonatomic, strong) IBOutlet UITableView *toDoListTable;
@property (nonatomic, strong) IBOutlet UITextView *titleTextView;
@property (nonatomic, strong) NSMutableArray *listHeights, *toDoListItems;
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
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupViewToHideKeyboard: self.toDoListTable];
}

- (void) saveListChanges {
    self.toDoList.listName = self.titleTextView.text;
    if ([self.toDoList.listName isEqualToString:@""] && [self.titleTextView.text isEqualToString:@""]) {
        [self.toDoList deleteItem];
    } else {
        [self.toDoList updateDatabase];
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
    static NSString *identifier = @"ListItemTableViewCell";
    ListItemTableViewCell *cell = (ListItemTableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.listItemText.attributedText = [[NSAttributedString alloc] initWithString:@"+   Add a new list" attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor], NSFontAttributeName: [UIFont systemFontOfSize:17.0]}];
    cell.listItemText.tag = indexPath.row;
//    cell.listItemText.delegate = self;
    [cell.lastModified setHidden:YES];
    return cell;
}

- (void) tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    ListItemTableViewCell *myCell = (ListItemTableViewCell *) cell;
//    myCell.listItemText.delegate = nil;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITextViewDelegate methods

- (void)textViewDidBeginEditing:(UITextView *)textView{
    textView.attributedText = nil;
    textView.text = @" ";
    [textView setFont:[UIFont systemFontOfSize:17]];
    [textView setTextColor:[UIColor blackColor]];
}

- (BOOL) textViewShouldEndEditing:(UITextView *)textView {
    if ([textView isEqual:self.titleTextView]) {
        [self saveListChanges];
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
//    @try {
//        ToDoList *list = self.toDoLists[textView.tag];
//        list.listName = textView.text;
//        self.listHeights[textView.tag] = [NSNumber numberWithDouble:[textView updateHeight]+ 30.0];
//    }
//    @catch (NSException *exception) {
//
//    }
//    @finally {
//
//    }
}

- (void) textViewDidEndEditing:(UITextView *)textView {
    if ([textView isEqual:self.titleTextView]) {
        [self saveListChanges];
    }
//    @try {
//        if (textView.tag == self.listHeights.count - 1) {
//            ToDoList *list = [ToDoList new];
//            list.listId = [self getUniqueListId];
//            list.listName = textView.text;
//            [[ToDoListDataService sharedService] addNewList:list];
//            return;
//        }
//
//        [self.toDoList updateDatabase];
//    }
//    @catch (NSException *exception) {
//    }
//    @finally {
//    }
}

@end
