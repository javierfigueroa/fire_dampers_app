//
//  DPDamperStatusesViewController.h
//  Inspector
//
//  Created by Javier Figueroa on 5/10/12.
//  Copyright (c) 2012 Mainloop, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DPDamperStatusesViewControllerDelegate <NSObject>

- (void) didSelectStatus:(NSNumber *)damperStatusId;

@end

@interface DPDamperStatusesViewController : UITableViewController

@property (strong, nonatomic) NSMutableDictionary *damperStatus;
@property (strong, nonatomic) NSNumber *checkedStatus;
@property (assign, nonatomic) id<DPDamperStatusesViewControllerDelegate> delegate;

- (IBAction)didSelectDoneButton:(id)sender;
@end
