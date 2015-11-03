//
//  ToDoListDataService.h
//  ToDoList
//
//  Created by Rameez Hussain on 28/10/15.
//  Copyright © 2015 Rameez Hussain. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ToDoListItem;
@class ToDoList;

@interface ToDoListDataService : NSObject
+ (id)sharedService;
- (NSArray *) getAllLists;
- (NSArray *) getToDoListForListId:(NSInteger) listId;
- (void) addListItem: (ToDoListItem *) item;
- (void) updateListItem: (ToDoListItem *) item;
- (void) deleteListItem: (ToDoListItem *) listItem;
- (void) addNewList: (ToDoList *) list;
- (void) updateList: (ToDoList *) list;
- (void) deleteList: (ToDoList *) list;
@end
