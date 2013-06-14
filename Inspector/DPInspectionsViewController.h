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


@interface DPInspectionsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,NSFetchedResultsControllerDelegate, DPDamperStatusesViewControllerDelegate, DPDamperTypesViewControllerDelegate, DPNewInspectionTableViewControllerDelegate, DPPhotoCaptureViewControllerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UITextViewDelegate, DPDamperAirstreamViewControllerDelegate>
{
    BOOL _addingInspection;
    BOOL _takingOpenPhoto;
    BOOL _takingClosedPhoto;
    DPPhotoCaptureViewController *_photoController;
    UIImageView *photo;
    UIImageView *photo2;
}

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *addDamperButton;
@property (strong, nonatomic) IBOutlet UITableView *dampersTableView;
@property (assign, nonatomic) Job *job;
@property (assign, nonatomic) Inspection *selectedInspection;

@property (strong, nonatomic) NSMutableDictionary *damperCodes;
@property (strong, nonatomic) NSMutableDictionary *damperStatus;
@property (strong, nonatomic) NSMutableDictionary *damperAirstreams;

@property (strong, nonatomic) IBOutlet UIView *message;
@property (strong, nonatomic) IBOutlet UIView *form;
@property (strong, nonatomic) IBOutlet UITextField *building;
@property (strong, nonatomic) IBOutlet UITextField *floor;
@property (strong, nonatomic) IBOutlet UITextField *location;
@property (strong, nonatomic) IBOutlet UITextField *damper;
@property (strong, nonatomic) IBOutlet UIButton *damperTypeIdButton;
@property (strong, nonatomic) NSNumber *damperTypeId;
@property (strong, nonatomic) IBOutlet UIButton *damperStatusButton;
@property (strong, nonatomic) IBOutlet UIButton *imageButton;
@property (strong, nonatomic) NSNumber *damperStatusId;
@property (strong, nonatomic) IBOutlet UITextView *notes;
@property (strong, nonatomic) IBOutlet UIImageView *photo;

@property (strong, nonatomic) IBOutlet UIButton *damperAirstreamButton;
@property (strong, nonatomic) NSNumber *damperAirstreamValue;
@property (strong, nonatomic) IBOutlet UIImageView *photo2;
@property (strong, nonatomic) IBOutlet UILabel *tagLabel;
@property (strong, nonatomic) IBOutlet UITextField *unit;
@property (strong, nonatomic) IBOutlet UITextView *inspectorNotes;
@property (strong, nonatomic) IBOutlet UITextField *length;
@property (strong, nonatomic) IBOutlet UITextField *height;

- (IBAction)addDamperButtonSelected:(id)sender;
- (IBAction)pushDamperChangesButtonSelected:(id)sender;
- (IBAction)didSelectUpdateAll:(id)sender;
- (IBAction)didSelectFetchAll:(id)sender;

- (IBAction)didSelectOpenDamper:(id)sender;
- (IBAction)didSelectClosedDamper:(id)sender;
@end
