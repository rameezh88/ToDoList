//
//  ToDoListItem.m
//  ToDoList
//
//  Created by Rameez Hussain on 28/10/15.
//  Copyright © 2015 Rameez Hussain. All rights reserved.
//

#import "ToDoListItem.h"
#import "ToDoListDataService.h"

@implementation ToDoListItem

- (void) save {
    [[ToDoListDataService sharedService] updateListItem:self];
}

- (void) deleteItem {
    [[ToDoListDataService sharedService] deleteListItem:self];
}

@end
