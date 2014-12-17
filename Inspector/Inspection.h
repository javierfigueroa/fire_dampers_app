//
//  Inspection.h
//  Inspector
//
//  Created by Javier Figueroa on 5/22/12.
//  Copyright (c) 2012 Mainloop, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Inspection : NSManagedObject

@property (nonatomic, retain) NSString * building;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSNumber * damper;
@property (nonatomic, retain) NSNumber * damperStatus;
@property (nonatomic, retain) NSNumber * damperTypeId;
@property (nonatomic, retain) NSNumber * floor;
@property (nonatomic, retain) NSDate * inspected;
@property (nonatomic, retain) NSNumber * inspectionId;
@property (nonatomic, retain) NSNumber * jobId;
@property (nonatomic, retain) NSString * localPhoto;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * photo;
@property (nonatomic, retain) NSNumber * sync;
@property (nonatomic, retain) NSDate * updated_at;
@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSString * photo2;
@property (nonatomic, retain) NSString * localPhoto2;
@property (nonatomic, retain) NSNumber * damperAirstream;
@property (nonatomic, retain) NSNumber * unit;
@property (nonatomic, retain) NSString * length;
@property (nonatomic, retain) NSString * height;
@property (nonatomic, retain) NSString * inspectorNotes;
@property (nonatomic, retain) NSString * tag;

@end
