//
//  NSURL+Util.m
//  FirstP2P
//
//  Created by fengquanwang on 11/26/15.
//  Copyright © 2015 9888. All rights reserved.
//

#import "NSURL+Util.h"

@implementation NSURL(Util)

- (NSDictionary *)queryParams{
	NSMutableDictionary *params = [NSMutableDictionary dictionary];
	NSArray *pairArray = [self.query componentsSeparatedByString:@"&"];
	for (NSString *pair in pairArray) {
		NSArray *dataArray = [pair componentsSeparatedByString:@"="];
		if (dataArray.count == 2) {
			[params setObject:dataArray[1] forKey:dataArray[0]];
		}
	}
	
	return params;
}

@end
