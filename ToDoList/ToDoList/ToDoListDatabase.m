//
//  ToDoListDatabaseManager.m
//  ToDoList
//
//  Created by Rameez Hussain on 28/10/15.
//  Copyright © 2015 Rameez Hussain. All rights reserved.
//

#import "ToDoListDatabase.h"
#import "sqlite3.h"

static const NSString *kDatabaseOperation = @"database_operation";

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

- (BOOL) deleteItemWithId:(NSInteger)itemId fromTable:(NSString*)tableName primaryKey:(NSString*)primaryKey
{
    NSMutableString * sql = [NSMutableString stringWithFormat:@"DELETE FROM '%s' WHERE %s='%ld'",[tableName UTF8String],[primaryKey UTF8String], (long)itemId];
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
