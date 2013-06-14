//
//  DPLoginViewController.h
//  Inspector
//
//  Created by Eddy Borja on 4/22/12.
//  Copyright (c) 2012 Mainloop, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>





@interface DPLoginViewController : UIViewController



@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;


- (IBAction)didSelectLoginButton:(id)sender;
- (void)loginWithUsername:(NSString *)username password:(NSString *)password;



@end
