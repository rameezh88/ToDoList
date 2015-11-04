//
//  ToDoListDatabaseManager.h
//  ToDoList
//
//  Created by Rameez Hussain on 28/10/15.
//  Copyright © 2015 Rameez Hussain. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ToDoList;
@class ToDoListItem;

@protocol ToDoListDatabaseDelegate <NSObject>

- (void) databaseReadWriteUpdateCompleted;

@end

@interface ToDoListDatabase : NSObject

@property (nonatomic, weak) id<ToDoListDatabaseDelegate> delegate;

- (id) initWithFile:(NSString *)path;
- (NSArray *) getAllToDoLists;
- (NSArray *) getToDoListForListId: (NSString *) listId;
- (void) updateList:(ToDoList *)list;
- (void) insertList: (ToDoList *) list;
- (void) updateToDoListItem:(ToDoListItem *)listItem;
- (void) insertToDoListItem: (ToDoListItem *)listItem;
- (void) deleteListItemWithId: (NSString *) itemId;
- (void) deleteToDoListWithId: (NSString *) itemId;
@end
