
#import <UIKit/UIKit.h>

typedef enum{
    
    //设置密码
    CoreLockTypeSetPwd=0,
    
    //输入并验证密码
    CoreLockTypeVeryfiPwd,
    
    //修改密码
    CoreLockTypeModifyPwd,
    
    //登录时验证密码
    CoreLockTypeLogInVeryfiPwd,
    
}CoreLockType;



@interface CLLockVC : UIViewController

@property (nonatomic,assign) CoreLockType type;

/*
 *  是否有本地密码缓存？即用户是否设置过初始密码？
 */
+(BOOL)hasPwd;

/*
 *  展示设置密码控制器
 */
+(instancetype)showSettingLockVCInVC:(UIViewController *)vc successBlock:(void(^)(CLLockVC *lockVC, NSString *pwd))successBlock;

/*
 *  展示验证密码输入框
 */
+(instancetype)showVerifyLockVCInVC:(UIViewController *)vc isLogIn:(BOOL)isLogIn forgetPwdBlock:(void(^)())forgetPwdBlock successBlock:(void(^)(CLLockVC *lockVC, NSString *pwd))successBlock;

/*
 *  展示验证密码输入框
 */
+(instancetype)showModifyLockVCInVC:(UIViewController *)vc successBlock:(void(^)(CLLockVC *lockVC, NSString *pwd))successBlock;

/*
 *  消失
 */
-(void)dismiss:(NSTimeInterval)interval;


@end
