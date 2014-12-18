//
//  DPInspectionsViewController.m
//  Inspector
//
//  Created by Eddy Borja on 4/5/12.
//  Copyright (c) 2012 Mainloop, LLC. All rights reserved.
//

#import "DPInspectionsViewController.h"
#import "DPInspection.h"
#import "DPAppDelegate.h"
#import "Inspection.h"
#import "DPInspectionCell.h"
#import "DPDamperStatusesViewController.h"
#import "UIImageView+WebCache.h"
#import "DPReachability.h"
#import "SVProgressHUD.h"
#import "DPInspectionTableViewController.h"
#import "SDImageCache.h"

@interface DPInspectionsViewController ()

@end

@implementation DPInspectionsViewController
@synthesize dampersTableView;
@synthesize job;
@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize selectedInspection;
@synthesize addDamperButton;
@synthesize damperStatus;
@synthesize damperCodes;

- (NSManagedObjectContext *)managedObjectContext{
    return [NSManagedObjectContext MR_defaultContext];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - API calls

- (void)syncInspection:(Inspection *)inspection {
    [[SDImageCache sharedImageCache] queryDiskCacheForKey:inspection.localPhoto done:^(UIImage *photo, SDImageCacheType cacheType) {
        [[SDImageCache sharedImageCache] queryDiskCacheForKey:inspection.localPhoto2 done:^(UIImage *photo2, SDImageCacheType cacheType) {
            if (inspection.inspectionId && inspection.inspectionId > 0) {
                [DPInspection updateInspection:inspection withDamperPhotoOpen:photo  withDamperPhotoClosed:photo2 withBlock:^(NSObject *response) {
                    if ([response isKindOfClass:[NSError class]]) {
                        [SVProgressHUD showErrorWithStatus:[(NSError *)response localizedDescription]];
                    }else{
                        [SVProgressHUD showSuccessWithStatus:@"Inspection Updated"];
                    }
                }];
            }else{                
                [DPInspection addInspection:inspection withDamperPhotoOpen:photo withDamperPhotoClosed:photo2 withBlock:^(NSObject *response) {
                    if ([response isKindOfClass:[NSError class]]) {
                        [SVProgressHUD showErrorWithStatus:[(NSError*)response localizedDescription]];
                    }else{
                        inspection.inspectionId = [response valueForKey:@"id"];
                        inspection.sync = [NSNumber numberWithBool:YES];
                        [SVProgressHUD showSuccessWithStatus:@"Inspection Added"];
                    }        
                }];
            }
        }];
    }];
}

- (void)updateInspections
{
    if ([[DPReachability sharedClient] online]) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@ && sync = NO", @"jobId", self.job.jobId];
        NSFetchRequest *fetchRequest = [Inspection MR_requestAllWithPredicate:predicate];
        NSArray *array = [Inspection MR_executeFetchRequest:fetchRequest];
        if (array.count > 0) {
            [SVProgressHUD showWithStatus:@"Updating inspections" maskType:SVProgressHUDMaskTypeGradient];
            for (Inspection *inspection in array) {
                NSLog(@"%@", inspection);
                [self syncInspection:inspection];
            }
        }
    }else {
        [self.dampersTableView reloadData];
        [SVProgressHUD showSuccessWithStatus:@"You're working offline"];
    }
}

- (void)fetchInspections
{
    if ([[DPReachability sharedClient] online]) {
        [SVProgressHUD showWithStatus:@"Downloading inspections" maskType:SVProgressHUDMaskTypeGradient];
        [DPInspection getInspectionsForJobId:self.job.jobId withBlock:^(NSObject *response) {
            if ([response isKindOfClass:[NSError class]]) {
                [SVProgressHUD showErrorWithStatus:[(NSError *)response localizedDescription]];
            }else{
                [SVProgressHUD dismiss];
                [MagicalRecord saveWithBlock:nil];
            }       
        }];
    }else {
        [self.dampersTableView reloadData];
        [SVProgressHUD showSuccessWithStatus:@"You're working offline"];
    }
}

#pragma mark - View Cycle Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"DamperStatus" ofType:@"plist"];
    self.damperStatus = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    path = [[NSBundle mainBundle] pathForResource:@"DamperCodes" ofType:@"plist"];
    self.damperCodes = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    path = [[NSBundle mainBundle] pathForResource:@"DamperAirstream" ofType:@"plist"];
    self.damperAirstreams = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    self.title = self.job.jobName;
    [self fetchInspections];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.dampersTableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.fetchedResultsController = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{	
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

#pragma mark - IB Actions

- (void)didSelectUpdateAll:(id)sender
{
    if ([[DPReachability sharedClient] online]) {             
        [self updateInspections];
    }else{
        [SVProgressHUD showSuccessWithStatus:@"You're working offline, try syncing once you're back online"];
    }
}

- (void)didSelectFetchAll:(id)sender
{
    if ([[DPReachability sharedClient] online]) {
        [self updateInspections];
        [self fetchInspections];
    }else{
        [SVProgressHUD showSuccessWithStatus:@"You're working offline, try syncing once you're back online"];
    }
}

#pragma mark - Table View


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UINavigationController *controller = (UINavigationController *) segue.destinationViewController;
    if ([controller isKindOfClass:[DPInspectionTableViewController class]]) {
        DPInspectionTableViewController *newController = (DPInspectionTableViewController *)controller;
        newController.job = self.job;
        newController.inspection = self.selectedInspection;
    }else if ([controller.visibleViewController isKindOfClass:[DPNewInspectionTableViewController class]]) {
        DPNewInspectionTableViewController *newController = (DPNewInspectionTableViewController *)controller.visibleViewController;
        newController.job = self.job;
        newController.delegate = self;
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    Inspection *inspection = (Inspection *)[self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    return [NSString stringWithFormat:NSLocalizedString(@"Floor %@", @"A section title that indications a particular floor number"), inspection.floor];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
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
    static NSString *DamperInspectionCellIdentifier = @"DamperInspectionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DamperInspectionCellIdentifier forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Inspection *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self.managedObjectContext deleteObject:object];
        [MagicalRecord saveWithBlock:nil];

    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    Inspection *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return (!object.inspectionId || object.inspectionId == 0);
}  


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

-(void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Inspection *inspection = (Inspection *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    self.selectedInspection = inspection;
    return indexPath;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[DPInspectionCell class]]) {
        Inspection *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
        DPInspectionCell *inspectionCell = (DPInspectionCell *)cell;
        inspectionCell.damperId.text = [NSString stringWithFormat:@"Damper: %@", object.damper];
        
        NSDictionary *type = [self.damperCodes objectForKey:[NSString stringWithFormat:@"%@", object.damperTypeId]];
        inspectionCell.damperType.text = [NSString stringWithFormat:@"Type: %@", [type valueForKey:@"Abbrev"]];
        
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString *dateString = [dateFormatter stringFromDate:object.inspected];
        
        inspectionCell.comments.text = [NSString stringWithFormat:@"Inspected on: %@", dateString];
        
        NSDictionary *damperState = [self.damperStatus objectForKey:[NSString stringWithFormat:@"%@", object.damperStatus]];
        inspectionCell.status.text = [NSString stringWithFormat:@"Inspection Result: %@", [damperState valueForKey:@"Abbrev"]];
        
        if ([object.sync boolValue]) {
            inspectionCell.syncState.textColor = [UIColor greenColor];
            inspectionCell.syncState.text = @"Synced";
        }else {
            inspectionCell.syncState.textColor = [UIColor orangeColor];
            inspectionCell.syncState.text = @"Needs Sync";
        }
        
        if ((!object.inspectionId || object.inspectionId == 0) && ![object.sync boolValue]) {
            inspectionCell.syncState.textColor = [UIColor redColor];
            inspectionCell.syncState.text = @"Not Synced";
        }
    }
}


#pragma mark - Core Data Stack

- (NSFetchedResultsController *)fetchedResultsController
{
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"jobId == %@", self.job.jobId];
    __fetchedResultsController = [Inspection MR_fetchAllSortedBy:@"floor,damper" ascending:YES withPredicate:predicate groupBy:@"floor" delegate:self];
    
    return __fetchedResultsController;
}



#pragma mark - FetchedResultsController Delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.dampersTableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.dampersTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.dampersTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:
            break;
        case NSFetchedResultsChangeUpdate:
            [self.dampersTableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationNone];
            default:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.dampersTableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath]
                    atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.dampersTableView endUpdates];
}

#pragma mark - DPNewDamperController Delegate

- (void)didAddInspection
{
    [self updateInspections];
}

 -(void)didCancelInspection
{
    
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self updateInspections];
    }
}

#pragma mark - UITextField Delegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
}

@end
