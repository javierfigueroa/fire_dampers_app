//
//  DPInspection.m
//  Inspector
//
//  Created by Javier Figueroa on 5/3/12.
//  Copyright (c) 2012 Mainloop, LLC. All rights reserved.
//

#import "DPInspection.h"
#import "DPApiClient.h"
#import "DPAppDelegate.h"
#import "Inspection.h"
#import "AFHTTPRequestOperation.h"
#import "SDImageCache.h"

@implementation DPInspection
@synthesize location;
@synthesize building;
@synthesize photo;
@synthesize notes;
@synthesize floor;
@synthesize damper;
@synthesize userId;
@synthesize damperTypeId;
@synthesize damperStatus;
@synthesize created;
@synthesize updated;
@synthesize inspected;
@synthesize jobId;
@synthesize inspectionId;
@synthesize photo2;
@synthesize localPhoto2;
@synthesize damperAirstream;
@synthesize unit;
@synthesize length;
@synthesize height;
@synthesize inspectorNotes;
@synthesize tag;

- (id)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    location = [attributes valueForKey:@"location"];
    building = [attributes valueForKey:@"building_abbrev"];
    created = [dateFormatter dateFromString:[attributes valueForKey:@"created_at"]];
    updated = [dateFormatter dateFromString:[attributes valueForKey:@"updated_at"]];
    photo = [attributes valueForKey:@"damper_image_url_open"];
    notes = [attributes valueForKey:@"description"];
    userId = [attributes valueForKey:@"user_id"];
    damper = [attributes valueForKey:@"damper_id"];
    damperStatus = [attributes valueForKey:@"damper_status_id"];
    damperTypeId = [attributes valueForKey:@"damper_type_id"];
    floor = [attributes valueForKey:@"floor"];
    inspected = [dateFormatter dateFromString:[attributes valueForKey:@"inspection_date"]];    
    jobId = [attributes valueForKey:@"job_id"];
    inspectionId = [attributes valueForKey:@"id"];
    
    photo2 = [attributes valueForKey:@"damper_image_url_closed"];
    damperAirstream = [attributes valueForKey:@"damper_airstream_id"];
    if (![[attributes valueForKey:@"unit"] isKindOfClass:[NSNull class]]) {
        unit = [attributes valueForKey:@"unit"];
    }
    length = [attributes valueForKey:@"length"];
    height = [attributes valueForKey:@"height"];
    inspectorNotes = [attributes valueForKey:@"notes"];
    tag = [attributes valueForKey:@"tag"];
    
    return self;
}

+ (void)deleteInspectionByDamperId:(NSNumber*)_damperId andJobId:(NSNumber*)_jobId
{
    NSFetchRequest *request = [Inspection MR_requestFirstWithPredicate:[NSPredicate predicateWithFormat:@"jobId == %@ && damper == %@", _jobId, _damperId]];
    id inspection = [Inspection MR_executeFetchRequestAndReturnFirstObject:request];
    if (inspection != nil && [inspection isKindOfClass:[Inspection class]]) {
        [[NSManagedObjectContext MR_defaultContext] deleteObject:inspection];
    }
}

- (Inspection *)copyToManagedInspectionWithPhoto:(UIImage *)picture1 andPhoto:(UIImage *)picture2
{
    Inspection *managedInspection = [Inspection MR_createEntity];
    DPInspection *inspection = self;
    
    managedInspection.location = inspection.location;
    managedInspection.building = inspection.building;
    managedInspection.photo = inspection.photo;
    managedInspection.notes = inspection.notes;
    managedInspection.floor = inspection.floor;
    managedInspection.damper = [NSNumber numberWithInt:[inspection.damper intValue]];
    managedInspection.userId = inspection.userId;
    managedInspection.damperStatus = inspection.damperStatus;
    managedInspection.damperTypeId = inspection.damperTypeId;
    managedInspection.created = inspection.created;
    managedInspection.updated_at = inspection.updated;
    managedInspection.inspected = inspection.inspected;
    managedInspection.jobId = inspection.jobId;
    managedInspection.inspectionId = inspection.inspectionId;
    managedInspection.photo2 = inspection.photo2;
    managedInspection.damperAirstream = inspection.damperAirstream;
    if (![inspection.unit isKindOfClass:[NSNull class]]) {
        managedInspection.unit = inspection.unit;
    }
    managedInspection.length = inspection.length;
    managedInspection.height = inspection.height;
    managedInspection.inspectorNotes = inspection.inspectorNotes;
    managedInspection.tag = inspection.tag;
    managedInspection.sync = [NSNumber numberWithBool:NO];
    
    if (picture1){
        NSString *photoName1 = [NSString stringWithFormat:@"%@-%@-1-%i", inspection.jobId, inspection.damper, (rand() + 1000)];        
        managedInspection.localPhoto = photoName1;
        [DPInspection cacheImageFor:managedInspection image:picture1 andName:photoName1]; 
    }
    
    if (picture2){
        NSString *photoName2 = [NSString stringWithFormat:@"%@-%@-2-%i", inspection.jobId, inspection.damper, (rand() + 1000)];        
        managedInspection.localPhoto2 = photoName2;
        [DPInspection cacheImageFor:managedInspection image:picture2 andName:photoName2]; 
    }
    
    return managedInspection;
}

+ (void)cacheImageFor:(Inspection *)inspection image:(UIImage *)picture andName:(NSString *)name {
    if (picture) {        
        dispatch_queue_t backgroundQueue = dispatch_queue_create("com.inspector.bgqueue", NULL);    
        dispatch_async(backgroundQueue, ^{     
            [[SDImageCache sharedImageCache] storeImage:picture forKey:name toDisk:YES];
        });
    }
}

+ (void)updateRecords:(NSMutableArray *)records
{
    for (DPInspection *inspection in records) {
        NSArray *array = [Inspection MR_findByAttribute:@"inspectionId" withValue:inspection.inspectionId];
        Inspection *managedInspection = array.count == 0 ? [Inspection MR_createEntity] : [array objectAtIndex:0];
        
        managedInspection.location = inspection.location;
        managedInspection.building = inspection.building;
        managedInspection.photo = inspection.photo;
        managedInspection.notes = inspection.notes;
        managedInspection.floor = inspection.floor;
        managedInspection.damper = [NSNumber numberWithInt:[inspection.damper intValue]];
        managedInspection.userId = inspection.userId;
        managedInspection.damperStatus = inspection.damperStatus;
        managedInspection.damperTypeId = inspection.damperTypeId;
        managedInspection.created = inspection.created;
        managedInspection.updated_at = inspection.updated;
        managedInspection.inspected = inspection.inspected;
        managedInspection.jobId = inspection.jobId;
        managedInspection.inspectionId = inspection.inspectionId;
        managedInspection.photo2 = inspection.photo2;
        managedInspection.damperAirstream = inspection.damperAirstream;
        if (![inspection.unit isKindOfClass:[NSNull class]]) {
            managedInspection.unit = inspection.unit;
        }
        managedInspection.length = inspection.length;
        managedInspection.height = inspection.height;
        managedInspection.inspectorNotes = inspection.inspectorNotes;
        managedInspection.tag = inspection.tag;
        managedInspection.localPhoto2 = @"";
        managedInspection.localPhoto = @"";
        managedInspection.sync = [NSNumber numberWithBool:YES];
    }
}

+ (void)getInspectionsForJobId:(NSNumber *)jobId withBlock:(void (^)(NSObject *))block
{
    [[DPApiClient sharedClient] GET:[NSString stringWithFormat:@"inspections/job/%@.json", jobId] parameters:nil success:^(NSURLSessionTask *operation, id responseObject){
        
        NSMutableArray *records = [[NSMutableArray alloc]init];
        NSLog(@"response %@", responseObject);
        if ([responseObject isKindOfClass:[NSArray class]]) {
            for (NSDictionary *inspectionJSON in responseObject) {
                NSDictionary *attributes = [(NSDictionary *)inspectionJSON objectForKey:@"inspection"];
                DPInspection *inspection = [[DPInspection alloc]initWithAttributes:attributes];
                [records addObject:inspection];
            }
            
            // update records in core data
            [self updateRecords:records];  
            if (block) {
                block([NSArray arrayWithArray:records]);
            }
        }
    } 
    failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        if (block) {
            block([NSError errorWithDomain:[error localizedDescription] code:error.code userInfo:nil]);
        }
    }];

}

+ (void)updateInspection:(Inspection *)inspection withDamperPhotoOpen:(UIImage *)photoOpen withDamperPhotoClosed:(UIImage *)photoClosed withBlock:(void (^)(NSObject *))block
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]init];
    [parameters setValue:inspection.building forKey:@"inspection[building_abbrev]"];
    [parameters setValue:inspection.damper forKey:@"inspection[damper_id]"];
    [parameters setValue:inspection.damperStatus forKey:@"inspection[damper_status_id"];
    [parameters setValue:inspection.damperTypeId forKey:@"inspection[damper_type_id]"];
    [parameters setValue:inspection.notes forKey:@"inspection[description]"];
    [parameters setValue:inspection.floor forKey:@"inspection[floor]"];
    
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy"];
    NSString *year = [dateFormatter stringFromDate:inspection.inspected];
    [parameters setValue:year forKey:@"inspection[inspection_date(1i)]"];
    
    [dateFormatter setDateFormat:@"MM"];
    NSString *month = [dateFormatter stringFromDate:inspection.inspected];
    [parameters setValue:month forKey:@"inspection[inspection_date(2i)]"];
    
    [dateFormatter setDateFormat:@"dd"];
    NSString *day = [dateFormatter stringFromDate:inspection.inspected];
    [parameters setValue:day forKey:@"inspection[inspection_date(3i)]"];
    
    [parameters setValue:inspection.jobId forKey:@"inspection[job_id]"];
    [parameters setValue:inspection.location forKey:@"inspection[location]"];
    [parameters setValue:inspection.unit forKey:@"inspection[unit]"];
    [parameters setValue:inspection.damperAirstream forKey:@"inspection[damper_airstream_id]"];
    [parameters setValue:inspection.inspectorNotes forKey:@"inspection[notes]"];
    [parameters setValue:inspection.length forKey:@"inspection[length]"];
    [parameters setValue:inspection.height forKey:@"inspection[height]"];
    
    if (photoOpen || photoClosed) {
        
        NSData *imageDataOpen = nil;
        NSString *photoNameOpen = nil;
        NSData *imageDataClosed = nil;
        NSString *photoNameClosed = nil;
        
        if (photoOpen) {
            imageDataOpen = UIImageJPEGRepresentation(photoOpen, 0.032);
            photoNameOpen = inspection.localPhoto;        
        }
        
        if (photoClosed) {
            imageDataClosed = UIImageJPEGRepresentation(photoClosed, 0.032);
            photoNameClosed = inspection.localPhoto2;        
        }
//        [DPInspection cacheImageFor:inspection image:photo andName:photoName];       
        NSError *serializationError = nil;
        NSMutableURLRequest *request = [[DPApiClient sharedClient].requestSerializer multipartFormRequestWithMethod:@"PUT" URLString:[[NSURL URLWithString:[NSString stringWithFormat:@"inspections/%@.json", inspection.inspectionId] relativeToURL:[DPApiClient sharedClient].baseURL] absoluteString] parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            if (imageDataOpen) {
                [formData appendPartWithFileData:imageDataOpen
                                            name:@"inspection[damper_image]"
                                        fileName:[NSString stringWithFormat:@"%@.jpg", photoNameOpen]
                                        mimeType:@"image/jpeg"];
            }
            
            if (imageDataClosed) {
                [formData appendPartWithFileData:imageDataClosed
                                            name:@"inspection[damper_image_second]"
                                        fileName:[NSString stringWithFormat:@"%@.jpg", photoNameClosed]
                                        mimeType:@"image/jpeg"];
            }
            
        } error:&serializationError];
        
        if (serializationError) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
                dispatch_async([DPApiClient sharedClient].completionQueue ?: dispatch_get_main_queue(), ^{
                    NSLog(@"Error: %@", serializationError);
                    if (block) {
                        block([NSError errorWithDomain:[serializationError localizedDescription] code:serializationError.code userInfo:nil]);
                    }
                });
#pragma clang diagnostic pop
        }else{
            
            __block NSURLSessionDataTask *task = [[DPApiClient sharedClient] uploadTaskWithStreamedRequest:request progress:nil completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
                if (error) {
                    NSLog(@"Error: %@", error);
                    if (block) {
                        block([NSError errorWithDomain:[error localizedDescription] code:error.code userInfo:nil]);
                    }
                } else {
                    if(block) {
                        inspection.sync = [NSNumber numberWithBool:YES];
                        //                inspection.localPhoto = @"";
                        block(nil);
                    }
                }
            }];
            
            [task resume];
            
        }
    }else{
        
        [[DPApiClient sharedClient] PUT:[NSString stringWithFormat:@"inspections/%@.json", inspection.inspectionId] parameters:parameters success:^(NSURLSessionTask *operation, id responseObject) {
            inspection.sync = [NSNumber numberWithBool:YES];
            block(nil);
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            NSLog(@"%@", error);
            block([NSError errorWithDomain:[error localizedDescription] code:error.code userInfo:nil]);
        }];
    }   
}


+ (void)addInspection:(Inspection *)inspection withDamperPhotoOpen:(UIImage *)photoOpen withDamperPhotoClosed:(UIImage *)photoClosed withBlock:(void (^)(NSObject *))block
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc]init];
    [parameters setValue:inspection.building forKey:@"inspection[building_abbrev]"];
    [parameters setValue:[NSNumber numberWithInt:[inspection.damper intValue]] forKey:@"inspection[damper_id]"];
    [parameters setValue:[NSNumber numberWithInt:[inspection.damperStatus intValue]] forKey:@"inspection[damper_status_id"];
    [parameters setValue:[NSNumber numberWithInt:[inspection.damperTypeId intValue]] forKey:@"inspection[damper_type_id]"];
    [parameters setValue:inspection.notes forKey:@"inspection[description]"];
    [parameters setValue:inspection.floor forKey:@"inspection[floor]"];
    [parameters setValue:inspection.unit forKey:@"inspection[unit]"];
    [parameters setValue:[NSNumber numberWithInt:[inspection.damperAirstream intValue]] forKey:@"inspection[damper_airstream_id]"];
    [parameters setValue:inspection.inspectorNotes forKey:@"inspection[notes]"];
    [parameters setValue:inspection.length forKey:@"inspection[length]"];
    [parameters setValue:inspection.height forKey:@"inspection[height]"];
    [parameters setValue:inspection.userId forKey:@"inspection[user_id]"];
    
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy"];
    NSString *year = [dateFormatter stringFromDate:inspection.inspected];
    [parameters setValue:year forKey:@"inspection[inspection_date(1i)]"];
    
    [dateFormatter setDateFormat:@"MM"];
    NSString *month = [dateFormatter stringFromDate:inspection.inspected];
    [parameters setValue:month forKey:@"inspection[inspection_date(2i)]"];
    
    [dateFormatter setDateFormat:@"dd"];
    NSString *day = [dateFormatter stringFromDate:inspection.inspected];
    [parameters setValue:day forKey:@"inspection[inspection_date(3i)]"];
    
    [parameters setValue:inspection.jobId forKey:@"inspection[job_id]"];
    [parameters setValue:inspection.location forKey:@"inspection[location]"];
    
    if (photoOpen || photoClosed) {
        NSData *imageDataOpen = nil;
        NSData *imageDataClosed = nil;
        
        NSString *photoNameOpen = nil;
        NSString *photoNameClosed = nil;
        
        if (photoOpen) {
            imageDataOpen = UIImageJPEGRepresentation(photoOpen, 0.032);
            photoNameOpen = [NSString stringWithFormat:@"%@-%@-%i", inspection.jobId, inspection.damper, (rand() + 1000)]; 
            
            dispatch_queue_t backgroundQueue = dispatch_queue_create("com.inspector.bgqueue", NULL);    
            dispatch_async(backgroundQueue, ^{     
                [[SDImageCache sharedImageCache] storeImage:photoOpen forKey:photoNameOpen toDisk:YES];
            });
        }
        
        if (photoClosed) {
            imageDataClosed = UIImageJPEGRepresentation(photoClosed, 0.032);
            photoNameClosed = [NSString stringWithFormat:@"%@-%@-%i", inspection.jobId, inspection.damper, (rand() + 1000)]; 
            
            dispatch_queue_t backgroundQueue = dispatch_queue_create("com.inspector.bgqueue", NULL);    
            dispatch_async(backgroundQueue, ^{     
                [[SDImageCache sharedImageCache] storeImage:photoClosed forKey:photoNameClosed toDisk:YES];
            });
        }

        
        
        [[DPApiClient sharedClient] POST:@"inspections.json" parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            if (imageDataOpen){
                [formData appendPartWithFileData:imageDataOpen
                                            name:@"inspection[damper_image]"
                                        fileName:[NSString stringWithFormat:@"%@.jpg", photoNameOpen]
                                        mimeType:@"image/jpeg"];
            }
            
            if (imageDataClosed) {
                [formData appendPartWithFileData:imageDataClosed
                                            name:@"inspection[damper_image_second]"
                                        fileName:[NSString stringWithFormat:@"%@.jpg", photoNameClosed]
                                        mimeType:@"image/jpeg"];
                
            }
            
        } success:^(NSURLSessionDataTask *task, id responseObject) {
            if(block) {
                block([responseObject valueForKey:@"inspection"]);
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"Error: %@", error);
            if (block) {
                NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
                if (response.statusCode == 422) {
                    [self deleteInspectionByDamperId:inspection.damper andJobId:inspection.jobId];
                    block([NSError errorWithDomain:NSLocalizedString(@"Damper Id is a duplicate, enter a correct Damper Id", @"Damper Id is a duplicate, enter a correct Damper Id") code:response.statusCode userInfo:nil]);
                }else{
                    block([NSError errorWithDomain:response.description code:response.statusCode userInfo:nil]);
                }
            }
        }];
    }else{
            
        [[DPApiClient sharedClient] POST:@"inspections.json" parameters:parameters success:^(NSURLSessionTask *operation, id responseObject) {
            block([responseObject valueForKey:@"inspection"]);
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            NSLog(@"%@", error);
            NSHTTPURLResponse *response = (NSHTTPURLResponse *)operation.response;            
            if (response.statusCode == 422) {
                [self deleteInspectionByDamperId:inspection.damper andJobId:inspection.jobId];
                block([NSError errorWithDomain:NSLocalizedString(@"Damper Id is a duplicate, enter a correct Damper Id", @"Damper Id is a duplicate, enter a correct Damper Id") code:response.statusCode userInfo:nil]);
            }else{
                block([NSError errorWithDomain:response.description code:response.statusCode userInfo:nil]);
            }
        }];
    }    
}


@end
