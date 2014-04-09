//
//  ACECoreDataManager.m
//  ACECoreDataManagerDemo
//
//  Created by Stefano Acerbetti on 4/9/14.
//  Copyright (c) 2014 Aceland. All rights reserved.
//

#import "ACECoreDataManager.h"

@interface ACECoreDataManager ()
@property (strong, nonatomic) NSManagedObjectContext *privateWriterContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@end

@implementation ACECoreDataManager

@synthesize managedObjectContext = _managedObjectContext;

+ (instancetype)sharedManager
{
    static ACECoreDataManager *_instance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _instance = [[self alloc] init];
    });
    
    return _instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(saveContext)
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(saveContext)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(saveContext)
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillTerminateNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillResignActiveNotification
                                                  object:nil];
}


#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext == nil) {
        NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
        if (coordinator != nil) {
            
            // create the main context on the main thread
            _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
            
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0f) {
                // http://www.cocoanetics.com/2012/07/multi-context-coredata/
                _privateWriterContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
                [_privateWriterContext setPersistentStoreCoordinator:coordinator];
                
                // set the writer as a worker thread
                _managedObjectContext.parentContext = self.privateWriterContext;
                
            } else {
                // use just the main thread on iOS 5
                [_managedObjectContext setPersistentStoreCoordinator:coordinator];
            }
        }
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [self.delegate modelURLForManager:self];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [self.delegate storeURLForManager:self];
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSDictionary *options = @{
                              NSMigratePersistentStoresAutomaticallyOption: @YES,
                              NSInferMappingModelAutomaticallyOption: @YES
                              };
    
    NSError *error = nil;
    NSPersistentStore *persistentStore =
    [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                              configuration:nil
                                                        URL:storeURL
                                                    options:options
                                                      error:&error];
    if (persistentStore == nil) {
        NSLog(@"Error adding the persistent store: %@", error.localizedDescription);
        [[NSFileManager defaultManager] removeItemAtPath:storeURL.path error:&error];
        
        persistentStore =
        [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                  configuration:nil
                                                            URL:storeURL
                                                        options:options
                                                          error:&error];
    }
    return _persistentStoreCoordinator;
}


#pragma mark - Save

- (void)saveContext:(void (^)(NSError *error))errorBlock
{
    if ([self.managedObjectContext hasChanges]) {
        [self.managedObjectContext performBlock:^{
            
            NSError *error = nil;
            // save async the data in memory in the main thread
            if ([self.managedObjectContext save:&error]) {
                
                [self.privateWriterContext performBlock:^{
                    
                    NSError *error;
                    // save parent to disk asynchronously
                    if (![self.privateWriterContext save:&error] && errorBlock) {
                        errorBlock(error);
                    }
                }];
                
            } else if (errorBlock) {
                errorBlock(error);
            }
        }];
    }
}

- (void)saveContext
{
    [self saveContext:^(NSError *error) {
        NSLog(@"Error saving on disk: %@", error.localizedDescription);
    }];
}

@end
