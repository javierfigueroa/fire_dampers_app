//
//  DPLocalStorageFetcher.h
//  Inspector
//
//  Created by Javier Figueroa on 5/11/12.
//  Copyright (c) 2012 Mainloop, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SDImageCache.h"
//#import "SDImageCacheDelegate.h"

@interface DPLocalStorageFetcher : NSObject<SDImageCacheDelegate>

@property (nonatomic, strong) UIImageView *imageView;

- (void) fetchStoredImageForKey:(NSString *)key;
@end
