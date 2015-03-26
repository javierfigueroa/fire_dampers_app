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
    return [NSManagedObjectContext MR_defaultContext];
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
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"username"] &&
        [[NSUserDefaults standardUserDefaults] valueForKey:@"password"] ) {
    [self didSelectGetNewJobsButton:nil];
    }
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kUserDidLoginNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self didSelectGetNewJobsButton:nil];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (![[NSUserDefaults standardUserDefaults] valueForKey:@"username"] ||
        ![[NSUserDefaults standardUserDefaults] valueForKey:@"password"] ) {
        [self logout];
    }
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
        [SVProgressHUD showWithStatus:@"Downloading jobs" maskType:SVProgressHUDMaskTypeGradient];
        [DPJob getJobsWithBlock:^(NSObject *response) {
            __fetchedResultsController = nil;
            [self.fetchedResultsController performFetch:nil];
            NSLog(@"%@", response);
            [SVProgressHUD dismiss];
            [self.tableView reloadData];
        }];
    }else{
        [SVProgressHUD showSuccessWithStatus:@"You're working offline"];
        [self.tableView reloadData];
    }
}

- (void)didSelectLogoutButton:(id)sender
{
    //if ipad
    
    // Override point for customization after application launch
    if (IPAD) {
        UIAlertAction *actionDelete = nil;
        UIAlertAction *actionCancel = nil;
        
        // create action sheet
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:nil message:nil
                                              preferredStyle:UIAlertControllerStyleActionSheet];
        
        // Delete Button
        actionDelete = [UIAlertAction
                        actionWithTitle:@"Sign out"
                        style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                            [self logout];
                        }];
        
        // Cancel Button
        actionCancel = [UIAlertAction
                        actionWithTitle:@"Cancel"
                        style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                            // cancel
                        }];
        
        // Add Cancel action
        [alertController addAction:actionCancel];
        [alertController addAction:actionDelete];
        
        // show action sheet
        alertController.popoverPresentationController.barButtonItem = self.navigationItem.leftBarButtonItem;
        alertController.popoverPresentationController.sourceView = self.view;
        
        [self presentViewController:alertController animated:YES
                         completion:nil];
    }else{
         [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Sign out" otherButtonTitles:nil] showInView:self.view];
    }
}

- (void)logout
{
    __fetchedResultsController = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:kUserDidLogoutNotification object:nil];
}

#pragma mark - Core Data Stack


- (NSFetchedResultsController *)fetchedResultsController
{
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *companyId = [defaults valueForKey:@"company_id"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"companyId == %@", companyId];
    __fetchedResultsController = [Job MR_fetchAllSortedBy:@"jobId" ascending:NO withPredicate:predicate groupBy:nil delegate:self];

    return __fetchedResultsController;
}

#pragma mark - FetchedResultsController Delegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}

#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self logout];
            break;
            
        default:
            break;
    }
}

@end
