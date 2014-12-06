//
//  DPInspectionsViewController.h
//  Inspector
//
//  Created by Eddy Borja on 4/5/12.
//  Copyright (c) 2012 Mainloop, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Job.h"
#import "Inspection.h"
#import "DPDamperStatusesViewController.h"
#import "DPDamperTypesViewController.h"
#import "DPNewInspectionTableViewController.h"
#import "DPPhotoCaptureViewController.h"
#import "DPDamperAirstreamViewController.h"

enum{
    kIdentificationSection,
    kLocationSection,
    kInspectionSection,
    kNumberOfDamperDetailSections
};


@interface DPInspectionsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,NSFetchedResultsControllerDelegate,DPNewInspectionTableViewControllerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UITextViewDelegate>
{
    BOOL _addingInspection;
}

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) NSMutableDictionary *damperCodes;
@property (strong, nonatomic) NSMutableDictionary *damperStatus;
@property (strong, nonatomic) NSMutableDictionary *damperAirstreams;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *addDamperButton;
@property (strong, nonatomic) IBOutlet UITableView *dampersTableView;
@property (assign, nonatomic) Job *job;
@property (assign, nonatomic) Inspection *selectedInspection;

- (IBAction)didSelectUpdateAll:(id)sender;
- (IBAction)didSelectFetchAll:(id)sender;

@end
