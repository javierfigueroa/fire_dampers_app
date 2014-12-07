//
//  DPInspectionTableViewController.h
//  Inspector
//
//  Created by Javier Figueroa on 12/5/14.
//  Copyright (c) 2014 Mainloop, LLC. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "Job.h"
#import "Inspection.h"
#import "DPDamperTypesViewController.h"
#import "DPPhotoCaptureViewController.h"
#import "DPDamperAirstreamViewController.h"

@class DPLocalStorageFetcher;
@interface DPInspectionTableViewController : UITableViewController<DPDamperTypesViewControllerDelegate, DPDamperAirstreamViewControllerDelegate, DPPhotoCaptureViewControllerDelegate, UITextFieldDelegate>
{
    BOOL _takingOpenPhoto;
    BOOL _takingClosedPhoto;
    
    DPLocalStorageFetcher *_fetcherOpenPhoto;
    DPLocalStorageFetcher *_fetcherClosedPhoto;
}

@property (assign, nonatomic) Job *job;
@property (strong, nonatomic) Inspection *inspection;

@property (strong, nonatomic) NSMutableDictionary *damperCodes;
@property (strong, nonatomic) NSMutableDictionary *damperStatus;
@property (strong, nonatomic) NSMutableDictionary *damperAirstreams;

@property (strong, nonatomic) IBOutlet UITextField *building;
@property (strong, nonatomic) IBOutlet UITextField *floor;
@property (strong, nonatomic) IBOutlet UITextField *location;
@property (strong, nonatomic) IBOutlet UITextField *damper;
@property (strong, nonatomic) IBOutlet UILabel *damperTypeIdTextField;
@property (strong, nonatomic) NSNumber *damperTypeId;
@property (strong, nonatomic) NSNumber *damperStatusId;
@property (strong, nonatomic) IBOutlet UITextView *notes;
@property (strong, nonatomic) IBOutlet UILabel *inspectionDate;
@property (strong, nonatomic) IBOutlet UILabel *inspector;
@property (strong, nonatomic) IBOutlet UILabel *photoLabel;
@property (strong, nonatomic) IBOutlet UILabel *damperAirstreamTextField;
@property (strong, nonatomic) NSNumber *damperAirstreamId;
@property (strong, nonatomic) IBOutlet UILabel *photo2Label;
@property (strong, nonatomic) IBOutlet UITextField *unit;
@property (strong, nonatomic) IBOutlet UITextView *inspectorNotes;
@property (strong, nonatomic) IBOutlet UITextField *length;
@property (strong, nonatomic) IBOutlet UITextField *height;

@property (strong, nonatomic) IBOutlet UISegmentedControl *passFailControl;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

-(IBAction)didSelectStatusButton:(id)sender;
- (IBAction)didSelectDoneButton:(id)sender;
- (IBAction)didSelectBackButton:(id)sender;

@end
