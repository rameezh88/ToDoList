//
//  ToDoList.m
//  ToDoList
//
//  Created by Rameez Hussain on 28/10/15.
//  Copyright © 2015 Rameez Hussain. All rights reserved.
//

#import "ToDoList.h"
#import "ToDoListDataService.h"

@implementation ToDoList

- (void) save {
    [[ToDoListDataService sharedService] updateList:self];
}

- (void) deleteItem {
    [[ToDoListDataService sharedService] deleteList:self];
}

@end
