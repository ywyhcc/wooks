//
//  ZCKeyChainUtils.h
//  FirstP2P
//
//  Created by Yuan yiyang on 4/24/13.
//  Copyright (c) 2013 Yuan yiyang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeyChainUtils : NSObject

+ (NSString *)getValueForKey:(NSString *)keyName atService:(NSString *)serviceName error:(NSError **)error;
+ (BOOL)storeValue:(NSString *)value forKey:(NSString *)keyName atService:(NSString *)serviceName updateExisting:(BOOL)updateExisting error:(NSError **)error;
+ (BOOL)deleteValueForKey:(NSString *)keyName atService:(NSString *)serviceName error:(NSError **)error;
+ (BOOL)isValueExistingForKey:(NSString *)keyName atService:(NSString *)serviceName error:(NSError **)error;

@end
