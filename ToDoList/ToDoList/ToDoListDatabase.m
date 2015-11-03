//
//  ToDoListDatabaseManager.m
//  ToDoList
//
//  Created by Rameez Hussain on 28/10/15.
//  Copyright © 2015 Rameez Hussain. All rights reserved.
//

#import "ToDoListDatabase.h"
#import "ToDoList.h"
#import "ToDoListItem.h"
#import "sqlite3.h"

static NSString * const kDatabaseOperation = @"database_operation";
static NSString * const kToDoListTable = @"todo_lists";
static NSString * const kToDoListItemsTable = @"list_items";

@interface ToDoListDatabase ()

@property (nonatomic, strong) NSOperationQueue *databaseOperationQueue;

@end


@implementation ToDoListDatabase {
    sqlite3 * _sqlite3db;
}

static NSString * syncronized_object = @"Syncronized";

#pragma mark -

- (void)closeDatabase {
    if (_sqlite3db)
        sqlite3_close(_sqlite3db);
    _sqlite3db = NULL;
}

- (id)initWithFile:(NSString *)path {
    if (self = [super init]) {
        self.databaseOperationQueue = [NSOperationQueue new];
        if (!sqlite3_open_v2([path UTF8String], &_sqlite3db, SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK &&
            sqlite3_config(SQLITE_CONFIG_SERIALIZED) == SQLITE_OK) {
            NSLog(@"#%s:%d:Error opening quiz database", __FUNCTION__, __LINE__);
        }
    }
    return self;
}

- (void)dealloc {
    [self closeDatabase];
}

#pragma mark - Helpers.

- (NSDate *) dateFromString: (char *) dateStr {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *DateTimeString = [NSString stringWithUTF8String:dateStr];
    NSLog(@"DateTimeString = %@", DateTimeString);
    NSDate *myDate =[dateFormat dateFromString:DateTimeString];
    return myDate;
}

- (NSString *) stringFromDate: (NSDate *) date {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    return [dateFormat stringFromDate:date];
}

- (void) updateToDoListItem:(ToDoListItem *)listItem {
    NSInvocationOperation *insertOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(insertToDoListItem:) object:listItem];
    [self addDatabaseOperation:insertOperation toQueue:self.databaseOperationQueue];
}


- (void) insertToDoListItem: (ToDoListItem *)listItem {
    @synchronized (kDatabaseOperation) {
        NSString *sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %s (id,todo_list_id,text,checked,created) VALUES ('%s', '%s', '%s', %ld, '%s')", [kToDoListItemsTable UTF8String], [listItem.itemId UTF8String], [listItem.listId UTF8String], [listItem.itemText UTF8String], (long)listItem.checked, [[self stringFromDate:[NSDate new]] UTF8String]];
        sqlite3_stmt * insertStatement;
        int retVal = sqlite3_prepare_v2(_sqlite3db, [sql UTF8String], -1, &insertStatement, NULL);
        if (retVal == SQLITE_OK) {
            char * errMsg;
            int rc = sqlite3_exec(_sqlite3db, [sql UTF8String] ,NULL,NULL,&errMsg);
            if(SQLITE_OK != rc)
            {
                NSLog(@"Failed to insert record  rc:%d, msg=%s",rc,errMsg);
            } else {
                NSLog(@"#%s:%d:Sqlite Success. Inserted item.", __FUNCTION__, __LINE__);
            }
        } else {
            const char * err = sqlite3_errmsg(_sqlite3db);
            NSLog(@"#%s:%d:Sqlite Error: %s", __FUNCTION__, __LINE__, err);
        }
        sqlite3_finalize(insertStatement);
    }
}

- (void) updateList:(ToDoList *)list {
    NSInvocationOperation *insertOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(insertList:) object:list];
    [self addDatabaseOperation:insertOperation toQueue:self.databaseOperationQueue];
}

- (void) insertList: (ToDoList *) list {
    @synchronized (kDatabaseOperation) {
        NSString *sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %s (id,list_name,modified) VALUES ('%s','%s','%s')", [kToDoListTable UTF8String], [list.listId UTF8String], [list.listName UTF8String], [[self stringFromDate:[NSDate new]] UTF8String]];
        sqlite3_stmt * insertStatement;
        int retVal = sqlite3_prepare_v2(_sqlite3db, [sql UTF8String], -1, &insertStatement, NULL);
        if (retVal == SQLITE_OK) {
            char * errMsg;
            int rc = sqlite3_exec(_sqlite3db, [sql UTF8String] ,NULL,NULL,&errMsg);
            if(SQLITE_OK != rc)
            {
                NSLog(@"Failed to insert record  rc:%d, msg=%s",rc,errMsg);
            } else {
                NSLog(@"#%s:%d:Sqlite Success. Inserted item.", __FUNCTION__, __LINE__);
            }
        } else {
            const char * err = sqlite3_errmsg(_sqlite3db);
            NSLog(@"#%s:%d:Sqlite Error: %s", __FUNCTION__, __LINE__, err);
        }
        sqlite3_finalize(insertStatement);
    }
}


- (NSArray *) getAllToDoLists {
    if (!_sqlite3db) {
        NSLog(@"No db initialized");
        return nil;
    }
    @synchronized(syncronized_object) {
        NSMutableArray * arr = nil;
        NSString *sql = [NSString stringWithFormat:@"select id, list_name, modified from %@", kToDoListTable];
        sqlite3_stmt * selectStatement;
        int retVal = sqlite3_prepare_v2(_sqlite3db, [sql UTF8String], -1, &selectStatement, NULL);
        if (retVal == SQLITE_OK) {
            char *listId;
            char *nameStr;
            NSString *name, *listIdStr;
            NSDate *modified;
            arr = [[NSMutableArray alloc] initWithCapacity:8];
            ToDoList *list;
            while (sqlite3_step(selectStatement) == SQLITE_ROW) {
                listId = (char *)sqlite3_column_text(selectStatement, 0);
                nameStr = (char *)sqlite3_column_text(selectStatement, 1);
                char *dateTime = (char *)sqlite3_column_text(selectStatement, 2);
                modified = [self dateFromString:dateTime];
                name = [NSString stringWithCString:nameStr encoding:NSUTF8StringEncoding];
                listIdStr = [NSString stringWithCString:listId encoding:NSUTF8StringEncoding];
                list = [ToDoList new];
                list.listId = listIdStr;
                list.listName = name;
                list.lastModified = modified;
                [arr addObject:list];
            }
        } else {
            const char * err = sqlite3_errmsg(_sqlite3db);
            NSLog(@"#%s:%d:Sqlite Error: %s", __FUNCTION__, __LINE__, err);
        }
        sqlite3_finalize(selectStatement);
        return arr;
    }
}

- (NSArray *) getToDoListForListId: (NSInteger) listId {
    if (!_sqlite3db) {
        NSLog(@"No db initialized");
        return nil;
    }
    @synchronized(syncronized_object) {
        NSMutableArray * arr = nil;
        NSString *sql = [NSString stringWithFormat:@"select id, todo_list_id, text, checked, created from %@", kToDoListItemsTable];
        sqlite3_stmt * selectStatement;
        int retVal = sqlite3_prepare_v2(_sqlite3db, [sql UTF8String], -1, &selectStatement, NULL);
        if (retVal == SQLITE_OK) {
            char *listId, *listItemId;
            BOOL checked;
            char *text, *created;
            arr = [[NSMutableArray alloc] initWithCapacity:8];
            ToDoListItem *listItem;
            while (sqlite3_step(selectStatement) == SQLITE_ROW) {
                listItemId = (char *)sqlite3_column_text(selectStatement, 0);
                listId = (char *)sqlite3_column_text(selectStatement, 1);
                text = (char *)sqlite3_column_text(selectStatement, 2);
                checked = sqlite3_column_int(selectStatement, 3);
                created = (char *)sqlite3_column_text(selectStatement, 4);
                NSDate *itemCreated = [self dateFromString:created];
                NSString *textStr = [NSString stringWithCString:text encoding:NSUTF8StringEncoding];
                NSString *listItemIdStr = [NSString stringWithCString:listItemId encoding:NSUTF8StringEncoding];
                NSString *listIdStr = [NSString stringWithCString:listId encoding:NSUTF8StringEncoding];
                listItem.itemId = listItemIdStr;
                listItem.listId = listIdStr;
                listItem.itemText = textStr;
                listItem.checked = checked;
                listItem.created = itemCreated;
                [arr addObject:listItem];
            }
        } else {
            const char * err = sqlite3_errmsg(_sqlite3db);
            NSLog(@"#%s:%d:Sqlite Error: %s", __FUNCTION__, __LINE__, err);
        }
        sqlite3_finalize(selectStatement);
        return arr;
    }
}

- (void) deleteListItemWithId: (NSString *) itemId {
    [self deleteItemWithId:itemId fromTable:kToDoListItemsTable primaryKey:@"id"];
}

- (void) deleteToDoListWithId: (NSString *) itemId {
    [self deleteItemWithId:itemId fromTable:kToDoListTable primaryKey:@"id"];
}

- (BOOL) deleteItemWithId:(NSString *)itemId fromTable:(NSString*)tableName primaryKey:(NSString*)primaryKey
{
    NSMutableString * sql = [NSMutableString stringWithFormat:@"DELETE FROM '%s' WHERE %s='%s'",[tableName UTF8String],[primaryKey UTF8String], [itemId UTF8String]];
    return (BOOL)[self execute:sql];
}

-(id) execute:(NSString*) sql{
    @synchronized (kDatabaseOperation) {
        sqlite3_stmt *statement = NULL;
        if (sqlite3_prepare_v2(_sqlite3db, [sql UTF8String], -1, &statement, NULL) != SQLITE_OK) {
            sqlite3_finalize(statement);
            @throw [NSException exceptionWithName:@"SQLiteHelper" reason:[NSString stringWithFormat: @"Failed to perform query with SQL statement. '%s'\nQuery:'%@'", sqlite3_errmsg16(_sqlite3db),sql] userInfo:nil];
        }
        NSMutableArray* records =  [[NSMutableArray alloc] init];
        int result=sqlite3_step(statement);
        while ( result == SQLITE_ROW) {
            NSMutableDictionary* record = [[NSMutableDictionary alloc]init];
            for (int i = 0; i <sqlite3_column_count(statement); i++) {
                [record setValue:[NSString stringWithUTF8String:(char *) sqlite3_column_text(statement, i)] forKey:[NSString stringWithUTF8String:(char *) sqlite3_column_name(statement, i)]];
            }
            [records addObject:record];
            result=sqlite3_step(statement);
        }
        if (result!=SQLITE_OK && result != SQLITE_DONE) {
            NSLog(@"Error code:%d - Error message: '%s'",result,sqlite3_errmsg(_sqlite3db));
            return [NSNumber numberWithBool:NO];
        }
        sqlite3_finalize(statement);
        return records;
    }
}

- (void) addDatabaseOperation: (NSInvocationOperation *) operation toQueue: (NSOperationQueue *) queue {
    [queue addOperation:operation];
    [operation setCompletionBlock:^{
        if ([self.databaseOperationQueue operationCount] == 0) {
            NSLog(@"All database operations complete.");
            if (self.delegate) {
                [self.delegate databaseReadWriteUpdateCompleted];
            }
        }
    }];
}

@end
