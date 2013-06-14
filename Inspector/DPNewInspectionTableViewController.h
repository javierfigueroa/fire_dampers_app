//
//  DPNewInspectionTableViewController.h
//  Inspector
//
//  Created by Eddy Borja on 4/10/12.
//  Copyright (c) 2012 Mainloop, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Job.h"
#import "DPInspection.h"
#import "DPDamperTypesViewController.h"
#import "DPPhotoCaptureViewController.h"
#import "DPDamperAirstreamViewController.h"

@protocol DPNewInspectionTableViewControllerDelegate <NSObject>

- (void)didAddInspection;
- (void)didCancelInspection;

@end

@interface DPNewInspectionTableViewController : UITableViewController<DPDamperTypesViewControllerDelegate, DPPhotoCaptureViewControllerDelegate, DPDamperAirstreamViewControllerDelegate>
{
    BOOL _takingOpenPhoto;
    BOOL _takingClosedPhoto;
    DPPhotoCaptureViewController *_photoController;
    UIImage *photo;
    UIImage *photo2;
}

@property (assign, nonatomic) Job *job;
@property (strong, nonatomic) DPInspection *inspection;

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
@property (strong, nonatomic) IBOutlet UIButton *passButton;
@property (strong, nonatomic) IBOutlet UIButton *failButton;


@property (strong, nonatomic) IBOutlet UILabel *damperAirstreamTextField;
@property (strong, nonatomic) NSNumber *damperAirstreamId;
@property (strong, nonatomic) IBOutlet UILabel *photo2Label;
@property (strong, nonatomic) IBOutlet UITextField *unit;
@property (strong, nonatomic) IBOutlet UITextView *inspectorNotes;
@property (strong, nonatomic) IBOutlet UITextField *length;
@property (strong, nonatomic) IBOutlet UITextField *height;

@property (strong, nonatomic) IBOutlet UISegmentedControl *passFailControl;

@property (assign, nonatomic) id<DPNewInspectionTableViewControllerDelegate> delegate;


- (IBAction)didSelectDoneButton:(id)sender;
- (IBAction)didSelectCancelButton:(id)sender;
- (IBAction)didSelectStatusButton:(id)sender;

@end
