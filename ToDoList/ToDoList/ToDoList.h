//
//  ToDoList.h
//  ToDoList
//
//  Created by Rameez Hussain on 28/10/15.
//  Copyright © 2015 Rameez Hussain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ToDoList : NSObject
@property (nonatomic, strong) NSString *listName, *listId;
@property (nonatomic, strong) NSDate *lastModified;
- (void) updateDatabase;
- (void) deleteItem;
@end
