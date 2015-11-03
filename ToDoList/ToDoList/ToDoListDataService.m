//
//  ToDoListDataService.m
//  ToDoList
//
//  Created by Rameez Hussain on 28/10/15.
//  Copyright © 2015 Rameez Hussain. All rights reserved.
//

#import "ToDoListDataService.h"
#import "ToDoListDatabase.h"
#import "Globals.h"
#import "ToDoList.h"
#import "ToDoListItem.h"

@interface ToDoListDataService () <ToDoListDatabaseDelegate>

@property (nonatomic, strong) ToDoListDatabase *database;

@end

@implementation ToDoListDataService

+ (id)sharedService {
    static ToDoListDataService *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        [self configureDatabase];
    }
    return self;
}


#pragma mark - Database configuration.

- (void) configureDatabase {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *documentDBFolderPath = [documentsDirectory stringByAppendingPathComponent:@"database"];
    NSString *finalDatabasePath = [documentDBFolderPath stringByAppendingPathComponent:@"todolist.sqlite"];
    BOOL success = [fileManager fileExistsAtPath:finalDatabasePath];
    if (!success){
        [self copyBundledDatabase];
    }
    self.database = [[ToDoListDatabase alloc] initWithFile:finalDatabasePath];
    self.database.delegate = self;
}

- (void) copyBundledDatabase {
    NSString *resourceDBFolderPath;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *documentDBFolderPath = [documentsDirectory stringByAppendingPathComponent:@"database"];
    NSString *finalDatabasePath = [documentDBFolderPath stringByAppendingPathComponent:@"todolist.sqlite"];
    resourceDBFolderPath = [[NSBundle mainBundle] pathForResource:@"todolist" ofType:@"sqlite"];
    [fileManager createDirectoryAtPath:documentDBFolderPath withIntermediateDirectories:NO attributes:nil error:nil];
    if (![fileManager fileExistsAtPath:finalDatabasePath])
    {
        if ([fileManager fileExistsAtPath:resourceDBFolderPath]) {
            BOOL copySuccess = [fileManager copyItemAtPath:resourceDBFolderPath toPath:finalDatabasePath
                                                     error:&error];
            if (!copySuccess){
                NSLog(@"Database copy not successful. %@", error.localizedDescription);
            }
        }
    }
}

#pragma mark - Instance methods.

- (NSArray *) getAllLists {
    return [self.database getAllToDoLists];
}

- (NSArray *) getToDoListForListId:(NSInteger) listId {
    return [self.database getToDoListForListId:listId];
}

- (void) addListItem: (ToDoListItem *) item {
    [self.database insertToDoListItem:item];
}

- (void) updateListItem: (ToDoListItem *) item {
    [self.database updateToDoListItem:item];
}

- (void) addNewList: (ToDoList *) list {
    NSUUID  *UUID = [NSUUID UUID];
    NSString* stringUUID = [UUID UUIDString];
    list.listId = stringUUID;
    [self.database insertList:list];
}

- (void) updateList: (ToDoList *) list {
    [self.database updateList:list];
}

- (void) deleteList:(ToDoList *)list {
    [self.database deleteToDoListWithId:list.listId];
}

- (void) deleteListItem: (ToDoListItem *) listItem {
    [self.database deleteListItemWithId:listItem.itemId];
}

#pragma mark - ToDoListDelegate methods.

- (void) databaseReadWriteUpdateCompleted {
    [[NSNotificationCenter defaultCenter] postNotificationName:kDatabaseOperationEndedNotification object:nil];
}


@end
