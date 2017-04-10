//
//  PersonalCenterNewCell0.m
//  plan
//
//  Created by Fengzy on 16/4/15.
//  Copyright © 2016年 Fengzy. All rights reserved.
//

#import "PersonalCenterNewCell0.h"

@implementation PersonalCenterNewCell0

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

+ (PersonalCenterNewCell0 *)cellView
{
    PersonalCenterNewCell0 *cellView = [[NSBundle mainBundle] loadNibNamed:@"PersonalCenterNewCell0" owner:self options:nil].lastObject;
    //头像
    UIImage *image = [UIImage imageNamed:png_AvatarDefault];
    if ([Config shareInstance].settings.avatar) {
        image = [UIImage imageWithData:[Config shareInstance].settings.avatar];
    }
    cellView.imgViewAvatar.image = image;
    cellView.imgViewAvatar.clipsToBounds = YES;
    cellView.imgViewAvatar.backgroundColor = [UIColor clearColor];
    cellView.imgViewAvatar.contentMode = UIViewContentModeScaleAspectFit;
    cellView.imgViewAvatar.layer.borderWidth = 1;
    cellView.imgViewAvatar.layer.borderColor = [color_dedede CGColor];
    cellView.imgViewAvatar.layer.cornerRadius = cellView.imgViewAvatar.frame.size.height / 2;
    //昵称
    NSString *nickname = STRCommonTip12;
    if (![CommonFunction isEmptyString:[Config shareInstance].settings.nickname])
    {
        nickname = [Config shareInstance].settings.nickname;
    }
    cellView.labelNickname.text = nickname;
    cellView.labelNickname.textColor = [CommonFunction getGenderColor];
    //个性签名
    NSString *signature = STRViewTips61;
    if (![CommonFunction isEmptyString:[Config shareInstance].settings.signature])
    {
        signature = [Config shareInstance].settings.signature;
    }
    cellView.labelSignature.text = signature;
//    
//    NSString *planCount = [PlanCache getPlanTotalCount:@"ALL"];
//    NSString *photoCount = [PlanCache getPhotoTotalCount];
//    cellView.labelPlanCount.text = [NSString stringWithFormat: @"%@ 计划", planCount];
//    cellView.labelPhotoCount.text = [NSString stringWithFormat: @"%@ 影像", photoCount];
    
    return cellView;
}

@end
