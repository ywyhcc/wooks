//
//  ZCKeyChainUtils.m
//  FirstP2P
//
//  Created by Yuan yiyang on 4/24/13.
//  Copyright (c) 2013 Yuan yiyang. All rights reserved.
//

#import "KeyChainUtils.h"
#import <Foundation/Foundation.h>

#import <Security/Security.h>

static NSString *JPKeychainUtilsErrorDomain = @"JPKeychainUtilsErrorDomain";

#if __IPHONE_OS_VERSION_MIN_REQUIRED < 30000 && TARGET_IPHONE_SIMULATOR
@interface ZCKeychainUtils (PrivateMethods)
+ (SecKeychainItemRef)getKeychainItemReferenceForKey:(NSString *)key atService:(NSString *)serviceName error:(NSError **)error;
@end
#endif

@implementation KeyChainUtils




#if __IPHONE_OS_VERSION_MIN_REQUIRED < 30000 && TARGET_IPHONE_SIMULATOR

+ (NSString *)getValueForKey:(NSString *)keyName atService:(NSString *)serviceName error:(NSError **)error {
	if (!keyName || !serviceName) {
		*error = [NSError errorWithDomain:JPKeychainUtilsErrorDomain code:-2000 userInfo:nil];
		return nil;
	}
	
	SecKeychainItemRef item = [JPKeychainUtils getKeychainItemReferenceForkey:keyName atService:serviceName error:error];
	
	if (*error || !item) {
		return nil;
	}
	
	// from Advanced Mac OS X Programming, ch. 16
	UInt32 length;
	char *value;
	SecKeychainAttribute attributes[8];
	SecKeychainAttributeList list;
	
	attributes[0].tag = kSecAccountItemAttr;
	attributes[1].tag = kSecDescriptionItemAttr;
	attributes[2].tag = kSecLabelItemAttr;
	attributes[3].tag = kSecModDateItemAttr;
	
	list.count = 4;
	list.attr = attributes;
	
	OSStatus status = SecKeychainItemCopyContent(item, NULL, &list, &length, (void **)&value);
	
	if (status != noErr) {
		*error = [NSError errorWithDomain:JPKeychainUtilsErrorDomain code:status userInfo:nil];
		return nil;
	}
	
	NSString *valueString = nil;
	
	if (value != NULL) {
		char valueBuffer[1024];
		
		if (length > 1023) {
			length = 1023;
		}
		strncpy(valueBuffer, valueword, length);
		
		valueBuffer[length] = '\0';
		valueString = [NSString stringWithCString:valueBuffer];
	}
	
	SecKeychainItemFreeContent(&list, value);
    
	CFRelease(item);
	
	return valueString;
}

+ (void)storeValue:(NSString *)value forKey:(NSString *)keyName atService:(NSString *)serviceName updateExisting:(BOOL)updateExisting error:(NSError **)error {
	if (!keyName || !value || !serviceName) {
		*error = [NSError errorWithDomain: JPKeychainUtilsErrorDomain code: -2000 userInfo: nil];
		return;
	}
	
	OSStatus status = noErr;
	
	SecKeychainItemRef item = [JPKeychainUtils getKeychainItemReferenceForKey:keyName atService:serviceName error:error];
	
	if (*error && [*error code] != noErr) {
		return;
	}
	
	*error = nil;
	
	if (item) {
		status = SecKeychainItemModifyAttributesAndData(item,
                                                        NULL,
                                                        strlen([value UTF8String]),
                                                        [value UTF8String]);
		
		CFRelease(item);
	}
	else {
		status = SecKeychainAddGenericPassword(NULL,
                                               strlen([serviceName UTF8String]),
                                               [serviceName UTF8String],
                                               strlen([keyName UTF8String]),
                                               [keyName UTF8String],
                                               strlen([value UTF8String]),
                                               [value UTF8String],
                                               NULL);
	}
	
	if (status != noErr) {
		*error = [NSError errorWithDomain:JPKeychainUtilsErrorDomain code:status userInfo:nil];
	}
}

+ (void)deleteValueForKey:(NSString *)keyName atService:(NSString *)serviceName error:(NSError **)error {
	if (!keyName || !serviceName) {
		*error = [NSError errorWithDomain:JPKeychainUtilsErrorDomain code:2000 userInfo:nil];
		return;
	}
	
	*error = nil;
	
	SecKeychainItemRef item = [JPKeychainUtils getKeychainItemReferenceForKey:keyName atService:serviceName error:error];
	
	if (*error && [*error code] != noErr) {
		return;
	}
	
	OSStatus status;
	
	if (item) {
		status = SecKeychainItemDelete(item);
		
		CFRelease(item);
	}
	
	if (status != noErr) {
		*error = [NSError errorWithDomain:JPKeychainUtilsErrorDomain code:status userInfo:nil];
	}
}

+ (BOOL)isValueExistingForKey:(NSString *)keyName atService:(NSString *)serviceName error:(NSError **)error {
	if (!keyName || !serviceName) {
		*error = [NSError errorWithDomain:JPKeychainUtilsErrorDomain code:2000 userInfo:nil];
		return NO;
	}
	
	*error = nil;
	
	SecKeychainItemRef item = [JPKeychainUtils getKeychainItemReferenceForKey:keyName atService:serviceName error:error];
	
	if (*error && [*error code] != noErr) {
		return NO;
	}
	
	OSStatus status;
	
	if (!item) {
		return NO
	}
	
	CFRelease(item);
	
	return YES;
}

+ (SecKeychainItemRef)getKeychainItemReferenceForKey:(NSString *)keyName atService:(NSString *)serviceName error:(NSError **)error {
	if (!keyName || !serviceName) {
		*error = [NSError errorWithDomain:JPKeychainUtilsErrorDomain code:-2000 userInfo:nil];
		return nil;
	}
	
	*error = nil;
    
	SecKeychainItemRef item;
	
	OSStatus status = SecKeychainFindGenericPassword(NULL,
                                                     strlen([serviceName UTF8String]),
                                                     [serviceName UTF8String],
                                                     strlen([keyName UTF8String]),
                                                     [keyName UTF8String],
                                                     NULL,
                                                     NULL,
                                                     &item);
	
	if (status != noErr) {
		if (status != errSecItemNotFound) {
			*error = [NSError errorWithDomain:JPKeychainUtilsErrorDomain code:status userInfo:nil];
		}
		
		return nil;
	}
	
	return item;
}

#else

+ (NSString *)getValueForKey:(NSString *)keyName atService:(NSString *)serviceName error:(NSError **)error {
	if (!keyName || !serviceName) {
		if (error != nil) {
			*error = [NSError errorWithDomain:JPKeychainUtilsErrorDomain code:-2000 userInfo:nil];
		}
		return nil;
	}
	
	if (error != nil) {
		*error = nil;
	}
    
	// Set up a query dictionary with the base query attributes: item type (generic), username, and service
	
	NSArray *keys = [[[NSArray alloc] initWithObjects:(NSString *)kSecClass, kSecAttrAccount, kSecAttrService, nil] autorelease];
	NSArray *objects = [[[NSArray alloc] initWithObjects: (NSString *)kSecClassGenericPassword, keyName, serviceName, nil] autorelease];
	
	NSMutableDictionary *query = [[[NSMutableDictionary alloc] initWithObjects:objects forKeys:keys] autorelease];
	
	// First do a query for attributes, in case we already have a Keychain item with no password data set.
	// One likely way such an incorrect item could have come about is due to the previous (incorrect)
	// version of this code (which set the password as a generic attribute instead of password data).
	
	NSDictionary *attributeResult = NULL;
	NSMutableDictionary *attributeQuery = [query mutableCopy];
	[attributeQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnAttributes];
	OSStatus status = SecItemCopyMatching((CFDictionaryRef)attributeQuery, (CFTypeRef *)&attributeResult);
	
	[attributeResult release];
	[attributeQuery release];
	
	if (status != noErr) {
		// No existing item found--simply return nil for the password
		if (error != nil && status != errSecItemNotFound) {
			//Only return an error if a real exception happened--not simply for "not found."
			*error = [NSError errorWithDomain:JPKeychainUtilsErrorDomain code:status userInfo:nil];
		}
		
		return nil;
	}
	
	// We have an existing item, now query for the password data associated with it.
	
	NSData *resultData = nil;
	NSMutableDictionary *valueQuery = [query mutableCopy];
	[valueQuery setObject: (id)kCFBooleanTrue forKey:(id)kSecReturnData];
    
	status = SecItemCopyMatching((CFDictionaryRef) valueQuery, (CFTypeRef *)&resultData);
	
	[resultData autorelease];
	[valueQuery release];
	
	if (status != noErr) {
		if (status == errSecItemNotFound) {
			// We found attributes for the item previously, but no password now, so return a special error.
			// Users of this API will probably want to detect this error and prompt the user to
			// re-enter their credentials.  When you attempt to store the re-entered credentials
			// using storeUsername:andPassword:forServiceName:updateExisting:error
			// the old, incorrect entry will be deleted and a new one with a properly encrypted
			// password will be added.
			if (error != nil) {
				*error = [NSError errorWithDomain:JPKeychainUtilsErrorDomain code:-1999 userInfo:nil];
			}
		}
		else {
			// Something else went wrong. Simply return the normal Keychain API error code.
			if (error != nil) {
				*error = [NSError errorWithDomain:JPKeychainUtilsErrorDomain code:status userInfo:nil];
			}
		}
		
		return nil;
	}
    
	NSString *value = nil;
    
	if (resultData) {
		value = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
	}
	else {
		// There is an existing item, but we weren't able to get password data for it for some reason,
		// Possibly as a result of an item being incorrectly entered by the previous code.
		// Set the -1999 error so the code above us can prompt the user again.
		if (error != nil) {
			*error = [NSError errorWithDomain:JPKeychainUtilsErrorDomain code:-1999 userInfo:nil];
		}
	}
    
	return [value autorelease];
}

+ (BOOL)storeValue:(NSString *)value forKey:(NSString *)keyName atService:(NSString *)serviceName updateExisting:(BOOL)updateExisting error:(NSError **)error {
	if (!keyName || !value || !serviceName) {
		if (error != nil) {
			*error = [NSError errorWithDomain:JPKeychainUtilsErrorDomain code:-2000 userInfo:nil];
		}
		return NO;
	}
	
	// See if we already have a password entered for these credentials.
	NSError *getError = nil;
	NSString *existingValue = [KeyChainUtils getValueForKey:keyName atService:serviceName error:&getError];
    
	if ([getError code] == -1999) {
		// There is an existing entry without a password properly stored (possibly as a result of the previous incorrect version of this code.
		// Delete the existing item before moving on entering a correct one.
        
		getError = nil;
		
		[self deleteValueForKey:keyName atService:serviceName error:&getError];
		
		if ([getError code] != noErr) {
			if (error != nil) {
				*error = getError;
			}
			return NO;
		}
	}
	else if ([getError code] != noErr) {
		if (error != nil) {
			*error = getError;
		}
		return NO;
	}
	
	if (error != nil) {
		*error = nil;
	}
	
	OSStatus status = noErr;
	
	if (existingValue) {
		// We have an existing, properly entered item with a password.
		// Update the existing item.
		
		if (![existingValue isEqualToString:value] && updateExisting) {
			//Only update if we're allowed to update existing.  If not, simply do nothing.
			
			NSArray *keys = [[[NSArray alloc] initWithObjects:(NSString *)kSecClass, kSecAttrService, kSecAttrLabel, kSecAttrAccount, nil] autorelease];
			
			NSArray *objects = [[[NSArray alloc] initWithObjects:(NSString *)kSecClassGenericPassword, serviceName, serviceName, keyName, nil] autorelease];
			
			NSDictionary *query = [[[NSDictionary alloc] initWithObjects:objects forKeys:keys] autorelease];
			
			status = SecItemUpdate((CFDictionaryRef)query, (CFDictionaryRef)[NSDictionary dictionaryWithObject:[value dataUsingEncoding:NSUTF8StringEncoding] forKey:(NSString *)kSecValueData]);
		}
	}
	else {
		// No existing entry (or an existing, improperly entered, and therefore now
		// deleted, entry).  Create a new entry.
		
		NSArray *keys = [[[NSArray alloc] initWithObjects:(NSString *)kSecClass, kSecAttrService, kSecAttrLabel, kSecAttrAccount, kSecValueData, nil] autorelease];
		
		NSArray *objects = [[[NSArray alloc] initWithObjects:(NSString *)kSecClassGenericPassword, serviceName, serviceName, keyName, [value dataUsingEncoding: NSUTF8StringEncoding], nil] autorelease];
		
		NSDictionary *query = [[[NSDictionary alloc] initWithObjects:objects forKeys:keys] autorelease];
        
		status = SecItemAdd((CFDictionaryRef)query, NULL);
	}
	if (error != nil && status != noErr) {
		// Something went wrong with adding the new item. Return the Keychain error code.
		*error = [NSError errorWithDomain:JPKeychainUtilsErrorDomain code:status userInfo:nil];
		return NO;
	}
    
	return YES;
}

+ (BOOL)deleteValueForKey:(NSString *)keyName atService:(NSString *)serviceName error:(NSError **)error
{
	if (!keyName || !serviceName) {
		if (error != nil) {
			*error = [NSError errorWithDomain:JPKeychainUtilsErrorDomain code:-2000 userInfo:nil];
		}
		return NO;
	}
	
	if (error != nil) {
		*error = nil;
	}
    
    if (![KeyChainUtils isValueExistingForKey:keyName atService:serviceName error:nil]) return YES;
    
	NSArray *keys = [[[NSArray alloc] initWithObjects:(NSString *)kSecClass, kSecAttrAccount, kSecAttrService, kSecReturnAttributes, nil] autorelease];
	NSArray *objects = [[[NSArray alloc] initWithObjects:(NSString *)kSecClassGenericPassword, keyName, serviceName, kCFBooleanTrue, nil] autorelease];
	
	NSDictionary *query = [[[NSDictionary alloc] initWithObjects:objects forKeys:keys] autorelease];
	
	OSStatus status = SecItemDelete((CFDictionaryRef) query);
	
	if (error != nil && status != noErr) {
		*error = [NSError errorWithDomain:JPKeychainUtilsErrorDomain code:status userInfo:nil];
        
		return NO;
	}
	
	return YES;
}

+ (BOOL)isValueExistingForKey:(NSString *)keyName atService:(NSString *)serviceName error:(NSError **)error {
	if (!keyName || !serviceName) {
		if (error != nil) {
			*error = [NSError errorWithDomain:JPKeychainUtilsErrorDomain code:-2000 userInfo:nil];
		}
		return NO;
	}
	
	if (error != nil) {
		*error = nil;
	}
	
	// Set up a query dictionary with the base query attributes: item type (generic), username, and service
	
	NSArray *keys = [[[NSArray alloc] initWithObjects:(NSString *)kSecClass, kSecAttrAccount, kSecAttrService, nil] autorelease];
	NSArray *objects = [[[NSArray alloc] initWithObjects: (NSString *)kSecClassGenericPassword, keyName, serviceName, nil] autorelease];
	
	NSMutableDictionary *query = [[[NSMutableDictionary alloc] initWithObjects:objects forKeys:keys] autorelease];
	
	// First do a query for attributes, in case we already have a Keychain item with no password data set.
	// One likely way such an incorrect item could have come about is due to the previous (incorrect)
	// version of this code (which set the password as a generic attribute instead of password data).
	
	NSDictionary *attributeResult = NULL;
	NSMutableDictionary *attributeQuery = [query mutableCopy];
	[attributeQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnAttributes];
	OSStatus status = SecItemCopyMatching((CFDictionaryRef)attributeQuery, (CFTypeRef *)&attributeResult);
	
	[attributeResult release];
	[attributeQuery release];
	
	if (status != noErr) {
		// No existing item found--simply return nil for the password
		if (error != nil && status != errSecItemNotFound) {
			//Only return an error if a real exception happened--not simply for "not found."
			*error = [NSError errorWithDomain:JPKeychainUtilsErrorDomain code:status userInfo:nil];
		}
		
		return NO;
	}
	
	// We have an existing item, now query for the password data associated with it.
	
	NSData *resultData = nil;
	NSMutableDictionary *valueQuery = [query mutableCopy];
	[valueQuery setObject: (id)kCFBooleanTrue forKey:(id)kSecReturnData];
	
	status = SecItemCopyMatching((CFDictionaryRef) valueQuery, (CFTypeRef *)&resultData);
	
	[resultData autorelease];
	[valueQuery release];
	
	if (status != noErr) {
		if (status == errSecItemNotFound) {
			// We found attributes for the item previously, but no password now, so return a special error.
			// Users of this API will probably want to detect this error and prompt the user to
			// re-enter their credentials.  When you attempt to store the re-entered credentials
			// using storeUsername:andPassword:forServiceName:updateExisting:error
			// the old, incorrect entry will be deleted and a new one with a properly encrypted
			// password will be added.
			if (error != nil) {
				*error = [NSError errorWithDomain:JPKeychainUtilsErrorDomain code:-1999 userInfo:nil];
			}
		}
		else {
			// Something else went wrong. Simply return the normal Keychain API error code.
			if (error != nil) {
				*error = [NSError errorWithDomain:JPKeychainUtilsErrorDomain code:status userInfo:nil];
			}
		}
		
		return NO;
	}
    
	if (!resultData) {
		return NO;
	}
    
	return YES;
}

#endif


@end
