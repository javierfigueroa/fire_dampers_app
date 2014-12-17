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
#import "SDImageCache.h"
#import "UIImageView+WebCache.h"
#import <MobileCoreServices/UTCoreTypes.h>

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
    
    if (self.imageUrl != nil) {
        [self.imageView sd_setImageWithURL:self.imageUrl];
    }else if(self.imageKey != nil) {
        [[SDImageCache sharedImageCache] queryDiskCacheForKey:self.imageKey done:^(UIImage *image, SDImageCacheType cacheType) {
            self.imageView.image = image;
        }];
    }else if (self.image != nil) {
        self.imageView.image = self.image;
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
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didSelectPickerButton:(id)sender
{
    // Override point for customization after application launch
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    // Displays a control that allows the user to choose picture or
    // movie capture, if both are available:
    cameraUI.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = NO;
    cameraUI.delegate = self;
    
    if (IPAD) {
//        if (_picker && [_picker isPopoverVisible]) {
//            [_picker dismissPopoverAnimated:YES];
//        }else{
            UIPopoverController *picker = [[UIPopoverController alloc]initWithContentViewController:cameraUI];
            [picker presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
//        }
    }else{
        [self.navigationController presentViewController:cameraUI animated:YES completion:nil];
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
    [self presentViewController:cameraUI animated:YES completion:nil];
//    _cameraOn = YES;
//    [_picker dismissPopoverAnimated:YES];
}

#pragma mark - UIImagePicker Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
//    if (IPAD) {
//        [picker dismissPopoverAnimated:YES];
//    }else{
        [picker dismissViewControllerAnimated:YES completion:nil];
//    }
//
//    if (_cameraOn) {
//        [self dismissViewControllerAnimated:YES completion:nil];
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
