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

@interface PlanCell ()

@property (nonatomic, strong) UIButton *btnDone;
@property (nonatomic, strong) UILabel *labelContent;
@property (nonatomic, strong) UILabel *labelBeginDate;
@property (nonatomic, strong) UILabel *labelDateLeft;
@property (nonatomic, strong) UIImageView *imgViewAlarm;
@property (nonatomic, assign) CGFloat startLocation;
@property (nonatomic, assign) BOOL hideMenuView;

@end

@implementation PlanCell

@synthesize plan = _plan;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        if (self.moveContentView == nil)
        {
            self.moveContentView = [[UIView alloc] init];
            self.moveContentView.backgroundColor = [UIColor whiteColor];
        }
        [self.contentView addSubview:self.moveContentView];
        [self setBackgroundColor:[UIColor whiteColor]];
        [self addControl];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self addControl];
}

- (void)addControl
{
    UIView *menuContetnView = [[UIView alloc] init];
    menuContetnView.hidden = YES;
    menuContetnView.tag = 100;

    UIButton *btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDone setAllBackgroundImage:[UIImage imageNamed:png_Btn_Plan_Done]];
    [btnDone addTarget:self action:@selector(btnDoneAction:) forControlEvents:UIControlEventTouchUpInside];
    [btnDone setTag:1001];
    self.btnDone = btnDone;
    
    UIButton *btnDelete = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDelete setAllBackgroundImage:[UIImage imageNamed:png_Btn_Plan_Delete]];
    [btnDelete addTarget:self action:@selector(btnDeleteAction:) forControlEvents:UIControlEventTouchUpInside];
    [btnDelete setTag:1002];

    self.labelContent = [[UILabel alloc] initWithFrame:CGRectMake(kEdgeInset, 0, WIDTH_FULL_SCREEN - kEdgeInset * 2, kPlanCellHeight)];
    self.labelContent.textColor = color_333333;
    [self.labelContent setFont:font_Normal_20];
    [self.labelContent setNumberOfLines:1];
    [self.labelContent setBackgroundColor:[UIColor clearColor]];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didContentClicked:)];
    [self.labelContent addGestureRecognizer:tapGestureRecognizer];
    self.labelContent.userInteractionEnabled = YES;
    
    self.imgViewAlarm = [[UIImageView alloc] initWithFrame:CGRectMake(WIDTH_FULL_SCREEN - kEdgeInset * 2 - kPlanCellHeight / 3, kPlanCellHeight / 6, kPlanCellHeight / 3, kPlanCellHeight / 3)];
    self.imgViewAlarm.image = [UIImage imageNamed:png_Icon_Alarm];
    self.imgViewAlarm.hidden = YES;
    [self.labelContent addSubview:self.imgViewAlarm];
    
    UILabel *labelDate = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 15)];
    labelDate.textColor = color_666666;
    labelDate.font = font_Normal_10;
    self.labelBeginDate = labelDate;
    [self.labelContent addSubview:labelDate];
    
    UILabel *labelDateleft = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, 60, 15)];
    labelDateleft.backgroundColor = color_e9eff1;
    labelDateleft.textColor = color_ff0000_06;
    labelDateleft.textAlignment = NSTextAlignmentCenter;
    labelDateleft.font = font_Normal_10;
    labelDateleft.clipsToBounds = YES;
    labelDateleft.layer.cornerRadius = 7.5;
    self.labelDateLeft = labelDateleft;
    [self.labelContent addSubview:labelDateleft];
    
    [menuContetnView addSubview:btnDone];
    [menuContetnView addSubview:btnDelete];
    [self.moveContentView addSubview:self.labelContent];
    [self.contentView insertSubview:menuContetnView atIndex:0];
    
    UIPanGestureRecognizer *vPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    vPanGesture.delegate = self;
    [self.contentView addGestureRecognizer:vPanGesture];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    [self.moveContentView setFrame:CGRectMake(0, 0, WIDTH_FULL_SCREEN, self.frame.size.height)];
    UIView *menuView = [self.contentView viewWithTag:100];
    menuView.frame =CGRectMake(WIDTH_FULL_SCREEN - kPlanCellHeight * 2, 0, kPlanCellHeight * 2, self.frame.size.height);
    
    UIView *btnDone = [self.contentView viewWithTag:1001];
    btnDone.frame = CGRectMake(kPlanCellHeight, 0, kPlanCellHeight, self.frame.size.height);
    UIView *btnDelete = [self.contentView viewWithTag:1002];
    btnDelete.frame = CGRectMake(0, 0, kPlanCellHeight, self.frame.size.height);
    UIView *vbtnDoneNew = [self.contentView viewWithTag:1003];
    vbtnDoneNew.frame = CGRectMake(0, 10, 40, 40);
}

//此方法和下面的方法很重要,对ios 5SDK 设置不被Helighted
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    UIView *vMenuView = [self.contentView viewWithTag:100];
    if (vMenuView.hidden == YES)
    {
        [super setSelected:selected animated:animated];
    }
}

//此方法和上面的方法很重要，对ios 5SDK 设置不被Helighted
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    UIView *vMenuView = [self.contentView viewWithTag:100];
    if (vMenuView.hidden == YES)
    {
        [super setHighlighted:highlighted animated:animated];
    }
}

- (void)prepareForReuse
{
    self.contentView.clipsToBounds = YES;
    [self hideMenuView:YES Animated:NO];
}

- (CGFloat)getMaxMenuWidth
{
    return kPlanCellHeight * 2;
}

- (void)enableSubviewUserInteraction:(BOOL)enable
{
    if (enable)
    {
        for (UIView *aSubView in self.contentView.subviews)
        {
            aSubView.userInteractionEnabled = YES;
        }
    }
    else
    {
        for (UIView *aSubView in self.contentView.subviews)
        {
            UIView *vBtnDoneView = [self.contentView viewWithTag:100];
            if (aSubView != vBtnDoneView)
            {
                aSubView.userInteractionEnabled = NO;
            }
        }
    }
}

- (void)hideMenuView:(BOOL)hidden Animated:(BOOL)animated
{
    if (self.selected)
    {
        [self setSelected:NO animated:NO];
    }
    CGRect vDestinaRect = CGRectZero;
    if (hidden)
    {
        vDestinaRect = self.contentView.frame;
        [self enableSubviewUserInteraction:YES];
    }
    else
    {
        vDestinaRect = CGRectMake(-[self getMaxMenuWidth], self.contentView.frame.origin.x, self.contentView.frame.size.width, self.contentView.frame.size.height);
        [self enableSubviewUserInteraction:NO];
    }
    
    CGFloat vDuration = animated ? 0.4 : 0.0;
    [UIView animateWithDuration:vDuration animations: ^{
        self.moveContentView.frame = vDestinaRect;
    } completion:^(BOOL finished) {
        if (hidden)
        {
            if ([self.delegate respondsToSelector:@selector(didCellHided:)])
            {
                [self.delegate didCellHided:self];
            }
        }
        else
        {
            if ([self.delegate respondsToSelector:@selector(didCellShowed:)])
            {
                [self.delegate didCellShowed:self];
            }
        }
        UIView *vMenuView = [self.contentView viewWithTag:100];
        vMenuView.hidden = hidden;
    }];
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
    {
        CGPoint vTranslationPoint = [gestureRecognizer translationInView:self.contentView];
        return fabs(vTranslationPoint.x) > fabs(vTranslationPoint.y);
    }
    return YES;
}

- (void)handlePan:(UIPanGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        self.startLocation = [sender locationInView:self.contentView].x;
        CGFloat direction = [sender velocityInView:self.contentView].x;
        if (direction < 0)
        {
            if ([self.delegate respondsToSelector:@selector(didCellWillShow:)])
            {
                [self.delegate didCellWillShow:self];
            }
        }
        else
        {
            if ([self.delegate respondsToSelector:@selector(didCellWillHide:)])
            {
                [self.delegate didCellWillHide:self];
            }
        }
    }
    else if (sender.state == UIGestureRecognizerStateChanged)
    {
        CGFloat vCurrentLocation = [sender locationInView:self.contentView].x;
        CGFloat vDistance = vCurrentLocation - self.startLocation;
        self.startLocation = vCurrentLocation;
        
        CGRect vCurrentRect = self.moveContentView.frame;
        CGFloat vOriginX = MAX(-[self getMaxMenuWidth] - kBounceSpace, vCurrentRect.origin.x + vDistance);
        vOriginX = MIN(0 + kBounceSpace, vOriginX);
        self.moveContentView.frame = CGRectMake(vOriginX, vCurrentRect.origin.y, vCurrentRect.size.width, vCurrentRect.size.height);
        
        CGFloat direction = [sender velocityInView:self.contentView].x;

        if (direction < - 30.0 || vOriginX <  - (0.5 * [self getMaxMenuWidth]))
        {
            self.hideMenuView = NO;
            UIView *vMenuView = [self.contentView viewWithTag:100];
            vMenuView.hidden = self.hideMenuView;
        }
        else if (direction > 20.0 || vOriginX >  - (0.5 * [self getMaxMenuWidth]))
        {
            self.hideMenuView = YES;
        }
    }
    else if (sender.state == UIGestureRecognizerStateEnded)
    {
        [self hideMenuView:self.hideMenuView Animated:YES];
    }
}

- (void)setPlan:(Plan *)plan
{
    _plan = plan;
    self.labelContent.text = plan.content;
    NSDate *beginDate = [CommonFunction NSStringDateToNSDate:plan.beginDate formatter:STRDateFormatterType4];
    if (![plan.iscompleted isEqualToString:@"1"])
    {
        self.labelBeginDate.text = [CommonFunction getBeginDateStringForShow:plan.beginDate];
        if ([beginDate compare:[NSDate date]] == NSOrderedDescending)
        {
            self.labelDateLeft.text = [NSString stringWithFormat:STRCommonTime10,[CommonFunction howManyDaysLeft:plan.beginDate]];
            self.labelDateLeft.hidden = NO;
        }
        else
        {
            self.labelDateLeft.hidden = YES;
        }
    }
    else
    {
        self.labelDateLeft.hidden = YES;
    }
    
    if ([plan.isnotify isEqualToString:@"1"])
    {
        self.imgViewAlarm.hidden = NO;
    }
    else
    {
        self.imgViewAlarm.hidden = YES;
    }
}

- (void)setIsDone:(NSString *)isDone
{
    if ([isDone isEqualToString:@"1"])
    {
        [self.btnDone setAllBackgroundImage:[UIImage imageNamed:png_Btn_Plan_Doing]];
    }
    else
    {
        [self.btnDone setAllBackgroundImage:[UIImage imageNamed:png_Btn_Plan_Done]];
    }
}

- (void)didContentClicked:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(didCellClicked:)])
    {
        [self.delegate didCellClicked:self];
    }
}

- (void)btnDeleteAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(didCellClickedDeleteButton:)])
    {
        [self.delegate didCellClickedDeleteButton:self];
    }
}

- (IBAction)btnDoneAction:(id)sender
{
    [self.superview sendSubviewToBack:self];
    if ([self.delegate respondsToSelector:@selector(didCellClickedDoneButton:)])
    {
        [self.delegate didCellClickedDoneButton:self];
    }
}

@end
