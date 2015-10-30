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
#import "UITextView+VariableHeight.h"

@interface HomeViewController () <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>
@property (nonatomic, strong) IBOutlet UITableView *toDoListTable;
@property (nonatomic, strong) NSMutableArray *toDoLists;
@property (nonatomic, strong) NSMutableArray *listHeights;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Home";
    self.toDoLists = [NSMutableArray new];
    [self.toDoListTable reloadData];
//    [self addNewItem];
}

- (void) setDoneButtonOnNavBar {
    UIBarButtonItem *addList = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(handleListEditingDone)];
    self.navigationItem.rightBarButtonItem = addList;
}

- (void) handleListEditingDone {
    [self hideKeyboard];
    [self clearNavBarRightItems];
    [self refreshTable];
}

- (void) clearNavBarRightItems {
    self.navigationItem.rightBarButtonItems = nil;
}

- (void) addNewItem {
    ToDoList *list = [ToDoList new];
    list.listId = [self getUniqueListId];
    list.listName = [self randomStringWithLength:10];
    [[ToDoListDataService sharedService] addNewList:list];
    [self refreshTable];
}

- (void) updateListHeights {
    self.listHeights = [NSMutableArray new];
    for (int i = 0; i < self.toDoLists.count; i++) {
        [self.listHeights addObject:[NSNumber numberWithDouble:80.0]];
    }
    [self.listHeights addObject:[NSNumber numberWithDouble:80.0]];
}

- (void) refreshTable {
    self.toDoLists = [NSMutableArray arrayWithArray:[[ToDoListDataService sharedService] getAllLists]];
    [self updateListHeights];
    [self.toDoListTable reloadData];
}

-(NSString *) randomStringWithLength: (int) len {
    NSString *alphabet  = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY0123456789";
    NSMutableString *s = [NSMutableString stringWithCapacity:20];
    for (NSUInteger i = 0U; i < 20; i++) {
        u_int32_t r = arc4random() % [alphabet length];
        unichar c = [alphabet characterAtIndex:r];
        [s appendFormat:@"%C", c];
    }
    return s;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self registerForKeyboardNotifications];
    [self setupViewToHideKeyboard: self.toDoListTable];
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

#pragma mark - Notifications.

- (void) setupViewToHideKeyboard: (UIView *) view {
    UITapGestureRecognizer *hideKeyboard = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [hideKeyboard setCancelsTouchesInView:YES];
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
//    CGPoint bottomOffset = CGPointMake(0, keyboardSize.height);
//    [self.toDoListTable setContentOffset:bottomOffset animated:YES];
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
    return self.listHeights.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"ListItemTableViewCell";
    ListItemTableViewCell *cell = (ListItemTableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:identifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }

    if (self.toDoLists.count == 0 || indexPath.row == self.toDoLists.count) {
        cell.listItemText.attributedText = [[NSAttributedString alloc] initWithString:@"Add a new item" attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
        cell.listItemText.tag = indexPath.row;
        cell.listItemText.delegate = self;
        [cell.lastModified setHidden:YES];
        return cell;
    }
    
    @try {
        [cell.lastModified setHidden:NO];
        ToDoList *list = self.toDoLists[indexPath.row];
        cell.listItemText.text = list.listName;
        [cell.listItemText updateHeight];
        cell.listItemText.tag = indexPath.row;
        cell.listItemText.delegate = self;
        cell.lastModified.text = [self stringFromDate:list.lastModified];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    ListItemTableViewCell *myCell = (ListItemTableViewCell *) cell;
    myCell.listItemText.delegate = nil;
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

- (void)textViewDidChange:(UITextView *)textView
{
    @try {
        ToDoList *list = self.toDoLists[textView.tag];
        list.listName = textView.text;
        self.listHeights[textView.tag] = [NSNumber numberWithDouble:[textView updateHeight]+ 30.0];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}

- (void) textViewDidEndEditing:(UITextView *)textView {
    @try {
        if (textView.tag == self.listHeights.count - 1) {
            ToDoList *list = [ToDoList new];
            list.listId = [self getUniqueListId];
            list.listName = textView.text;
            [[ToDoListDataService sharedService] addNewList:list];
            return;
        }
        
        ToDoList *list = self.toDoLists[textView.tag];
        [list updateDatabase];
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
}

- (NSInteger) getUniqueListId {
    if (self.toDoLists.count > 0) {
        return self.toDoLists.count+1;
    }
    return 0;
}

@end
