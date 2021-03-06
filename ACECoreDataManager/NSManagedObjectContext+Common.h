// NSManagedObjectContext+Common.h
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

#import "ACECoreDataManager.h"

@interface NSManagedObjectContext (Common)

///-----------------------------------------------------------
/// @name Entity Descriptions Helpers
///-----------------------------------------------------------

/**
 Shortcut to return the entity description from a string
 
 @param entityName The name of the entity.
 */
- (NSEntityDescription *)entityWithName:(NSString *)entityName;

/**
 Returns the attribute marked as index for the selected entity
 
 @param entityName The name of the entity.
 */
- (NSAttributeDescription *)indexedAttributeForEntityName:(NSString *)entityName;

- (__kindof NSManagedObject *)safeObjectFromObject:(NSManagedObject *)object;


- (NSArray *)fetchAllObjectsForEntityName:(NSString *)entityName
                           sortDescriptor:(NSSortDescriptor *)sortDescriptor
                                    error:(NSError **)error;

- (NSArray *)fetchAllObjectsForEntityName:(NSString *)entityName
                          sortDescriptors:(NSArray *)sortDescriptors
                                    error:(NSError **)error;

- (__kindof NSManagedObject *)fetchObjectForEntityName:(NSString *)entityName
                                          withUniqueId:(id)uniqueId
                                                 error:(NSError **)error;

@end
