//
//  NewListItemViewController.m
//  ToDoList
//
//  Created by Rameez Hussain on 04/11/15.
//  Copyright © 2015 Rameez Hussain. All rights reserved.
//

#import "NewListItemViewController.h"
#import "UIPlaceholderTextView.h"
#import "NSString+Utils.h"
#import "ToDoListItem.h"

@interface NewListItemViewController () <UITextViewDelegate>

@property (nonatomic, strong) IBOutlet UIPlaceHolderTextView *textView;
@property BOOL itemEdited;

@end

@implementation NewListItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.itemEdited = NO;
    self.title = ([self.toDoListItem.itemText isEmpty]) ? @"New list item" : self.toDoListItem.itemText;
    [self setupDoneButton];
}

- (void) setupDoneButton {
    UIBarButtonItem *addNewListItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(handleEditingDone)];
    self.navigationItem.rightBarButtonItem = addNewListItem;
}

- (void) handleEditingDone {
    if ([self.toDoListItem.itemText isEmpty] && [self.textView.text isEmpty]) {
        [self.toDoListItem deleteItem];
    } else if (![self.textView.text isEmpty] && self.itemEdited) {
        self.toDoListItem.itemText = self.textView.text;
        [self.toDoListItem save];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextViewDelegate methods

- (void)textViewDidChange:(UITextView *)textView
{
    self.itemEdited = YES;
}


@end
