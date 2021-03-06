// ACECoreDataManager.h
//
// Copyright (c) 2014 Stefano Acerbetti
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

#import "NSManagedObjectContext+Common.h"
#import "NSManagedObjectContext+CRUD.h"
#import "NSManagedObjectContext+JSON.h"

@class ACECoreDataManager;

@protocol ACECoreDataDelegate <NSObject>

@required
- (NSURL *)modelURLForManager:(ACECoreDataManager *)manager;
- (NSURL *)storeURLForManager:(ACECoreDataManager *)manager; // return nil for in memory storage

@optional
- (void)coreDataManager:(ACECoreDataManager *)manager didFailOperationWithError:(NSError *)error;

@end

#pragma mark -

@interface ACECoreDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (assign, nonatomic) BOOL useBackgroundWriter; // default YES
@property (weak, nonatomic) id<ACECoreDataDelegate> delegate;

// context
- (void)saveContext;
- (void)deleteContext;

// atomic updates
- (void)beginUpdates;
- (void)endUpdates;

// temporary context
- (void)performOperation:(void (^)(NSManagedObjectContext *temporaryContext))actionBlock completeBlock:(dispatch_block_t)completeBlock;

// singleton
+ (instancetype)sharedManager;

@end
