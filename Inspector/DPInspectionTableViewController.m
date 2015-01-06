//
//  DPInspectionTableViewController.m
//  Inspector
//
//  Created by Javier Figueroa on 12/5/14.
//  Copyright (c) 2014 Mainloop, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DPInspectionTableViewController.h"
#import "DPAppDelegate.h"
#import "SVProgressHUD.h"
#import "DPReachability.h"
#import "SDImageCache.h"
#import "UIImageView+WebCache.h"
#import "DPInspection.h"
#import "SDWebImageManager.h"
#import <APNumberPad/APNumberPad.h>

@interface DPInspectionTableViewController ()

@end

@implementation DPInspectionTableViewController
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
@synthesize passFailControl;
@synthesize damperAirstreamTextField;
@synthesize damperAirstreamId;
@synthesize unit;
@synthesize inspectorNotes;
@synthesize length;
@synthesize height;
@synthesize photo2Label;
@synthesize damperAirstreams;
@synthesize tagTextField;

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
    [self setInspectionFields];
    
    _takingOpenPhoto = NO;
    _takingClosedPhoto = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    self.length.inputView = ({
        APNumberPad *numberPad = [APNumberPad numberPadWithDelegate:nil];
        numberPad;
    });
    
    self.height.inputView = ({
        APNumberPad *numberPad = [APNumberPad numberPadWithDelegate:nil];
        numberPad;
    });
    
    self.unit.inputView = ({
        APNumberPad *numberPad = [APNumberPad numberPadWithDelegate:nil];
        numberPad;
    });
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self validateForm];
    [self updateInspection];
    [super viewWillDisappear:animated];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)keyboardWasShown:(NSNotification *)notification
{
    self.inspection.sync = [NSNumber numberWithBool:NO];
}

- (void)setInspectionFields
{
    self.title = self.inspection.tag;
    self.building.text = self.inspection.building;
    self.floor.text =[NSString stringWithFormat:@"%@", self.inspection.floor];
    self.damper.text = [NSString stringWithFormat:@"%@", self.inspection.damper];
    self.location.text = inspection.location;
    NSDictionary *type = [self.damperCodes objectForKey:[NSString stringWithFormat:@"%@", self.inspection.damperTypeId]];
    self.damperTypeIdTextField.text = [type valueForKey:@"Abbrev"];
    self.damperTypeId = inspection.damperTypeId;
    self.tagTextField.text = self.inspection.tag;
    self.damperStatusId = self.inspection.damperStatus;
    self.notes.text = self.inspection.notes;
    self.inspectorNotes.text = self.inspection.inspectorNotes;
    self.length.text = self.inspection.length;
    self.height.text = self.inspection.height;
    if (self.inspection.unit  != nil) {
        self.unit.text = [NSString stringWithFormat:@"%@", self.inspection.unit];
    }

    NSDictionary *stream = [self.damperAirstreams objectForKey:[NSString stringWithFormat:@"%@", inspection.damperAirstream]];
    self.damperAirstreamTextField.text = [stream valueForKey:@"Abbrev"];
    self.damperAirstreamId = self.inspection.damperAirstream;
    
    self.damperStatusId = [NSNumber numberWithInt:[self.inspection.damperStatus intValue]];
    self.passFailControl.selectedSegmentIndex = [self.damperStatusId integerValue] - 1;

    if(self.inspection.localPhoto.length > 0) {
        self.photoLabel.text = @"Photo selected";
    }else if (self.inspection.photo.length > 0) {
        self.photoLabel.text = @"Photo selected";
    }
    
    if(self.inspection.localPhoto2.length > 0) {
        self.photo2Label.text = @"Photo selected";
    }else if (self.inspection.photo2.length > 0) {
        self.photo2Label.text = @"Photo selected";
    }
}

- (void) updateInspection
{
    NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
    inspection.damper = [formatter numberFromString:damper.text];
    inspection.damperStatus = [NSNumber numberWithInt:[damperStatusId intValue]];
    inspection.damperTypeId = [NSNumber numberWithInt:[damperTypeId intValue]];
    inspection.location = location.text;
    inspection.notes = notes.text;
    inspection.building = building.text;
    inspection.damperAirstream = [NSNumber numberWithInt:[damperAirstreamId intValue]];
    inspection.unit = [formatter numberFromString:[unit text]];
    inspection.inspectorNotes = inspectorNotes.text;
    inspection.length = length.text;
    inspection.height = height.text;
    inspection.tag = tagTextField.text;
    
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:nil completion:nil];
}

- (BOOL)validateForm
{
    if (   self.damperStatusId == 0
        || self.damperTypeId == 0
        || self.floor.text.length == 0
        || self.location.text.length == 0
        || self.building.text.length == 0
        || self.damper.text.length == 0
        || self.length.text.length == 0
        || self.height.text.length == 0
        || self.damperAirstreamTextField.text.length == 0) {
        
        [SVProgressHUD showErrorWithStatus:@"Please complete the entire form"];
        return NO;
    }
    
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[DPDamperTypesViewController class]]) {
        DPDamperTypesViewController *damperTypesController = (DPDamperTypesViewController *) segue.destinationViewController;
        damperTypesController.checkedType = damperTypeId;
        damperTypesController.delegate = self;
    }else if([segue.destinationViewController isKindOfClass:[DPDamperAirstreamViewController class]]) {
        DPDamperAirstreamViewController *airstreamController = (DPDamperAirstreamViewController *)segue.destinationViewController;
        airstreamController.delegate = self;
        airstreamController.checkedType = damperAirstreamId;
    }else if([segue.destinationViewController isKindOfClass:[DPPhotoCaptureViewController class]]) {
        DPPhotoCaptureViewController *photoController = (DPPhotoCaptureViewController *)segue.destinationViewController;
        photoController.delegate = self;
        
        if (_takingOpenPhoto) {
            if(inspection.localPhoto.length > 0) {
                photoController.imageKey = inspection.localPhoto;
            }else if (inspection.photo.length > 0) {
                photoController.imageUrl = [NSURL URLWithString:inspection.photo];
            }
        }else{
            if(inspection.localPhoto2.length > 0) {
                photoController.imageKey = inspection.localPhoto2;
            }else if (inspection.photo2.length > 0) {
                photoController.imageUrl = [NSURL URLWithString:inspection.photo2];
            }
        }
    }
}

#pragma mark - Table view delegate

- (NSIndexPath*)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _takingOpenPhoto = NO;
    _takingClosedPhoto = NO;
    
    if ([indexPath section] == 0) {
        switch ([indexPath row]) {
            case 0:
                _takingOpenPhoto = YES;
                break;
            case 1:
                _takingClosedPhoto = YES;
                break;
            default:
                break;
        }
    }
    
    return indexPath;
}

- (IBAction)didSelectDoneButton:(id)sender {
   
    if ([self validateForm]) {
    
        [SVProgressHUD showWithStatus:@"Saving" maskType:SVProgressHUDMaskTypeGradient];
        
        self.inspection.damperTypeId = [NSNumber numberWithInt:[self.damperTypeId intValue]];
        self.inspection.damperStatus = [NSNumber numberWithInt:[self.damperStatusId intValue]];
        self.inspection.damperAirstream = [NSNumber numberWithInt:[self.damperAirstreamId intValue]];
        
        NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
        self.inspection.floor =  [formatter numberFromString:floor.text];
        self.inspection.notes = self.notes.text;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.inspection.userId = [defaults valueForKey:@"user_id"];
        self.inspection.location = self.location.text;
        self.inspection.building = self.building.text;
        self.inspection.inspected = [NSDate new];
        self.inspection.jobId = self.job.jobId;
        self.inspection.damper = [formatter numberFromString:self.damper.text];
        self.inspection.unit = [formatter numberFromString:self.unit.text];
        self.inspection.length = self.length.text;
        self.inspection.height = self.height.text;
        self.inspection.inspectorNotes = self.inspectorNotes.text;
        self.inspection.tag = self.tagTextField.text;
        
        [self updateInspection];
        
        if ([[DPReachability sharedClient] online]) {
            [[SDImageCache sharedImageCache] queryDiskCacheForKey:self.inspection.localPhoto done:^(UIImage *photo, SDImageCacheType cacheType) {
                [[SDImageCache sharedImageCache] queryDiskCacheForKey:self.inspection.localPhoto2 done:^(UIImage *photo2, SDImageCacheType cacheType) {
                    if (inspection.inspectionId && inspection.inspectionId > 0) {
                        [DPInspection updateInspection:inspection withDamperPhotoOpen:photo  withDamperPhotoClosed:photo2 withBlock:^(NSObject *response) {
                            if ([response isKindOfClass:[NSError class]]) {
                                [SVProgressHUD showErrorWithStatus:[(NSError *)response localizedDescription]];
                            }else{
                                [SVProgressHUD showSuccessWithStatus:@"Inspection updated"];
                                [self.navigationController popViewControllerAnimated:YES];
                            }
                        }];
                    }else{
                        [DPInspection addInspection:self.inspection withDamperPhotoOpen:photo withDamperPhotoClosed:photo2 withBlock:^(NSObject *response) {
                            if ([response isKindOfClass:[NSError class]]) {
                                [SVProgressHUD showErrorWithStatus:[(NSError*)response localizedDescription]];
                            }else{
                                [SVProgressHUD showSuccessWithStatus:@"Inspection added"];
                                [self.navigationController popViewControllerAnimated:YES];
                            }        
                        }];
                    }
                }];
            }];
        }else{
            [SVProgressHUD showErrorWithStatus:@"You're working offline, this inspection will be synced next time you get online"];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

-(void)didSelectStatusButton:(id)sender
{
    UISegmentedControl *control = (UISegmentedControl *)sender;
    self.damperStatusId = [NSNumber numberWithInt:((int)control.selectedSegmentIndex + 1)];
    self.inspection.sync = [NSNumber numberWithBool:NO];
}

- (void)didSelectBackButton:(id)sender
{
    if ([self validateForm]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - DPDamperStatusesDelegate Methods

- (void)didSelectDamperType:(NSNumber *)_damperTypeId
{
    NSDictionary *type = [self.damperCodes objectForKey:[NSString stringWithFormat:@"%@", _damperTypeId]];
    damperTypeIdTextField.text = [type valueForKey:@"Abbrev"];
    damperTypeId = _damperTypeId;
    self.inspection.sync = [NSNumber numberWithBool:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - DPDamperAirstream Delegate Methods

- (void)didSelectDamperAirstream:(NSNumber *)_damperAirstreamId
{
    NSDictionary *type = [self.damperAirstreams objectForKey:[NSString stringWithFormat:@"%@", _damperAirstreamId]];
    damperAirstreamTextField.text = [type valueForKey:@"Abbrev"];
    damperAirstreamId = _damperAirstreamId;
    self.inspection.sync = [NSNumber numberWithBool:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Photo Delegate

- (void)didCaptureImage:(UIImage *)image
{
    self.inspection.sync = [NSNumber numberWithBool:NO];
    if (_takingOpenPhoto) {
        NSString *photoName = [NSString stringWithFormat:@"%@-%@-1-%i", self.inspection.jobId, self.inspection.damper, (rand() + 1000)];
        self.inspection.localPhoto = photoName;
        [DPInspection cacheImageFor:self.inspection image:image andName:photoName];
        _takingOpenPhoto = NO;
        self.photoLabel.text = @"Photo selected";
    }else if(_takingClosedPhoto) {
        NSString *photoName = [NSString stringWithFormat:@"%@-%@-2-%i", self.inspection.jobId, self.inspection.damper, (rand() + 1000)];
        self.inspection.localPhoto2 = photoName;
        [DPInspection cacheImageFor:self.inspection image:image andName:photoName];
        _takingClosedPhoto = NO;
        self.photo2Label.text = @"Photo selected";
    }
}


@end
