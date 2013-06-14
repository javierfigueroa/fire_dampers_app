//
//  DPInspectionCell.h
//  Inspector
//
//  Created by Javier Figueroa on 5/6/12.
//  Copyright (c) 2012 Mainloop, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DPInspectionCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *damperId;
@property (strong, nonatomic) IBOutlet UILabel *damperType;
@property (strong, nonatomic) IBOutlet UILabel *comments;
@property (strong, nonatomic) IBOutlet UILabel *status;
@property (strong, nonatomic) IBOutlet UILabel *syncState;
@end
