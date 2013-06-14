//
//  DPLocalStorageFetcher.m
//  Inspector
//
//  Created by Javier Figueroa on 5/11/12.
//  Copyright (c) 2012 Mainloop, LLC. All rights reserved.
//

#import "DPLocalStorageFetcher.h"

@implementation DPLocalStorageFetcher
@synthesize imageView;


- (void) fetchStoredImageForKey:(NSString *)key
{
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:self, @"delegate", key, @"key", [NSNumber numberWithInt:0], @"options", nil];    
    [[SDImageCache sharedImageCache] queryDiskCacheForKey:key delegate:self userInfo:info];
}

#pragma mark - SDImageCacheDelegate

- (void)imageCache:(SDImageCache *)imageCache didFindImage:(UIImage *)image forKey:(NSString *)key userInfo:(NSDictionary *)info
{
    self.imageView.image = image;
}

- (void)imageCache:(SDImageCache *)imageCache didNotFindImageForKey:(NSString *)key userInfo:(NSDictionary *)info
{    
    //no image found
    NSLog(@"No image found for key %@", key);
}

@end
