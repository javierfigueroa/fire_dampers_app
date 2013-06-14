//
//  DPJobsTableViewController.m
//  Inspector
//
//  Created by Eddy Borja on 4/10/12.
//  Copyright (c) 2012 Mainloop, LLC. All rights reserved.
//

#import "DPJobsTableViewController.h"
#import "DPApiClient.h"
#import "DPAppDelegate.h"
#import "Job.h"
#import "DPJob.h"
#import "DPInspectionsViewController.h"
#import "SVProgressHUD.h"
#import "DPReachability.h"


@interface DPJobsTableViewController ()

@end

@implementation DPJobsTableViewController
@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext = __managedObjectContext;


- (NSManagedObjectContext *)managedObjectContext{
    if(__managedObjectContext == nil){
        DPAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        [self setManagedObjectContext:appDelegate.managedObjectContext];
    }
    
    return __managedObjectContext;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"auth_token"] &&
        [[NSUserDefaults standardUserDefaults] valueForKey:@"user_id"] ) {
        [self didSelectGetNewJobsButton:nil];
    }else{
        [self didSelectLogoutButton:nil];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	
    return interfaceOrientation == UIInterfaceOrientationPortrait;
        
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"JobsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    

    // Configure the cell...
    Job *managedJob = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [cell.textLabel setText:managedJob.jobName];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UITableViewCell *cell = (UITableViewCell *)sender;
    if ([segue.destinationViewController isKindOfClass:[DPInspectionsViewController class]]) {
        DPInspectionsViewController *inspectionsController = (DPInspectionsViewController *) segue.destinationViewController;
        NSIndexPath *path = [self.tableView indexPathForCell:cell];
        inspectionsController.job = [self.fetchedResultsController.fetchedObjects objectAtIndex:[path row]];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}


#pragma mark - Interface Builder
//See https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/CoreData/Articles/cdImporting.html for guidelines related to importing data into core data efficiently
- (IBAction)didSelectGetNewJobsButton:(id)sender {
    if ([[DPReachability sharedClient] online]) {
        [SVProgressHUD showWithStatus:@"Downloading Jobs..."];
        [DPJob getJobsWithBlock:^(NSObject *response) {
            NSLog(@"%@", response);
            if([response isKindOfClass:[NSError class]]) {
                [self didSelectLogoutButton:nil];
            }
            
            [SVProgressHUD dismissWithSuccess:@"Jobs updated"];
        }];
    }else{
        [SVProgressHUD showWithStatus:@"You're working offline" maskType:SVProgressHUDMaskTypeNone];        
        [SVProgressHUD dismissWithError:@"You're work will be sync when you get back online" afterDelay:2];
    }
}

- (void)didSelectLogoutButton:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kUserDidLogoutNotification object:nil];
    
//    NSError *error;
//    for (Job *message in [self.fetchedResultsController fetchedObjects]) {
//        [self.managedObjectContext deleteObject:message];
//    }
//    
//    if (![self.managedObjectContext save:&error]) {
//        NSLog(@"Delete message error %@, %@", error, [error userInfo]);
//    }

}


#pragma mark - Core Data Stack


- (NSFetchedResultsController *)fetchedResultsController
{
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Job" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startDate" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
//    NSNumber *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userId == %@", userId];
//    [fetchRequest setPredicate:predicate];
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return __fetchedResultsController;
}    



#pragma mark - FetchedResultsController Delegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}

@end
