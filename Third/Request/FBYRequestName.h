//
//  FBYRequestName.h
//  SealTalk
//
//  Created by zhangzhendong on 2020/3/21.
//  Copyright © 2020 RongCloud. All rights reserved.
//



#define SendVerCode             @"/userAccount/sendSms"                 //发送验证码
#define Register                @"/userAccount/register"                //注册
#define LogIn                   @"/userAccount/login"                   //登录
#define FinePassword            @"/userAccount/updateUserPassword"      //找回密码
#define ReceiveInvite           @"/userAccount/getMyInviterId"          //获取邀请码
#define GetInfo                 @"/userInfo/getUserInfo"                //获取个人信息（我和他人）
#define UpdateMyInfo            @"/userInfo/updateMyUserInfo"           //修改个人信息
#define AddFriend               @"/friend/addFriend"                    //添加好友
#define FriendList              @"/friend/getMyFriend"                  //获取通讯录
#define ApplyRecord             @"/friend/getFriendApplyLog"            //申请记录
#define SearchFriend            @"/friend/searchFriendByTelphone"       //搜索好友
#define CheckFriend             @"/friend/updateFriendStatus"           //审核好友
#define DeleteFriend            @"/friend/delFriend"                    //删除好友
#define CreateGroup             @"/group/create"                        //新建群组
#define DeleteGroup             @"/group/del"                           //解散群租
#define DeleteBetchFriend       @"/friend/batch/delFriend"              //批量删除好友
#define GetGroupInfo            @"/group/getGroupInfo"                  //获取当前群租信息
#define GetGroupMembers         @"/group/member/get/allMember"          //获取群成员信息
#define GetQiniu                @"/qiniu/token/getEasyUploadToken"      //获取七牛token
#define ActiveInviteCode        @"/userAccount/updateInviterId"         //激活邀请码
#define AddBlackList            @"/friend/blacklist/add"                //添加黑名单
#define RemoveBlackList         @"/friend/blacklist/delBlackUser"       //移出黑名单
#define AcceptFriends           @"/friend/updateFriendsStatus"          //一键同意
#define GetAllGroups            @"/group/getAllGroups"                  //获取所有群组
#define AddGroupMember          @"/group/member/add/groupMember"        //群组添加成员
#define RemoveGroupMember       @"/group/member/del/groupMember"        //移除成员
#define UpdateGroupMaster       @"/group/member/update/groupMaster"     //群主转让
#define RemoveGroupManager      @"/group/member/del/groupManager"       //移除群管理员
#define AddGroupManager         @"/group/member/update/groupManager"    //添加群管理员
#define GetGroupManagers        @"/group/member/getAllGroupManager"     //获取管理员列表
#define ChangeGroupInfo         @"/group/update"                        //更改群信息
#define ChangeMyInfoInGroup     @"/group/member/update/myMemberNickName"//更改我在群里的信息
#define ExitGroup               @"/group/member/quitGroup"              //退群
#define DelGroup                @"/group/del"                           //解散群
#define GetMailList             @"/friend/getMyFriend"                  //获取通讯录好友
#define GetLeaveGroupList       @"/group/member/getLeaveGroupMembers"   //获取退群成员
#define AddFriendsRequest       @"/group/member/update/addFriendsInGroup"//一键加好友请求
#define ChangeGroupSetting      @"/group/member/update/groupMemberInfo" //更改群勿扰置顶等
#define ChangeFriendInfo        @"/friend/update/AdditionalInformation" //更改好友信息
#define BlackList               @"/friend/blacklist/allBlackList"       //黑名单列表
#define GroupMute               @"/group/updateGroupBanTalk"            //群禁言
#define CopyGroup               @"/group/member/update/copyToNewGroup"  //复制到新群
#define GetLabelInfo            @"/label/getOneLabel"                   //获取标签内容
#define CreateLabel             @"/label/add"                           //创建标签
#define GetAllLabels            @"/label/getAllLabel"                   //获取所有标签
#define DeleteLabel             @"/label/del"                           //删除标签
#define EditLabelInfo           @"/label/update"                        //更改标签内容
#define RechargeInfo            @"/payment/specifications/getAllMoment" //充值信息
#define AppConfig               @"/app/global/config/getAllConfig"      //全局配置
#define SetSeting               @"/user/settings/updateUserSetting"     //更改设置
#define GetPhoneAllUser         @"/friend/allPhoneUser"                 //获取所有手机通讯录好友
#define GetProvenceInfo         @"/location/provience/getAllProviences" //获取省份信息
#define GetCityInfo             @"/location/city/getAllCitys"           //获取城市信息
#define GetXianInfo             @"/location/district/getAllDistricts"   //获取区县信息
#define GetUserAllInfo          @"/friend/allFriendInfo"                //获取该好友的全部信息


#define Cancellection           @"/userAccount/loginout"                //注销
#define ResetDisturb            @"/friend/update/friend/info"           //更改好友打扰、置顶
#define Salesman                @"/admin/user/list/salesman"            //获取销售人员列表
#define AddSaleman              @"/admin/user/add/salesman"             //添加销售人员
#define AdminLogin              @"/admin/admin/user/login"              //管理员登录

#define GetMomentData           @"/moment/detail/getAllMoment"          //获取朋友圈数据
#define GetMomentData           @"/moment/detail/getAllMoment"          //获取朋友圈数据
#define DeleteDisucuss          @"/moment/discuss/reply/deleteDisucuss" //删除评论
#define DiscussOrReply          @"/moment/discuss/reply/create/discussOrReply"  //评论
#define LikeOrDisLike           @"/moment/like/likeOrDisLike"           //点赞
#define DelFriendInfo           @"/moment/detail/del"                   //删除动态
#define CreatFrindInfo          @"/moment/detail/create"                //发布朋友圈
#define GetOtherMoments         @"/moment/detail/getMyMomentLog"        //获取朋友圈动态
#define GetMomentDetail         @"/moment/detail/getOneMomentDetail"    //获取动态详情
#define GetMomentMsg            @"/moment/opt/getMyMomentOpt"           //获取互动消息
#define ClearMomentMsg          @"/moment/opt/delAllOpt"                //清空互动消息列表


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FBYRequestName : NSObject

@end

NS_ASSUME_NONNULL_END
