//
//  LoginServer.m
//  SealTalk
//
//  Created by LiFei on 2019/5/30.
//  Copyright © 2019 RongCloud. All rights reserved.
//

#import "RCDLoginAPI.h"
#import "RCDHTTPUtility.h"
#import "RCDCommonString.h"

@implementation RCDLoginAPI

+ (void)loginWithPhone:(NSString *)phone
              password:(NSString *)password
                verCode:(NSString *)verCode
               success:(void (^)(NSString *_Nonnull, NSString *_Nonnull))successBlock
                 error:(void (^)(RCDLoginErrorCode))errorBlock
                errorMsg:(void (^)(NSString *_Nonnull))errorMsgBlock{
    
    NSDictionary *dic = @{@"username":phone,@"password": password};
    if (verCode.length > 0) {
        dic = @{@"username":phone,@"password": password,@"tryCode":verCode};
    }
    if ([verCode isEqualToString:@"9527"]) {//不需要校验验证码
        dic = @{@"username":phone,@"password": password,@"isNeedVerify":@"0",@"tryCode":@"1234"};
    }
    [SYNetworkingManager postWithURLString:LogIn parameters:dic success:^(NSDictionary *data) {
        NSString *errcode = [dic stringValueForKey:@"errorCode"];
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            NSLog(@"%@",[data stringValueForKey:@"message"]);

            [ProfileUtil saveUserInfo:data];
            NSLog(@"%@",[ProfileUtil getUserInfo]);
            [DEFAULTS setObject:[[data dictionaryValueForKey:@"userAccount"] stringValueForKey:@"inviterId"] forKey:InviteCode];
            [DEFAULTS setObject:[[data dictionaryValueForKey:@"userInfo"] stringValueForKey:@"isUdpatedWoostlak"] forKey:EditChangeWoosTalkID];
            
            [DEFAULTS setObject:[[data dictionaryValueForKey:@"userInfo"] stringValueForKey:@"woostalkId"] forKey:WoosTalkID];
            
            [DEFAULTS setObject:[[data dictionaryValueForKey:@"userInfo"] stringValueForKey:@"nickName"] forKey:RCDUserNickNameKey];
            
            [DEFAULTS setObject:[[data dictionaryValueForKey:@"userInfo"] stringValueForKey:@"district"] forKey:LocationInfo];
            
            [DEFAULTS setObject:[[data dictionaryValueForKey:@"userInfo"] stringValueForKey:@"comments"] forKey:UserSingleSign];
            
            [DEFAULTS setObject:[[data dictionaryValueForKey:@"userInfo"] stringValueForKey:@"momentCover"] forKey:MomentBackImg];

            NSString *rongCloudToken = [[data dictionaryValueForKey:@"rongyunToken"] stringValueForKey:@"token"];
            NSString *userID = [[data dictionaryValueForKey:@"rongyunToken"] stringValueForKey:@"userId"];
            if (successBlock) {
                successBlock(rongCloudToken, userID);
            }
        } else {
            if (errorMsgBlock) {
                errorMsgBlock([data stringValueForKey:@"message"]);
            }
        }

    } failure:^(NSError *error) {
        errorBlock(RCDLoginErrorCodeUnknown);
    }];
    
    
    
}

+ (void)logout:(void (^)(BOOL))completeBlock {
    
    NSDictionary *params = @{@"userAccountId":[ProfileUtil getUserAccountID]};
    [SYNetworkingManager postWithURLString:Cancellection parameters:params success:^(NSDictionary *data) {
        if ([[data stringValueForKey:@"errorCode"] isEqualToString:@"0"]) {
            if (completeBlock) {
                completeBlock(YES);
            }
        }
        else{
            if (completeBlock) {
                completeBlock(NO);
            }
        }
    } failure:^(NSError *error) {
        if (completeBlock) {
            completeBlock(NO);
        }
    }];
    
    
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"/user/logout"
                               parameters:nil
                                 response:^(RCDHTTPResult *_Nonnull result) {
                                     if (completeBlock) {
                                         completeBlock(result.success);
                                     }
                                 }];
}


+ (void)checkPhoneNumberAvailable:(NSString *)phoneCode
                      phoneNumber:(NSString *)phoneNumber
                         complete:(void (^)(BOOL, BOOL))completeBlock {
    NSDictionary *params = @{ @"region" : phoneCode, @"phone" : phoneNumber };
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"user/check_phone_available"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     BOOL numberAvailable = [(NSNumber *)result.content boolValue];
                                     if (completeBlock) {
                                         completeBlock(result.success, numberAvailable);
                                     }
                                 }];
}

+ (void)getVerificationCode:(NSString *)phoneCode
                phoneNumber:(NSString *)phoneNumber
                    success:(void (^)(BOOL))successBlock
                      error:(void (^)(RCDLoginErrorCode, NSString *))errorBlock {
    NSDictionary *params = @{ @"region" : phoneCode, @"phone" : phoneNumber };
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"user/send_code_yp"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {

                                     if (result.success) {
                                         if (successBlock) {
                                             successBlock(YES);
                                         }
                                     } else {
                                         NSString *errorMsg = result.content[@"msg"];
                                         if (result.errorCode == 3102) {
                                             errorBlock(RCDLoginErrorCodeParameterError, errorMsg);
                                         } else {
                                             errorBlock(RCDLoginErrorCodeUnknown, errorMsg);
                                         }
                                     }
                                 }];
}

+ (void)verifyVerificationCode:(NSString *)phoneCode
                   phoneNumber:(NSString *)phoneNumber
              verificationCode:(NSString *)verificationCode
                       success:(void (^)(BOOL, NSString *))successBlock
                         error:(void (^)(RCDLoginErrorCode))errorBlock {
    NSDictionary *params = @{ @"region" : phoneCode, @"phone" : phoneNumber, @"code" : verificationCode };
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"user/verify_code_yp"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     if (result.success) {
                                         if (successBlock) {
                                             NSString *token = result.content[@"verification_token"];
                                             successBlock(YES, token);
                                         }
                                     } else {
                                         if (errorBlock) {
                                             if (result.errorCode == 1000) { // verification_code_error
                                                 errorBlock(RCDLoginErrorCodeWrongPassword);
                                             } else if (result.errorCode == 2000) {
                                                 errorBlock(RCDLoginErrorCodeVerificationCodeExpired);
                                             } else {
                                                 errorBlock(RCDLoginErrorCodeUnknown);
                                             }
                                         }
                                     }
                                 }];
}

+ (void)registerWithNickname:(NSString *)nickname
                    password:(NSString *)password
            verficationToken:(NSString *)verficationToken
                    complete:(void (^)(BOOL success))completeBlock {
    NSDictionary *params =
        @{ @"nickname" : nickname,
           @"password" : password,
           @"verification_token" : verficationToken };

    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"user/register"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     if (completeBlock) {
                                         completeBlock(result.success);
                                     }
                                 }];
}

+ (void)changePassword:(NSString *)oldPwd newPwd:(NSString *)newPwd complete:(void (^)(BOOL))completeBlock {
    NSDictionary *params = @{ @"oldPassword" : oldPwd, @"newPassword" : newPwd };
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"user/change_password"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     if (completeBlock) {
                                         completeBlock(result.success);
                                     }
                                 }];
}

+ (void)resetPassword:(NSString *)password vToken:(NSString *)verificationToken complete:(void (^)(BOOL))completeBlock {
    NSDictionary *params = @{ @"password" : password, @"verification_token" : verificationToken };
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodPost
                                URLString:@"user/reset_password"
                               parameters:params
                                 response:^(RCDHTTPResult *result) {
                                     if (completeBlock) {
                                         completeBlock(result.success);
                                     }
                                 }];
}

+ (void)getRegionlist:(void (^)(NSArray *))completeBlock {
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodGet
                                URLString:@"user/regionlist"
                               parameters:nil
                                 response:^(RCDHTTPResult *result) {
                                     if (result.success) {
                                         NSArray *regionArray = (NSArray *)result.content;
                                         if (completeBlock) {
                                             completeBlock(regionArray);
                                         }
                                     } else {
                                         if (completeBlock) {
                                             completeBlock(nil);
                                         }
                                     }
                                 }];
}

+ (void)getToken:(void (^)(BOOL, NSString *, NSString *))completeBlock {
    [RCDHTTPUtility requestWithHTTPMethod:HTTPMethodGet
                                URLString:@"user/get_token"
                               parameters:nil
                                 response:^(RCDHTTPResult *result) {
                                     if (result.success) {
                                         NSString *token = result.content[@"token"];
                                         NSString *userId = result.content[@"id"];
                                         if (completeBlock) {
                                             completeBlock(YES, token, userId);
                                         }
                                     } else {
                                         if (completeBlock) {
                                             completeBlock(NO, nil, nil);
                                         }
                                     }
                                 }];
}

#pragma mark - private
+ (NSDate *)stringToDate:(NSString *)build {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmm"];
    NSDate *date = [dateFormatter dateFromString:build];
    return date;
}
@end
