//
//  ToDoListDatabaseManager.h
//  ToDoList
//
//  Created by Rameez Hussain on 28/10/15.
//  Copyright © 2015 Rameez Hussain. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ToDoListDatabaseDelegate <NSObject>

- (void) databaseReadWriteUpdateCompleted;

@end

@interface ToDoListDatabase : NSObject

@property (nonatomic, weak) id<ToDoListDatabaseDelegate> delegate;

- (id) initWithFile:(NSString *)path;
- (NSArray *) getAllToDoLists;
- (NSArray *) getToDoListForListId: (NSInteger) listId;
- (void) deleteListItemWithId: (NSInteger) itemId;
- (void) deleteToDoListWithId: (NSInteger) itemId;
@end
