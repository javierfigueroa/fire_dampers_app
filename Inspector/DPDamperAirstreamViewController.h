//
//  DPDamperAirstreamViewController.h
//  Inspector
//
//  Created by Javier Figueroa on 5/22/12.
//  Copyright (c) 2012 Mainloop, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DPDamperAirstreamViewControllerDelegate <NSObject>

- (void) didSelectDamperAirstream:(NSNumber *)damperAirstreamId;

@end
@interface DPDamperAirstreamViewController : UITableViewController

@property (strong, nonatomic) NSMutableDictionary *damperAirstreams;
@property (strong, nonatomic) NSNumber *checkedType;
@property (assign, nonatomic) id<DPDamperAirstreamViewControllerDelegate> delegate;

- (IBAction)didSelectDoneButton:(id)sender;
@end
