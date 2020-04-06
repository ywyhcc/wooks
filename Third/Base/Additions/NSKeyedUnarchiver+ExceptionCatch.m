//
//  NSKeyedUnarchiver+ExceptionCatch.m
//  RRSpring
//
//  Created by siglea on 9/28/12.
//  Copyright (c) 2012 RenRen.com. All rights reserved.
//

#import "NSKeyedUnarchiver+ExceptionCatch.h"
#import <objc/runtime.h>


@implementation NSKeyedUnarchiver (CatchExceptions)


+ (id)unarchiveObjectWithData:(NSData*)data
                  caughtException:(NSException**)caughtException {
    id object = nil ;
    
    
    @try {
        // Note: Since methods were swapped, this is invoking the original method
        object = [NSKeyedUnarchiver unarchiveObjectWithData:data] ;
    }
    @catch (NSException* exception) {
        if (caughtException) {
            *caughtException = exception ;
        }
    }
    @finally{
    }
    
    return object ;
}

+ (id)unarchiveObjectWithFile:(NSString *)path
                  caughtException:(NSException**)caughtException {
    id object = nil ;
    
    
    @try {
        // Note: Since methods were swapped, this is invoking the original method
        object = [NSKeyedUnarchiver unarchiveObjectWithFile:path] ;
    }
    @catch (NSException* exception) {
        if (caughtException) {
            *caughtException = exception ;
        }
    }
    @finally{
    }
    
    return object ;
}

@end