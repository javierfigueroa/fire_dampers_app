//
//  DPDetailViewController.h
//  Inspector
//
//  Created by Eddy Borja on 3/31/12.
//  Copyright (c) 2012 Badderjoy, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DPDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end
