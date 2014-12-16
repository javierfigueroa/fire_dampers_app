//
//  DPLoginViewController.m
//  Inspector
//
//  Created by Eddy Borja on 4/22/12.
//  Copyright (c) 2012 Mainloop, LLC. All rights reserved.
//

#import "DPLoginViewController.h"
#import "DPApiClient.h"
#import "DPUser.h"
#import "DPTechnician.h"
#import "SVProgressHUD.h"

@interface DPLoginViewController ()

@end

@implementation DPLoginViewController
@synthesize usernameTextField;
@synthesize passwordTextField;

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
    self.usernameTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    self.passwordTextField.text = @"";
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{	
    return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (IBAction)didSelectLoginButton:(id)sender {
    
    [self loginWithUsername:self.usernameTextField.text password:self.passwordTextField.text];
     [self.view endEditing:YES];
    
}


//TODO: Verify username and password is correct
- (void)loginWithUsername:(NSString *)username password:(NSString *)password{
    
    [SVProgressHUD showWithStatus:@"Signing in" maskType:SVProgressHUDMaskTypeGradient];
    [DPUser loginWithUsername:username andPassword:password block:^(NSObject *response) {
        if ([response isKindOfClass:[DPUser class]]) {
            [DPTechnician getTechnicianWithBlock:^(NSObject *response) {
                [SVProgressHUD showSuccessWithStatus:@"Logged in Successfully"];
               [[NSNotificationCenter defaultCenter] postNotificationName:kUserDidLoginNotification object:self];
            }];
        }else{
            [SVProgressHUD showErrorWithStatus:@"Failed to login, check your credentials or contact Support"];
        }
    }];
}

@end
