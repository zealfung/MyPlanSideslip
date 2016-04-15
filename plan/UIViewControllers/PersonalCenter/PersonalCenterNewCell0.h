//
//  PersonalCenterNewCell0.h
//  plan
//
//  Created by Fengzy on 16/4/15.
//  Copyright © 2016年 Fengzy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PersonalCenterNewCell0 : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imgViewAvatar;
@property (strong, nonatomic) IBOutlet UILabel *labelNickname;
@property (strong, nonatomic) IBOutlet UILabel *labelSignature;
@property (strong, nonatomic) IBOutlet UILabel *labelPlanCount;
@property (strong, nonatomic) IBOutlet UILabel *labelTaskCount;
@property (strong, nonatomic) IBOutlet UILabel *labelPhotoCount;

+ (PersonalCenterNewCell0 *)cellView;

@end
