//
//  DPMasterViewController.h
//  Inspector
//
//  Created by Eddy Borja on 3/31/12.
//  Copyright (c) 2012 Badderjoy, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DPDetailViewController;

#import <CoreData/CoreData.h>

@interface DPMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) DPDetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
