//
//  DPJob.m
//  Inspector
//
//  Created by Javier Figueroa on 5/2/12.
//  Copyright (c) 2012 Mainloop, LLC. All rights reserved.
//

#import "DPJob.h"
#import "Job.h"
#import "DPApiClient.h"
#import "DPAppDelegate.h"

@implementation DPJob
@synthesize address;
@synthesize name;
@synthesize start;
@synthesize finish;
@synthesize created;
@synthesize updated;
@synthesize contact;
@synthesize phone;
@synthesize identifier;
@synthesize active;
@synthesize userId;

- (id)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    name = [attributes valueForKey:@"name"];
    address = [attributes valueForKey:@"address"];
    start = [dateFormatter dateFromString:[attributes valueForKey:@"start_date"]];
    finish = [dateFormatter dateFromString:[attributes valueForKey:@"finish_date"]];
    created = [dateFormatter dateFromString:[attributes valueForKey:@"created_at"]];
    updated = [dateFormatter dateFromString:[attributes valueForKey:@"updated_at"]];
    contact = [NSString stringWithFormat:@"%@ %@", [attributes valueForKey:@"contact_first_name"], [attributes valueForKey:@"contact_last_name"]];
    phone = [attributes valueForKey:@"contact_phone"];
    identifier = [attributes valueForKey:@"id"];
    userId = [attributes valueForKey:@"user_id"];
    active = [NSNumber numberWithBool:[[attributes valueForKey:@"active"] boolValue]];
    
    
    return self;
}

+ (void)updateRecords:(NSMutableArray *)records
{
    DPAppDelegate *delegate = (DPAppDelegate *)[[UIApplication sharedApplication] delegate];            
    NSManagedObjectContext *context = delegate.managedObjectContext;
    
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Job" 
                                              inManagedObjectContext:context];
    for (DPJob *job in records) {                
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDescription];          
        
        NSPredicate *predicate = [NSComparisonPredicate predicateWithLeftExpression:[NSExpression expressionForKeyPath:@"jobId"] rightExpression:[NSExpression expressionForConstantValue:job.identifier]  modifier:NSDirectPredicateModifier type:NSEqualToPredicateOperatorType options:0];
        [request setPredicate:predicate];
        NSError *error = nil;
        NSArray *array = [context executeFetchRequest:request error:&error];
        
        Job *managedJob = array.count == 0 ? 
        (Job *)[NSEntityDescription 
                            insertNewObjectForEntityForName:@"Job" 
                            inManagedObjectContext:context] : [array objectAtIndex:0];
        
        
        managedJob.jobName = job.name;
        managedJob.address = job.address;
        managedJob.active = job.active;
        managedJob.startDate = job.start;
        managedJob.finishDate = job.finish;
        managedJob.creationDate = job.created;
        managedJob.lastUpdate = job.updated;
        managedJob.contactName = job.contact;
        managedJob.contactPhoneNumber = job.phone;
        managedJob.jobId = job.identifier;
        managedJob.userId = job.userId;
    }
}

+ (void)getJobsWithBlock:(void (^)(NSObject *))block
{
    [[DPApiClient sharedClient] GET:@"jobs.json" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject)  {
        
        NSMutableArray *records = [[NSMutableArray alloc]init];
        NSLog(@"response %@", responseObject);
        if ([responseObject isKindOfClass:[NSArray class]]) {
            for (NSDictionary *jobJSON in responseObject) {
                NSDictionary *attributes = [(NSDictionary *)jobJSON objectForKey:@"job"];
                DPJob *job = [[DPJob alloc]initWithAttributes:attributes];
                [records addObject:job];
            }
            
            // update records in core data
            [self updateRecords:records];  
            if (block) {
                block([NSArray arrayWithArray:records]);
            }
        }
     } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Error: %@", error);
        if (block) {
            block([NSError errorWithDomain:[error localizedDescription] code:error.code userInfo:nil]);
        }
    }];
}

@end
