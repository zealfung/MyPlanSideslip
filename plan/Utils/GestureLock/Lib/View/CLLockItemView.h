
#import <UIKit/UIKit.h>


typedef enum {
    
    //正上
    LockItemViewDirecTop=1,
    
    //右上
    LockItemViewDirecRightTop,
    
    //右
    LockItemViewDirecRight,
    
    //右下
    LockItemViewDiretRightBottom,
    
    //下
    LockItemViewDirecBottom,
    
    //左下
    LockItemViewDirecLeftBottom,
    
    //左
    LockItemViewDirecLeft,
    
    //左上
    LockItemViewDirecLeftTop,

}LockItemViewDirect;


@interface CLLockItemView : UIView

/** 是否选中 */
@property (nonatomic,assign) BOOL selected;

/** 方向 */
@property (nonatomic,assign) LockItemViewDirect direct;

@end
