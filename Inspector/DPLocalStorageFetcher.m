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
    [[SDImageCache sharedImageCache] queryDiskCacheForKey:key done:^(UIImage *image, SDImageCacheType cacheType) {
        
        if (!image) {
            NSLog(@"No image found for key %@", key);
        }
        self.imageView.image = image;
        
    }];
}

@end
