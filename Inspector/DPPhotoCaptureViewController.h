//
//  DPPhotoCaptureViewController.h
//  Inspector
//
//  Created by Javier Figueroa on 5/10/12.
//  Copyright (c) 2012 Mainloop, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

@protocol DPPhotoCaptureViewControllerDelegate <NSObject>

- (void)didCaptureImage:(UIImage *)image;

@end


@interface DPPhotoCaptureViewController : UIViewController<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    UIPopoverController *_picker;
    BOOL _cameraOn;
}

@property (nonatomic, strong) NSURL *imageUrl;
@property (nonatomic, strong) NSString *imageKey;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, assign) id<DPPhotoCaptureViewControllerDelegate> delegate;

- (IBAction)didSelectCaptureButton:(id)sender;
- (IBAction)didSelectPickerButton:(id)sender;
- (IBAction)didSelectDoneButton:(id)sender;

@end
