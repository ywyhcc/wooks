//
//  NSKeyedUnarchiver+ExceptionCatch.h
//  RRSpring
//
//  Created by siglea on 9/28/12.
//  Copyright (c) 2012 RenRen.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSKeyedUnarchiver (CatchExceptions)

+ (id)unarchiveObjectWithData:(NSData*)data
                  caughtException:(NSException**)caughtException;

+ (id)unarchiveObjectWithFile:(NSString *)path
                  caughtException:(NSException**)caughtException;

@end
