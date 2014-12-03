//
//  DPPhotoCaptureViewController.m
//  Inspector
//
//  Created by Javier Figueroa on 5/10/12.
//  Copyright (c) 2012 Mainloop, LLC. All rights reserved.
//

#import "DPPhotoCaptureViewController.h"
#import "DPInspectionsViewController.h"
#import "UIImage+FixOrientation.h"
#import "SVProgressHUD.h"

@interface DPPhotoCaptureViewController ()

@end

@implementation DPPhotoCaptureViewController
@synthesize delegate;
@synthesize image = _image;
@synthesize imageView;
//@synthesize pickerButton;

- (void)setImage:(UIImage *)image
{
    _image = image;
    
    if (_image) {
        self.imageView.image = _image;
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (delegate && [delegate isKindOfClass:[DPInspectionsViewController class]]) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(didSelectDoneButton:)];
    }
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{	
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

-(void)didSelectDoneButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didSelectPickerButton:(id)sender
{    
    if (_picker && [_picker isPopoverVisible]) {
        [_picker dismissPopoverAnimated:YES];
    }else{
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    // Displays a control that allows the user to choose picture or
    // movie capture, if both are available:
    cameraUI.mediaTypes =
    [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = NO;
    
    cameraUI.delegate = self;
    
    _picker = [[UIPopoverController alloc]initWithContentViewController:cameraUI];
    
    [_picker presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    
}



- (void)didSelectCaptureButton:(id)sender {
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    // Displays a control that allows the user to choose picture or
    // movie capture, if both are available:
    cameraUI.mediaTypes =
    [UIImagePickerController availableMediaTypesForSourceType:
     UIImagePickerControllerSourceTypeCamera];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = NO;
    
    cameraUI.delegate = self;
    [self presentViewController:cameraUI animated:YES completion:^{
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }];
    
//    _cameraOn = YES;
    
    [_picker dismissPopoverAnimated:YES];
}

#pragma mark - UIImagePicker Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    [_picker dismissPopoverAnimated:YES];
    
//    if (_cameraOn) {
//        [self dismissModalViewControllerAnimated:YES];
//    }
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *photo = [info
                          objectForKey:UIImagePickerControllerOriginalImage];
        
        self.imageView.image = [photo fixOrientation];
        if (delegate && [delegate respondsToSelector:@selector(didCaptureImage:)]) {
            [delegate didCaptureImage: self.imageView.image];
        }
    }
    
    
}


@end
