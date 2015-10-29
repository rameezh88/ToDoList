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

@interface HomeViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) IBOutlet UITableView *toDoListTable;
@property (nonatomic, strong) NSMutableArray *toDoLists;
@property int listId;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Home";
    self.toDoLists = [NSMutableArray new];
    [self.toDoListTable reloadData];
    
    self.listId = -1;
    UIBarButtonItem *addList = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewItem)];
    self.navigationItem.rightBarButtonItem = addList;
}

- (void) addNewItem {
    self.listId++;
    ToDoList *list = [ToDoList new];
    list.listId = self.listId;
    list.listName = [self randomStringWithLength:10];
    [[ToDoListDataService sharedService] addNewList:list];
    [self refreshTable];
}

- (void) refreshTable {
    self.toDoLists = [NSMutableArray arrayWithArray:[[ToDoListDataService sharedService] getAllLists]];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(databaseOperationCompleted:) name:kDatabaseOperationEndedNotification object:nil];
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

#pragma mark - Notifications.

- (void)keyboardDidShow: (NSNotification *) notification{
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGPoint center = self.view.center;
    center.y -= keyboardSize.height / 2;
}

- (void)keyboardWillHide:(NSNotification *)notification {
}

//- (void) databaseOperationCompleted:(NSNotification *)notification {
//    self.toDoLists = [NSMutableArray arrayWithArray:[[ToDoListDataService sharedService] getAllLists]];
//    [self.toDoListTable reloadData];
//}

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
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    ToDoList *list = self.toDoLists[indexPath.row];
    cell.textLabel.text = list.listName;
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
