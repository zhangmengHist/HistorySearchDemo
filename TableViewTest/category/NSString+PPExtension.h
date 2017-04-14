//
//  NSString+PPExtension.h
//  BLGProject
//
//  Created by pengpeng on 16/2/20.
//  Copyright © 2016年 baolegou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (PPExtension)

@property (readonly) NSString *md5String;

/**
 *  返回缓存路径的完整路径名
 */
- (NSString *)cacheDir;

@end
