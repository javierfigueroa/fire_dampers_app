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
#import "DPLocalStorageFetcher.h"
#import "DPInspectionTableViewController.h"

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
    if(__managedObjectContext == nil){
        DPAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        [self setManagedObjectContext:appDelegate.managedObjectContext];
    }
    
    return __managedObjectContext;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)syncInspection:(Inspection *)inspection {
    DPLocalStorageFetcher *fetcherOpenPhoto = [[DPLocalStorageFetcher alloc]init];
    DPLocalStorageFetcher *fetcherClosedPhoto = [[DPLocalStorageFetcher alloc]init];
    
    if (inspection.localPhoto.length > 0) {
        [fetcherOpenPhoto fetchStoredImageForKey:inspection.localPhoto];
    }
    
    if (inspection.localPhoto2.length > 0) {
        [fetcherClosedPhoto fetchStoredImageForKey:inspection.localPhoto2];
    }
    
    if (inspection.inspectionId && inspection.inspectionId > 0) {
        [DPInspection updateInspection:inspection withDamperPhotoOpen:fetcherOpenPhoto.image  withDamperPhotoClosed:fetcherClosedPhoto.image withBlock:^(NSObject *response) {
            if ([response isKindOfClass:[NSError class]]) {
                [SVProgressHUD showErrorWithStatus:[(NSError *)response localizedDescription]];
            }else{
                [SVProgressHUD showSuccessWithStatus:@"Inspection Updated"];
            }        
        }];
    }else{
        
        DPInspection *DPinspection = [[DPInspection alloc]init];
        DPinspection.damperTypeId = [NSNumber numberWithInt:[inspection.damperTypeId intValue]];
        DPinspection.damperStatus = [NSNumber numberWithInt:[inspection.damperStatus intValue]];
        DPinspection.damperAirstream = [NSNumber numberWithInt:[inspection.damperAirstream intValue]];
        
        DPinspection.floor =  inspection.floor;
        DPinspection.notes = inspection.notes;
        DPinspection.unit = inspection.unit;
        DPinspection.userId = inspection.userId;
        DPinspection.technicianId = inspection.technicianId;
        DPinspection.location = inspection.location;
        DPinspection.building = inspection.building;
        DPinspection.inspected = inspection.inspected;
        DPinspection.jobId = inspection.jobId;
        DPinspection.inspectorNotes = inspection.inspectorNotes;
        DPinspection.length = inspection.length;
        DPinspection.height = inspection.height;
        DPinspection.damper = [NSNumber numberWithInt:[inspection.damper intValue]];
        
        [DPInspection addInspection:DPinspection withDamperPhotoOpen:fetcherOpenPhoto.image withDamperPhotoClosed:fetcherClosedPhoto.image withBlock:^(NSObject *response) {
            if ([response isKindOfClass:[NSError class]]) {
                [SVProgressHUD showErrorWithStatus:[(NSError*)response localizedDescription]];
            }else{                
                inspection.sync = [NSNumber numberWithBool:YES];
                [SVProgressHUD showSuccessWithStatus:@"Inspection Added"];
            }        
        }];
    }
}

- (NSArray *)fetchedUnsyncInspections
{
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Inspection" 
                                              inManagedObjectContext:self.managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];          
    
    NSPredicate *predicate = [NSComparisonPredicate predicateWithLeftExpression:[NSExpression expressionForKeyPath:@"jobId"] rightExpression:[NSExpression expressionForConstantValue:self.job.jobId]  modifier:NSDirectPredicateModifier type:NSEqualToPredicateOperatorType options:0];
    [request setPredicate:predicate];
    
    NSError *error =nil;
    NSArray *array = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    return error == nil ? array : nil;
}

- (void)updateInspections
{
    NSArray *array =  [self fetchedUnsyncInspections];
    
    if (array) {
        BOOL needsUpdate = NO;
        [SVProgressHUD showWithStatus:@"Updating inspections" maskType:SVProgressHUDMaskTypeGradient];
        for (Inspection *inspection in array) {
            if (![inspection.sync boolValue]) {
                NSLog(@"%@", inspection);
                needsUpdate = YES;
                [self syncInspection:inspection];
            }
        }
        
        if (!needsUpdate) {
            [SVProgressHUD showSuccessWithStatus:@"Nothing to update"];
        }
    }
}

- (void)fetchInspections
{
        if ([[DPReachability sharedClient] online]) {     
            
            NSArray *array =  [self fetchedUnsyncInspections];
            BOOL needsUpdate = NO;
            if (array) {
                for (Inspection *inspection in array) {
                    if (inspection.inspectionId && inspection.inspectionId > 0 && ![inspection.sync boolValue]) {
                        needsUpdate = YES;
                    }
                }
            }

            
            if (needsUpdate) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sync Needed" message:@"Please sync all inspection before continuing" delegate:self cancelButtonTitle:@"Later" otherButtonTitles:@"Sync All", nil];
                [alert show];                
            }else{
                [SVProgressHUD showWithStatus:@"Getting inspections..." maskType:SVProgressHUDMaskTypeGradient];
                [DPInspection getInspectionsForJobId:self.job.jobId withBlock:^(NSObject *response) {
                    if ([response isKindOfClass:[NSError class]]) {
                        [SVProgressHUD showErrorWithStatus:[(NSError *)response localizedDescription]];
                    }else{
                        [SVProgressHUD dismiss];
                        
                        NSError *error = nil;
                        NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
                        if (managedObjectContext != nil) {
                            if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
                                // Replace this implementation with code to handle the error appropriately.
                                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                            }
                        }
                    }       
                }];
            }
        }else {
            [self.dampersTableView reloadData];
            [SVProgressHUD showSuccessWithStatus:@"You're working offline"];
        }
}

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
    _addingInspection = NO;
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
    }
}

- (void)didSelectFetchAll:(id)sender
{
    [self fetchInspections];
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
        _addingInspection = YES;
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    NSString *sectionTitle = nil;

    
    Inspection *inspection = (Inspection *)[self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
    return [NSString stringWithFormat:NSLocalizedString(@"Floor %@", @"A section title that indications a particular floor number"), inspection.floor];

    NSAssert(sectionTitle != nil, @"Could not get a title for a section!");
    
    return sectionTitle;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.dampersTableView) {
        // Return the number of rows in the section.
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    }

    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *DamperInspectionCellIdentifier = @"DamperInspectionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DamperInspectionCellIdentifier forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}  


- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
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
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Inspection" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"floor" ascending:YES];
    NSSortDescriptor *sortDescriptor2 = [[NSSortDescriptor alloc] initWithKey:@"damper" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, sortDescriptor2, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"jobId == %@", self.job.jobId];
    [fetchRequest setPredicate:predicate];
    
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"floor" cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//	    abort();
	}
    
    return __fetchedResultsController;
}    



#pragma mark - FetchedResultsController Delegate

//- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
//{
//    // In the simplest, most efficient, case, reload the table view.
//    [self.dampersTableView reloadData];
//}


#pragma mark - NSFetchedResultsControllerDelegate methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.dampersTableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.dampersTableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeUpdate:{
            UITableViewCell *cell = [self.dampersTableView cellForRowAtIndexPath:indexPath];
            [self configureCell:cell atIndexPath:indexPath];
//            [cell setNeedsLayout];
//            [dampersTableView  reloadData];
            break;
        }
        case NSFetchedResultsChangeMove:
            // Reloading the section inserts a new row and ensures that titles are updated appropriately.
            [tableView reloadSections:[NSIndexSet indexSetWithIndex:newIndexPath.section] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.dampersTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.dampersTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeMove:
        case NSFetchedResultsChangeUpdate:
            default:
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.dampersTableView endUpdates];
}

#pragma mark - DPNewDamperController Delegate

- (void)didAddInspection
{
    _addingInspection = NO;
    [self fetchInspections];
}

 -(void)didCancelInspection
{
    _addingInspection = NO;
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
