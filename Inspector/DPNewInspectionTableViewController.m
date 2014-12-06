    //
//  DPNewInspectionTableViewController.m
//  Inspector
//
//  Created by Eddy Borja on 4/10/12.
//  Copyright (c) 2012 Mainloop, LLC. All rights reserved.
//

#import "DPNewInspectionTableViewController.h"
#import "DPInspection.h"
#import "Inspection.h"
#import "DPAppDelegate.h"
#import "SVProgressHUD.h"
#import "DPReachability.h"
#import "DPLocalStorageFetcher.h"
#import "UIImageView+WebCache.h"

@interface DPNewInspectionTableViewController ()

@end

@implementation DPNewInspectionTableViewController
@synthesize inspection;
@synthesize damperStatus;
@synthesize damperCodes;
@synthesize building;
@synthesize floor;
@synthesize location;
@synthesize damper;
@synthesize damperTypeIdTextField;
@synthesize notes;
@synthesize damperTypeId;
@synthesize damperStatusId;
@synthesize job;
@synthesize inspector;
@synthesize inspectionDate;
@synthesize photoLabel;
@synthesize passButton;
@synthesize failButton;
@synthesize delegate;
@synthesize passFailControl;


@synthesize damperAirstreamTextField;
@synthesize damperAirstreamId;
@synthesize unit;
@synthesize inspectorNotes;
@synthesize length;
@synthesize height;
@synthesize photo2Label;
@synthesize damperAirstreams;

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
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"DamperCodes" ofType:@"plist"];
    self.damperCodes = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    path = [[NSBundle mainBundle] pathForResource:@"DamperAirstream" ofType:@"plist"];
    self.damperAirstreams = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    self.inspector.text = [NSString stringWithFormat:@"%@ %@ - %@", [defaults valueForKey:@"first_name"], [defaults valueForKey:@"last_name"], [defaults valueForKey:@"email"]];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate new]];
    self.inspectionDate.text = dateString;
    
    self.damperStatusId = [NSNumber numberWithInt:2];
    
    self.damper.keyboardType = UIKeyboardTypeNumberPad;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _takingClosedPhoto = NO;
    _takingOpenPhoto = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{	
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)setInspectionFields
{
//    self.building.text = self.savedInspection.building;
//    self.floor.text =[NSString stringWithFormat:@"%@", self.savedInspection.floor];
//    self.damper.text = [NSString stringWithFormat:@"%@", self.savedInspection.damper];
//    self.location.text = inspection.location;
//    NSDictionary *type = [self.damperCodes objectForKey:[NSString stringWithFormat:@"%@", self.savedInspection.damperTypeId]];
//    self.damperTypeIdTextField.text = [type valueForKey:@"Abbrev"];
//    self.damperTypeId = inspection.damperTypeId;
//    
////    NSDictionary *status = [self.damperStatus objectForKey:[NSString stringWithFormat:@"%@", savedInspection.damperStatus]];
////    [damperStatusButton setTitle:[status valueForKey:@"Abbrev"] forState:UIControlStateNormal];
//    self.damperStatusId = self.savedInspection.damperStatus;
////    tagLabel.text = savedInspection.tag;
//    self.notes.text = self.savedInspection.notes;
//    self.inspectorNotes.text = self.savedInspection.inspectorNotes;
//    self.length.text = self.savedInspection.length;
//    self.height.text = self.savedInspection.height;
//    
//    self.unit.text = [NSString stringWithFormat:@"%@", self.savedInspection.unit];
//    
//    NSDictionary *stream = [self.damperAirstreams objectForKey:[NSString stringWithFormat:@"%@", savedInspection.damperAirstream]];
////    [damperAirstreamButton setTitle:[stream valueForKey:@"Abbrev"] forState:UIControlStateNormal];
////    damperAirstreamValue = savedInspection.damperAirstream;
//    self.damperTypeIdTextField.text = [stream valueForKey:@"Abbrev"];
//    
//    if ([savedInspection.sync boolValue] && savedInspection.localPhoto.length == 0) {
//        [photoView sd_setImageWithURL:[NSURL URLWithString:savedInspection.photo]];
//    }else if(savedInspection.localPhoto.length > 0) {
//        DPLocalStorageFetcher *fetcher = [[DPLocalStorageFetcher alloc]init];
//        fetcher.imageView = photoView;
//        [fetcher fetchStoredImageForKey:savedInspection.localPhoto];
//    }
//    
//    if ([savedInspection.sync boolValue] && savedInspection.localPhoto2.length == 0) {
//        [photoView2 sd_setImageWithURL:[NSURL URLWithString:savedInspection.photo2]];
//    }else if(savedInspection.localPhoto2.length > 0) {
//        DPLocalStorageFetcher *fetcher = [[DPLocalStorageFetcher alloc]init];
//        fetcher.imageView = photoView;
//        [fetcher fetchStoredImageForKey:savedInspection.localPhoto2];
//    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[DPDamperTypesViewController class]]) {
        DPDamperTypesViewController *damperTypesController = (DPDamperTypesViewController *) segue.destinationViewController;
        damperTypesController.checkedType = damperTypeId;
        damperTypesController.delegate = self;
    }else if([segue.destinationViewController isKindOfClass:[DPPhotoCaptureViewController class]]) {
        _photoController = (DPPhotoCaptureViewController *)segue.destinationViewController;
        _photoController.delegate = self;
    }else if([segue.destinationViewController isKindOfClass:[DPDamperAirstreamViewController class]]) {
        DPDamperAirstreamViewController *airstreamController = (DPDamperAirstreamViewController *)segue.destinationViewController;
        airstreamController.delegate = self;
        airstreamController.checkedType = damperAirstreamId;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0) {
        switch ([indexPath row]) {
            case 0:
                _takingOpenPhoto = YES;
                _photoController.image = photo;
                break;
            case 1:
                _takingClosedPhoto = YES;
                _photoController.image = photo2;
                break;
            default:
                break;
        }
    }
}

- (IBAction)didSelectDoneButton:(id)sender {
    
    if (   self.damperStatusId == 0
        || self.damperTypeId == 0
        || self.floor.text.length == 0
        || self.location.text.length == 0
        || self.building.text.length == 0
        || self.damper.text.length == 0 
        || self.unit.text.length == 0
        || self.length.text.length == 0 
        || self.height.text.length == 0
        || self.damperAirstreamTextField.text.length == 0) {
        
        [SVProgressHUD showErrorWithStatus:@"Please complete the entire form"];
        return;
    }
    
    
    self.inspection = [[DPInspection alloc]init];
    self.inspection.damperTypeId = [NSNumber numberWithInt:[self.damperTypeId intValue]];
    self.inspection.damperStatus = [NSNumber numberWithInt:[self.damperStatusId intValue]];
    self.inspection.damperAirstream = [NSNumber numberWithInt:[self.damperAirstreamId intValue]];
    
    NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
    self.inspection.floor =  [formatter numberFromString:floor.text];
    self.inspection.notes = self.notes.text;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.inspection.userId = [defaults valueForKey:@"user_id"];
    self.inspection.technicianId = [defaults valueForKey:@"technician_id"];
    self.inspection.location = self.location.text;
    self.inspection.building = self.building.text;
    self.inspection.inspected = [NSDate new];
    self.inspection.jobId = self.job.jobId;
    self.inspection.damper = [formatter numberFromString:self.damper.text];
    self.inspection.unit = [formatter numberFromString:self.unit.text];
    self.inspection.length = self.length.text;
    self.inspection.height = self.height.text;
    self.inspection.inspectorNotes = self.inspectorNotes.text;
    
    [SVProgressHUD showWithStatus:@"Adding Inspection" maskType:SVProgressHUDMaskTypeGradient];
    
    if ([[DPReachability sharedClient] online]) {
        [DPInspection addInspection:self.inspection withDamperPhotoOpen:photo withDamperPhotoClosed:photo2 withBlock:^(NSObject *response) {
            if ([response isKindOfClass:[NSError class]]) {
                [SVProgressHUD showErrorWithStatus:[(NSError*)response domain]];
            }else{
                [SVProgressHUD showSuccessWithStatus:@"Inspection Added"];
                if (delegate && [delegate respondsToSelector:@selector(didAddInspection)]) {
                    [delegate didAddInspection];
                }
                [self dismissViewControllerAnimated:YES completion:nil];
            }        
        }];
    }else{
        [self.inspection copyToManagedInspectionWithPhoto:photo andPhoto:photo2];
        [SVProgressHUD showErrorWithStatus:@"You're working offline, this inspection will be synced next time you get online"];
        if (delegate && [delegate respondsToSelector:@selector(didAddInspection)]) {
            [delegate didAddInspection];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }    
}

- (IBAction)didSelectCancelButton:(id)sender {
    
    if (delegate && [delegate respondsToSelector:@selector(didCancelInspection)]) {
        [delegate didCancelInspection];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)didSelectStatusButton:(id)sender
{
    UISegmentedControl *control = (UISegmentedControl *)sender;
    self.damperStatusId = [NSNumber numberWithInt:((int)control.selectedSegmentIndex + 1)];
}

#pragma mark - DPDamperStatusesDelegate Methods

- (void)didSelectDamperType:(NSNumber *)_damperTypeId
{    
    NSDictionary *type = [self.damperCodes objectForKey:[NSString stringWithFormat:@"%@", _damperTypeId]];
    damperTypeIdTextField.text = [type valueForKey:@"Abbrev"];
    damperTypeId = _damperTypeId;
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - DPDamperAirstream Delegate Methods

- (void)didSelectDamperAirstream:(NSNumber *)_damperAirstreamId
{    
    NSDictionary *type = [self.damperAirstreams objectForKey:[NSString stringWithFormat:@"%@", _damperAirstreamId]];
    damperAirstreamTextField.text = [type valueForKey:@"Abbrev"];
    damperAirstreamId = _damperAirstreamId;
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Photo Delegate

- (void)didCaptureImage:(UIImage *)image
{
    if (_takingOpenPhoto) {
        photo = image;
        self.photoLabel.text = @"Photo has been selected";
    }else if(_takingClosedPhoto) {
        photo2 = image;
        self.photo2Label.text = @"Photo has been selected";        
    }
}

@end
