//
//  Job.h
//  Inspector
//
//  Created by Eddy Borja on 4/12/12.
//  Copyright (c) 2012 Mainloop, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Job : NSManagedObject

@property (nonatomic, retain) NSNumber * active;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * contactName;
@property (nonatomic, retain) NSString * contactPhoneNumber;
@property (nonatomic, retain) NSDate * creationDate;
@property (nonatomic, retain) NSDate * finishDate;
@property (nonatomic, retain) NSString * jobName;
@property (nonatomic, retain) NSDate * lastUpdate;
@property (nonatomic, retain) NSDate * startDate;
@property (retain, nonatomic) NSNumber *jobId;
@property (retain, nonatomic) NSNumber *userId;

@end
