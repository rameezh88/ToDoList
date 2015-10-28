//
//  ToDoListItem.h
//  ToDoList
//
//  Created by Rameez Hussain on 28/10/15.
//  Copyright © 2015 Rameez Hussain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ToDoListItem : NSObject
@property (nonatomic, strong) NSString *itemText;
@property (nonatomic, strong) NSDate *created;
@property NSInteger itemId, listId;
@property BOOL checked;
@end
