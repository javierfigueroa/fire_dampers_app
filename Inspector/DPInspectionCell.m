//
//  DPInspectionCell.m
//  Inspector
//
//  Created by Javier Figueroa on 5/6/12.
//  Copyright (c) 2012 Mainloop, LLC. All rights reserved.
//

#import "DPInspectionCell.h"

@implementation DPInspectionCell
@synthesize damperId;
@synthesize damperType;
@synthesize comments;
@synthesize status;
@synthesize syncState;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
