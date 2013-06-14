//
//  DPDamperTypesViewController.h
//  Inspector
//
//  Created by Javier Figueroa on 5/10/12.
//  Copyright (c) 2012 Mainloop, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DPDamperTypesViewControllerDelegate <NSObject>

- (void) didSelectDamperType:(NSNumber *)damperTypeId;

@end

@interface DPDamperTypesViewController : UITableViewController


@property (strong, nonatomic) NSMutableDictionary *damperTypes;
@property (strong, nonatomic) NSNumber *checkedType;
@property (assign, nonatomic) id<DPDamperTypesViewControllerDelegate> delegate;

- (IBAction)didSelectDoneButton:(id)sender;
@end
