//
//  DPJobsTableViewController.h
//  Inspector
//
//  Created by Eddy Borja on 4/10/12.
//  Copyright (c) 2012 Mainloop, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Job;
@interface DPJobsTableViewController : UITableViewController <NSFetchedResultsControllerDelegate>


@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


- (IBAction)didSelectGetNewJobsButton:(id)sender;
- (IBAction)didSelectLogoutButton:(id)sender;

@end
