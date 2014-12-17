//
//  DPInspection.h
//  Inspector
//
//  Created by Javier Figueroa on 5/3/12.
//  Copyright (c) 2012 Mainloop, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Inspection;

@interface DPInspection : NSObject


@property (strong, nonatomic) NSString* location;
@property (strong, nonatomic) NSString* building;
@property (strong, nonatomic) NSString* photo;
@property (strong, nonatomic) NSString* notes;
//@property (strong, nonatomic) NSNumber* technicianId;
@property (strong, nonatomic) NSNumber* floor;
@property (strong, nonatomic) NSNumber* inspectionId;
@property (strong, nonatomic) NSNumber* damper;
@property (strong, nonatomic) NSNumber* userId;
@property (strong, nonatomic) NSNumber* damperTypeId;
@property (strong, nonatomic) NSNumber* jobId;
@property (strong, nonatomic) NSNumber* damperStatus;
@property (strong, nonatomic) NSDate* created;
@property (strong, nonatomic) NSDate* updated;
@property (strong, nonatomic) NSDate* inspected;
@property (nonatomic, strong) NSString * photo2;
@property (nonatomic, strong) NSString * localPhoto2;
@property (nonatomic, strong) NSNumber * damperAirstream;
@property (nonatomic, strong) NSNumber * unit;
@property (nonatomic, strong) NSString * length;
@property (nonatomic, strong) NSString * height;
@property (nonatomic, strong) NSString * inspectorNotes;
@property (nonatomic, strong) NSString * tag;


- (id)initWithAttributes:(NSDictionary *)attributes;
- (Inspection *)copyToManagedInspectionWithPhoto:(UIImage *)picture1 andPhoto:(UIImage *)picture2;
- (BOOL)isUnique;

+ (void)deleteInspectionByDamperId:(NSNumber*)_damperId andJobId:(NSNumber*)_jobId;
+ (void)cacheImageFor:(Inspection *)inspection image:(UIImage *)picture andName:(NSString *)name;
+ (void)getInspectionsForJobId:(NSNumber *)jobId withBlock:(void (^)(NSObject *))block;
+ (void)updateInspection:(Inspection *)inspection withDamperPhotoOpen:(UIImage *)photoOpen withDamperPhotoClosed:(UIImage *)photoClosed withBlock:(void (^)(NSObject *))block;
+ (void)addInspection:(DPInspection *)inspection withDamperPhotoOpen:(UIImage *)photoOpen withDamperPhotoClosed:(UIImage *)photoClosed withBlock:(void (^)(NSObject *))block;
@end
