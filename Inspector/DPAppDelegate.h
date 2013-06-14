//
//  DPAppDelegate.h
//  Inspector
//
//  Created by Eddy Borja on 3/31/12.
//  Copyright (c) 2012 Badderjoy, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DPLoginViewController;
@interface DPAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) DPLoginViewController *loginViewController;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
