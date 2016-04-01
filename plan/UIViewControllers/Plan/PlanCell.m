//
//  PlanCell.m
//  plan
//
//  Created by Fengzy on 15/9/12.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "PlanCell.h"


NSUInteger const kPlanCellHeight = 60;
NSUInteger const kBounceSpace = 20;

@implementation PlanCell {
    
    UIButton *btnDone;
    UILabel *labelContent;
    UILabel *labelBeginDate;
    UILabel *labelDateLeft;
    UIImageView *imgViewAlarm;
}

@synthesize plan = _plan;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        if (_moveContentView == nil) {
            _moveContentView = [[UIView alloc] init];
            _moveContentView.backgroundColor = [UIColor whiteColor];
        }
        [self.contentView addSubview:_moveContentView];
        [self setBackgroundColor:[UIColor whiteColor]];
        [self addControl];
    }
    return self;
}

- (void)awakeFromNib {
    [self addControl];
}

- (void)addControl {
    UIView *menuContetnView = [[UIView alloc] init];
    menuContetnView.hidden = YES;
    menuContetnView.tag = 100;

    UIButton *vBtnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    [vBtnDone setAllBackgroundImage:[UIImage imageNamed:png_Btn_Plan_Done]];
    [vBtnDone addTarget:self action:@selector(btnDoneAction:) forControlEvents:UIControlEventTouchUpInside];
    [vBtnDone setTag:1001];
    btnDone = vBtnDone;
    
    UIButton *vBtnDelete = [UIButton buttonWithType:UIButtonTypeCustom];
    [vBtnDelete setAllBackgroundImage:[UIImage imageNamed:png_Btn_Plan_Delete]];
    [vBtnDelete addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [vBtnDelete setTag:1002];

    labelContent = [[UILabel alloc] initWithFrame:CGRectMake(kEdgeInset, 0, WIDTH_FULL_SCREEN - kEdgeInset * 2, kPlanCellHeight)];
    labelContent.textColor = color_333333;
    [labelContent setFont:font_Normal_20];
    [labelContent setNumberOfLines:1];
    [labelContent setBackgroundColor:[UIColor clearColor]];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didContentClicked:)];
    [labelContent addGestureRecognizer:tapGestureRecognizer];
    labelContent.userInteractionEnabled = YES;
    
    imgViewAlarm = [[UIImageView alloc] initWithFrame:CGRectMake(WIDTH_FULL_SCREEN - kEdgeInset * 2 - kPlanCellHeight / 3, kPlanCellHeight / 6, kPlanCellHeight / 3, kPlanCellHeight / 3)];
    imgViewAlarm.image = [UIImage imageNamed:png_Icon_Alarm];
    imgViewAlarm.hidden = YES;
    [labelContent addSubview:imgViewAlarm];
    
    UILabel *labelDate = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 15)];
    labelDate.textColor = color_666666;
    labelDate.font = font_Normal_10;
    labelBeginDate = labelDate;
    [labelContent addSubview:labelDate];
    
    UILabel *labelDateleft = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, 60, 15)];
    labelDateleft.backgroundColor = color_e9eff1;
    labelDateleft.textColor = color_ff0000_06;
    labelDateleft.textAlignment = NSTextAlignmentCenter;
    labelDateleft.font = font_Normal_10;
    labelDateleft.clipsToBounds = YES;
    labelDateleft.layer.cornerRadius = 7.5;
    labelDateLeft = labelDateleft;
    [labelContent addSubview:labelDateleft];
    
    [menuContetnView addSubview:vBtnDone];
    [menuContetnView addSubview:vBtnDelete];
    [_moveContentView addSubview:labelContent];
    [self.contentView insertSubview:menuContetnView atIndex:0];
    
    UIPanGestureRecognizer *vPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    vPanGesture.delegate = self;
    [self.contentView addGestureRecognizer:vPanGesture];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [_moveContentView setFrame:CGRectMake(0, 0, WIDTH_FULL_SCREEN, self.frame.size.height)];
    UIView *vMenuView = [self.contentView viewWithTag:100];
    vMenuView.frame =CGRectMake(WIDTH_FULL_SCREEN - kPlanCellHeight * 2, 0, kPlanCellHeight * 2, self.frame.size.height);
    
    UIView *vBtnDone = [self.contentView viewWithTag:1001];
    vBtnDone.frame = CGRectMake(kPlanCellHeight, 0, kPlanCellHeight, self.frame.size.height);
    UIView *vMoreButton = [self.contentView viewWithTag:1002];
    vMoreButton.frame = CGRectMake(0, 0, kPlanCellHeight, self.frame.size.height);
    UIView *vBtnDoneNew = [self.contentView viewWithTag:1003];
    vBtnDoneNew.frame = CGRectMake(0, 10, 40, 40);
}

//此方法和下面的方法很重要,对ios 5SDK 设置不被Helighted
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    UIView *vMenuView = [self.contentView viewWithTag:100];
    if (vMenuView.hidden == YES) {
        [super setSelected:selected animated:animated];
    }
}

//此方法和上面的方法很重要，对ios 5SDK 设置不被Helighted
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    UIView *vMenuView = [self.contentView viewWithTag:100];
    if (vMenuView.hidden == YES) {
        [super setHighlighted:highlighted animated:animated];
    }
}

- (void)prepareForReuse {
    self.contentView.clipsToBounds = YES;
    [self hideMenuView:YES Animated:NO];
}

- (CGFloat)getMaxMenuWidth {
    return kPlanCellHeight * 2;
}

- (void)enableSubviewUserInteraction:(BOOL)enable {
    if (enable) {
        for (UIView *aSubView in self.contentView.subviews) {
            aSubView.userInteractionEnabled = YES;
        }
    } else {
        for (UIView *aSubView in self.contentView.subviews) {
            UIView *vBtnDoneView = [self.contentView viewWithTag:100];
            if (aSubView != vBtnDoneView) {
                aSubView.userInteractionEnabled = NO;
            }
        }
    }
}

- (void)hideMenuView:(BOOL)hidden Animated:(BOOL)animated {
    if (self.selected) {
        [self setSelected:NO animated:NO];
    }
    CGRect vDestinaRect = CGRectZero;
    if (hidden) {
        vDestinaRect = self.contentView.frame;
        [self enableSubviewUserInteraction:YES];
    } else {
        vDestinaRect = CGRectMake(-[self getMaxMenuWidth], self.contentView.frame.origin.x, self.contentView.frame.size.width, self.contentView.frame.size.height);
        [self enableSubviewUserInteraction:NO];
    }
    
    CGFloat vDuration = animated ? 0.4 : 0.0;
    [UIView animateWithDuration:vDuration animations: ^{
        _moveContentView.frame = vDestinaRect;
    } completion:^(BOOL finished) {
        if (hidden) {
            if ([_delegate respondsToSelector:@selector(didCellHided:)]) {
                [_delegate didCellHided:self];
            }
        } else {
            if ([_delegate respondsToSelector:@selector(didCellShowed:)]) {
                [_delegate didCellShowed:self];
            }
        }
        UIView *vMenuView = [self.contentView viewWithTag:100];
        vMenuView.hidden = hidden;
    }];
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        CGPoint vTranslationPoint = [gestureRecognizer translationInView:self.contentView];
        return fabs(vTranslationPoint.x) > fabs(vTranslationPoint.y);
    }
    return YES;
}

- (void)handlePan:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        startLocation = [sender locationInView:self.contentView].x;
        CGFloat direction = [sender velocityInView:self.contentView].x;
        if (direction < 0) {
            if ([_delegate respondsToSelector:@selector(didCellWillShow:)]) {
                [_delegate didCellWillShow:self];
            }
        } else {
            if ([_delegate respondsToSelector:@selector(didCellWillHide:)]) {
                [_delegate didCellWillHide:self];
            }
        }
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        CGFloat vCurrentLocation = [sender locationInView:self.contentView].x;
        CGFloat vDistance = vCurrentLocation - startLocation;
        startLocation = vCurrentLocation;
        
        CGRect vCurrentRect = _moveContentView.frame;
        CGFloat vOriginX = MAX(-[self getMaxMenuWidth] - kBounceSpace, vCurrentRect.origin.x + vDistance);
        vOriginX = MIN(0 + kBounceSpace, vOriginX);
        _moveContentView.frame = CGRectMake(vOriginX, vCurrentRect.origin.y, vCurrentRect.size.width, vCurrentRect.size.height);
        
        CGFloat direction = [sender velocityInView:self.contentView].x;

        if (direction < - 30.0 || vOriginX <  - (0.5 * [self getMaxMenuWidth])) {
            hideMenuView = NO;
            UIView *vMenuView = [self.contentView viewWithTag:100];
            vMenuView.hidden = hideMenuView;
        } else if (direction > 20.0 || vOriginX >  - (0.5 * [self getMaxMenuWidth])) {
            hideMenuView = YES;
        }
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        [self hideMenuView:hideMenuView Animated:YES];
    }
}

- (void)setPlan:(Plan *)plan {
    _plan = plan;
    labelContent.text = plan.content;
    NSDate *beginDate = [CommonFunction NSStringDateToNSDate:plan.beginDate formatter:str_DateFormatter_yyyy_MM_dd];
    if ([plan.iscompleted isEqualToString:@"0"]
        && [beginDate compare:[NSDate date]] == NSOrderedDescending) {
        labelBeginDate.text = [CommonFunction getBeginDateStringForShow:plan.beginDate];
        labelDateLeft.text = [NSString stringWithFormat:str_Common_Time10,[CommonFunction howManyDaysLeft:plan.beginDate]];
        labelDateLeft.hidden = NO;
    } else {
        labelDateLeft.hidden = YES;
    }
    if ([plan.isnotify isEqualToString:@"1"]) {
        imgViewAlarm.hidden = NO;
    } else {
        imgViewAlarm.hidden = YES;
    }
}

- (void)setIsDone:(NSString *)isDone {
    if ([isDone isEqualToString:@"1"]) {
        [btnDone setAllBackgroundImage:[UIImage imageNamed:png_Btn_Plan_Doing]];
    } else {
        [btnDone setAllBackgroundImage:[UIImage imageNamed:png_Btn_Plan_Done]];
    }
}

- (void)didContentClicked:(id)sender {
    if ([_delegate respondsToSelector:@selector(didCellClicked:)]) {
        [_delegate didCellClicked:self];
    }
}

- (void)deleteButtonClicked:(id)sender {
    if ([_delegate respondsToSelector:@selector(didCellClickedDeleteButton:)]) {
        [_delegate didCellClickedDeleteButton:self];
    }
}

- (IBAction)btnDoneAction:(id)sender {
    [self.superview sendSubviewToBack:self];
    if ([_delegate respondsToSelector:@selector(didCellClickedDoneButton:)]) {
        [_delegate didCellClickedDoneButton:self];
    }
}

@end
