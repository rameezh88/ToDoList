//
//  ToDoListDataService.m
//  ToDoList
//
//  Created by Rameez Hussain on 28/10/15.
//  Copyright © 2015 Rameez Hussain. All rights reserved.
//

#import "ToDoListDataService.h"
#import "ToDoListDatabase.h"

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
    NSString *finalDatabasePath = [documentDBFolderPath stringByAppendingPathComponent:@"todolist.db"];
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
    NSString *finalDatabasePath = [documentDBFolderPath stringByAppendingPathComponent:@"todolist.db"];
    resourceDBFolderPath = [[NSBundle mainBundle] pathForResource:@"todolist" ofType:@"db"];
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

#pragma mark - ToDoListDelegate methods.

- (void) databaseReadWriteUpdateCompleted {
    
}


@end