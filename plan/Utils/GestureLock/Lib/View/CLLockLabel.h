
#import <UIKit/UIKit.h>

@interface CLLockLabel : UILabel

/*
 *  普通提示信息
 */
- (void)showNormalMsg:(NSString *)msg;

/*
 *  警示信息
 */
- (void)showWarnMsg:(NSString *)msg;

@end
