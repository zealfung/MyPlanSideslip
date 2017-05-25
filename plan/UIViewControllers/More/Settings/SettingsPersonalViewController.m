//
//  SettingsPersonalViewController.m
//  plan
//
//  Created by Fengzy on 16/4/15.
//  Copyright © 2016年 Fengzy. All rights reserved.
//

#import "CLLockVC.h"
#import "PlanCache.h"
#import "SelectItem.h"
#import <BmobSDK/BmobUser.h>
#import <BmobSDK/BmobFile.h>
#import <ShareSDK/ShareSDK.h>
#import "LogInViewController.h"
#import "SingleSelectedViewController.h"
#import "ChangePasswordViewController.h"
#import "SettingsSetTextViewController.h"
#import "SettingsPersonalViewController.h"

NSString *const kEdgeWhiteSpace = @"  ";

@interface SettingsPersonalViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) NSArray *arrayGender;//性别
@property (nonatomic, strong) NSArray *arrayDayOrMonth;//日月模式
@property (nonatomic, strong) NSArray *arrayCountdown;//倒计样式
@property (nonatomic, strong) NSArray *arrayShowGesture;//显示手势

@end

@implementation SettingsPersonalViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = STRViewTitle17;

    [self initTableView];
    [self initSelectItem];
    
    [NotificationCenter addObserver:self selector:@selector(refreshTableView) name:NTFSettingsSave object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)initTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, WIDTH_FULL_SCREEN, HEIGHT_FULL_VIEW) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void)initSelectItem
{
    SelectItem *itemMale = [[SelectItem alloc] init];
    itemMale.itemName = @"男";
    itemMale.itemValue = @"1";
    SelectItem *itemFemale = [[SelectItem alloc] init];
    itemFemale.itemName = @"女";
    itemFemale.itemValue = @"0";
    self.arrayGender = [NSArray arrayWithObjects:itemMale, itemFemale, nil];
    
    SelectItem *itemDay = [[SelectItem alloc] init];
    itemDay.itemName = STRSettingsViewTips13;
    itemDay.itemValue = @"0";
    SelectItem *itemMonth = [[SelectItem alloc] init];
    itemMonth.itemName = STRSettingsViewTips14;
    itemMonth.itemValue = @"1";
    self.arrayDayOrMonth = [NSArray arrayWithObjects:itemDay, itemMonth, nil];
    
    SelectItem *itemSecond = [[SelectItem alloc] init];
    itemSecond.itemName = STRSettingsViewTips7;
    itemSecond.itemValue = @"0";
    SelectItem *itemMinute = [[SelectItem alloc] init];
    itemMinute.itemName = STRSettingsViewTips8;
    itemMinute.itemValue = @"1";
    SelectItem *itemHour = [[SelectItem alloc] init];
    itemHour.itemName = STRSettingsViewTips9;
    itemHour.itemValue = @"2";
    SelectItem *itemAll = [[SelectItem alloc] init];
    itemAll.itemName = STRSettingsViewTips10;
    itemAll.itemValue = @"3";
    self.arrayCountdown = [NSArray arrayWithObjects:itemSecond, itemMinute, itemHour, itemAll, nil];

    SelectItem *itemNotShow = [[SelectItem alloc] init];
    itemNotShow.itemName = @"隐藏";
    itemNotShow.itemValue = @"0";
    SelectItem *itemShow = [[SelectItem alloc] init];
    itemShow.itemName = @"显示";
    itemShow.itemValue = @"1";
    self.arrayShowGesture = [NSArray arrayWithObjects:itemNotShow, itemShow, nil];
}
    
- (void)refreshTableView
{
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 3 || section == 4)
    {
        return 1;
    }
    else if (section == 0)
    {
        return 2;
    }
    else if (section == 1)
    {
        return 6;
    }
    else if (section == 2)
    {
        BOOL usePwd = [[Config shareInstance].settings.isUseGestureLock isEqualToString:@"1"];
        if (usePwd)
        {
            return 5;
        }
        else
        {
            return 3;
        }
    }
    else
    {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//    if (cell == nil)
//    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
//        cell.accessoryType = UITableViewCellAccessoryNone;
//    }
    
    switch (indexPath.section)
    {
        case 0:
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            switch (indexPath.row)
            {
                case 0:
                {
                    cell.textLabel.text = @"账号";
                    BmobUser *user = [BmobUser currentUser];
                    NSString *email = [user objectForKey:@"username"];
                    NSRange range = [email rangeOfString:@"@"];
                    if (range.location != NSNotFound) {
                        NSString *replaceString = @"*";
                        for (NSInteger i = 1; i < range.location - 1; i++) {
                            replaceString = [replaceString stringByAppendingString:@"*"];
                        }
                        email = [email stringByReplacingCharactersInRange:NSMakeRange(1, range.location - 1) withString:replaceString];
                    }
                    cell.detailTextLabel.text = email;
                }
                    break;
                case 1:
                {
                    cell.textLabel.text = @"编号";
                    BmobUser *user = [BmobUser currentUser];
                    cell.detailTextLabel.text = user.objectId;
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 1:
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.textLabel.text = @"头像";
                    
                    UIImage *avatarImage = [UIImage imageNamed:png_AvatarDefault];
                    if ([Config shareInstance].settings.avatar)
                    {
                        avatarImage = [UIImage imageWithData:[Config shareInstance].settings.avatar];
                    }
                    NSUInteger yDistance = 6;
                    CGFloat avatarSize = 60 - yDistance;
                    UIImageView *avatar = [[UIImageView alloc] initWithFrame:CGRectMake(WIDTH_FULL_SCREEN - kEdgeInset - avatarSize, yDistance/2, avatarSize, avatarSize)];
                    avatar.image = avatarImage;
                    avatar.clipsToBounds = YES;
                    avatar.layer.borderWidth = 0.5;
                    avatar.userInteractionEnabled = YES;
                    avatar.layer.cornerRadius = avatarSize / 2;
                    avatar.backgroundColor = [UIColor clearColor];
                    avatar.layer.borderColor = [color_dedede CGColor];
                    avatar.contentMode = UIViewContentModeScaleAspectFit;

                    [cell addSubview:avatar];
                }
                    break;
                case 1:
                {
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.textLabel.text = @"昵称";
                    NSString *nickName = [Config shareInstance].settings.nickname;
                    if (nickName.length == 0) {
                        nickName = STRViewTips72;
                    }
                    cell.detailTextLabel.text = nickName;
                }
                    break;
                case 2:
                {
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.textLabel.text = @"性别";
                    NSString *genderType = [Config shareInstance].settings.gender;
                    NSString *genderString = @"未设置";
                    if (genderType)
                    {
                        for (SelectItem *item in self.arrayGender)
                        {
                            if ([genderType isEqualToString:item.itemValue])
                            {
                                genderString = item.itemName;
                            }
                        }
                    }
                    cell.detailTextLabel.text = genderString;
                }
                    break;
                case 3:
                {
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.textLabel.text = @"生日";
                    NSString *birthday = [Config shareInstance].settings.birthday;
                    if (birthday.length == 0)
                    {
                        birthday = STRViewTips79;
                    }
                    cell.detailTextLabel.text = birthday;
                }
                    break;
                case 4:
                {
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.textLabel.text = @"岁数";
                    NSString *lifespan = [Config shareInstance].settings.lifespan;
                    if (lifespan.length == 0)
                    {
                        lifespan = STRViewTips81;
                    }
                    cell.detailTextLabel.text = lifespan;
                }
                    break;
                case 5:
                {
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.textLabel.text = @"签名";
                    NSString *signature = [Config shareInstance].settings.signature;
                    if (signature.length == 0)
                    {
                        signature = STRViewTips74;
                    }
                    cell.detailTextLabel.text = signature;
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 2:
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.textLabel.text = @"日月样式";
                    
                    NSString *dayOrMonth = [Config shareInstance].settings.dayOrMonth;
                    NSString *showText = @"";
                    switch ([dayOrMonth integerValue])
                    {
                        case 0:
                            showText = STRSettingsViewTips13;
                            break;
                        case 1:
                            showText = STRSettingsViewTips14;
                            break;
                        default:
                            showText = STRSettingsViewTips13;
                            break;
                    }
                    cell.detailTextLabel.text = showText;
                }
                    break;
                case 1:
                {
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.textLabel.text = @"倒计样式";
                    
                    NSString *countdownType = [Config shareInstance].settings.countdownType;
                    NSString *showText = @"";
                    switch ([countdownType integerValue])
                    {
                        case 0:
                            showText = STRSettingsViewTips7;
                            break;
                        case 1:
                            showText = STRSettingsViewTips8;
                            break;
                        case 2:
                            showText = STRSettingsViewTips9;
                            break;
                        case 3:
                            showText = STRSettingsViewTips10;
                            break;
                        default:
                            showText = STRSettingsViewTips7;
                            break;
                    }
                    cell.detailTextLabel.text = showText;
                }
                    break;
                case 2:
                {
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.textLabel.text = @"手势解锁";
                    
                    NSString *isUseGestureLock = [Config shareInstance].settings.isUseGestureLock;
                    NSString *showText = @"";
                    if ([isUseGestureLock intValue] == 1)
                    {
                        showText = @"已启用";
                    }
                    else
                    {
                        showText = @"未启用";
                    }
                    cell.detailTextLabel.text = showText;
                }
                    break;
                case 3:
                {
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.textLabel.text = STRSettingsViewTips4;
                    
                    NSString *isShowGestureTrack = [Config shareInstance].settings.isShowGestureTrack;
                    NSString *showText = @"";
                    if ([isShowGestureTrack intValue] == 1)
                    {
                        showText = @"显示";
                    }
                    else
                    {
                        showText = @"隐藏";
                    }
                    cell.detailTextLabel.text = showText;
                }
                    break;
                case 4:
                {
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.textLabel.text = @"修改手势";
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 3:
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            cell.textLabel.text = @"修改密码";
        }
            break;
        case 4:
        {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.backgroundColor = [UIColor redColor];
            button.titleLabel.font = font_Bold_18;
            button.clipsToBounds = YES;
            [button setAllTitle:STRViewTips84];
            [button addTarget:self action:@selector(exitAction) forControlEvents:UIControlEventTouchUpInside];
            
            CGRect frame = CGRectZero;
            frame.origin.x = 0;
            frame.origin.y = 0;
            frame.size.width = WIDTH_FULL_SCREEN;
            frame.size.height = 60;
            button.frame = frame;
            
            [cell.contentView addSubview:button];
        }
            break;
        default:
            break;
    }
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section)
    {
        case 1:
        {
            switch (indexPath.row)
            {
                case 0://头像
                {
                    [self setAvatar];
                }
                    break;
                case 1://昵称
                {
                    [self toSetNickNameViewController];
                }
                    break;
                case 2://性别
                {
                    [self toSetGenderViewController];
                }
                    break;
                case 3://生日
                {
                    [self setBirthday];
                }
                    break;
                case 4://岁数
                {
                    [self toSetLifeViewController];
                }
                    break;
                case 5://签名
                {
                    [self toSetSignatureViewController];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 2:
        {
            switch (indexPath.row)
            {
                case 0://日月样式
                {
                    [self toSetDayOrMonthViewController];
                }
                    break;
                case 1://倒计样式
                {
                    [self toSetCountdownViewController];
                }
                    break;
                case 2://手势解锁
                {
                    [self toSetUseGestureLockViewController];
                }
                    break;
                case 3://显示手势
                {
                    [self toSetShowGestureViewController];
                }
                    break;
                case 4://修改手势
                {
                    [self toSetChangeGestureViewController];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 3:
        {
            [self toChangePasswordViewController];
        }
            break;
        default:
            break;
    }
}

- (void)setAvatar
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:STRViewTips82
                                                                 delegate:self
                                                        cancelButtonTitle:STRCommonTip28
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:STRCommonTip46, STRCommonTip45, nil];
        [actionSheet showInView:self.view];
        
    }
    else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:STRViewTips83
                                                                 delegate:self
                                                        cancelButtonTitle:STRCommonTip28
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:STRCommonTip45, nil];
        [actionSheet showInView:self.view];
        
    }
    else
    {
        //不支持相片选取
    }
}

- (void)toSetNickNameViewController
{
    __weak typeof(self) weakSelf = self;
    SettingsSetTextViewController *controller = [[SettingsSetTextViewController alloc] init];
    controller.title = STRSettingsViewTips18;
    controller.textFieldDefaultValue = [Config shareInstance].settings.nickname;
    controller.textFieldPlaceholder = STRSettingsViewTips19;
    controller.setType = SetNickName;
    controller.finishedBlock = ^(NSString *text)
    {
        text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if (text.length > 10)
        {
            [weakSelf alertButtonMessage:STRSettingsViewTips20];
            return;
        }
        if (text.length == 0)
        {
            [weakSelf alertButtonMessage:STRSettingsViewTips19];
            return;
        }

        BmobUser *user = [BmobUser currentUser];
        [weakSelf showHUD];
        BmobQuery *bquery = [BmobQuery queryWithClassName:@"UserSettings"];
        [bquery whereKey:@"userObjectId" equalTo:user.objectId];
        [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error)
         {
             [weakSelf hideHUD];
             if (!error)
             {
                 if (array.count)
                 {
                     BmobObject *obj1 = array[0];
                     [obj1 setObject:text forKey:@"nickName"];
                     [obj1 updateInBackground];
                     
                     [Config shareInstance].settings.nickname = text;
                     [PlanCache storePersonalSettings:[Config shareInstance].settings isNotify:YES];
                     [weakSelf alertToastMessage:STRCommonTip13];
                     [weakSelf.navigationController popViewControllerAnimated:YES];
                     [weakSelf.tableView reloadData];
                 }
             }
             else
             {
                 [AlertCenter alertToastMessage:@"更新昵称失败"];
             }
         }];
    };
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)toSetGenderViewController
{
    __weak typeof(self) weakSelf = self;
    SingleSelectedViewController *controller = [[SingleSelectedViewController alloc] init];
    controller.viewTitle = @"设置性别";
    controller.arrayData = self.arrayGender;
    controller.selectedValue = [Config shareInstance].settings.gender;
    controller.SelectedDelegate = ^(NSString *selectedValue)
    {
        BmobUser *user = [BmobUser currentUser];
        [weakSelf showHUD];
        BmobQuery *bquery = [BmobQuery queryWithClassName:@"UserSettings"];
        [bquery whereKey:@"userObjectId" equalTo:user.objectId];
        [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error)
         {
             [weakSelf hideHUD];
             if (!error)
             {
                 if (array.count)
                 {
                     BmobObject *obj1 = array[0];
                     [obj1 setObject:selectedValue forKey:@"gender"];
                     [obj1 updateInBackground];
                     
                     [Config shareInstance].settings.gender = selectedValue;
                     [PlanCache storePersonalSettings:[Config shareInstance].settings isNotify:YES];
                     [weakSelf alertToastMessage:STRCommonTip13];
                     [weakSelf.tableView reloadData];
                 }
             }
             else
             {
                 [AlertCenter alertToastMessage:@"更新性别失败"];
             }
         }];
    };
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)toSetSignatureViewController
{
    __weak typeof(self) weakSelf = self;
    SettingsSetTextViewController *controller = [[SettingsSetTextViewController alloc] init];
    controller.title = STRSettingsViewTips21;
    controller.textFieldDefaultValue = [Config shareInstance].settings.signature;
    controller.textFieldPlaceholder = STRSettingsViewTips22;
    controller.setType = SetNickName;
    controller.finishedBlock = ^(NSString *text)
    {
        text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if (text.length == 0)
        {
            [weakSelf alertButtonMessage:STRSettingsViewTips22];
            return;
        }
 
        BmobUser *user = [BmobUser currentUser];

        [weakSelf showHUD];
        BmobQuery *bquery = [BmobQuery queryWithClassName:@"UserSettings"];
        [bquery whereKey:@"userObjectId" equalTo:user.objectId];
        [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error)
         {
             [weakSelf hideHUD];
             if (!error)
             {
                 if (array.count)
                 {
                     BmobObject *obj1 = array[0];
                     [obj1 setObject:text forKey:@"signature"];
                     [obj1 updateInBackground];
                     
                     [Config shareInstance].settings.signature = text;
                     [PlanCache storePersonalSettings:[Config shareInstance].settings isNotify:YES];
                     [weakSelf alertToastMessage:STRCommonTip13];
                     [weakSelf.navigationController popViewControllerAnimated:YES];
                     [weakSelf.tableView reloadData];
                 }
             }
             else
             {
                 [AlertCenter alertToastMessage:@"更新签名失败"];
             }
         }];
    };
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)toSetLifeViewController
{
    __weak typeof(self) weakSelf = self;
    SettingsSetTextViewController *controller = [[SettingsSetTextViewController alloc] init];
    controller.title = STRSettingsViewTips23;
    controller.textFieldDefaultValue = [Config shareInstance].settings.lifespan;
    controller.textFieldPlaceholder = STRSettingsViewTips24;
    controller.setType = SetLife;
    controller.finishedBlock = ^(NSString *text)
    {
        text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if (text.length == 0)
        {
            [weakSelf alertButtonMessage:STRSettingsViewTips25];
            return;
        }
        
        if ([text intValue]> 130)
        {
            [weakSelf alertButtonMessage:STRSettingsViewTips26];
            return;
        }

        BmobUser *user = [BmobUser currentUser];
        [weakSelf showHUD];
        BmobQuery *bquery = [BmobQuery queryWithClassName:@"UserSettings"];
        [bquery whereKey:@"userObjectId" equalTo:user.objectId];
        [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error)
         {
             [weakSelf hideHUD];
             if (!error)
             {
                 if (array.count)
                 {
                     BmobObject *obj1 = array[0];
                     [obj1 setObject:text forKey:@"lifespan"];
                     [obj1 updateInBackground];
                     
                     [Config shareInstance].settings.lifespan = text;
                     [PlanCache storePersonalSettings:[Config shareInstance].settings isNotify:YES];
                     [weakSelf alertToastMessage:STRCommonTip13];
                     [weakSelf.navigationController popViewControllerAnimated:YES];
                     [weakSelf.tableView reloadData];
                 }
             }
             else
             {
                 [AlertCenter alertToastMessage:@"更新岁数失败"];
             }
         }];
    };
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)toSetDayOrMonthViewController
{
    __weak typeof(self) weakSelf = self;
    SingleSelectedViewController *controller = [[SingleSelectedViewController alloc] init];
    controller.viewTitle = @"日月样式";
    controller.arrayData = self.arrayDayOrMonth;
    controller.selectedValue = [Config shareInstance].settings.dayOrMonth;
    controller.SelectedDelegate = ^(NSString *selectedValue)
    {
        BmobUser *user = [BmobUser currentUser];
        [weakSelf showHUD];
        BmobQuery *bquery = [BmobQuery queryWithClassName:@"UserSettings"];
        [bquery whereKey:@"userObjectId" equalTo:user.objectId];
        [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error)
         {
             [weakSelf hideHUD];
             if (!error)
             {
                 if (array.count)
                 {
                     BmobObject *obj1 = array[0];
                     [obj1 setObject:selectedValue forKey:@"dayOrMonth"];
                     [obj1 updateInBackground];
                     
                     [Config shareInstance].settings.dayOrMonth = selectedValue;
                     [PlanCache storePersonalSettings:[Config shareInstance].settings isNotify:YES];
                     [weakSelf alertToastMessage:STRCommonTip13];
                     [weakSelf.tableView reloadData];
                 }
             }
             else
             {
                 [AlertCenter alertToastMessage:@"更新日月样式失败"];
             }
         }];
    };
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)toSetCountdownViewController
{
    __weak typeof(self) weakSelf = self;
    SingleSelectedViewController *controller = [[SingleSelectedViewController alloc] init];
    controller.viewTitle = @"倒计样式";
    controller.arrayData = self.arrayCountdown;
    controller.selectedValue = [Config shareInstance].settings.countdownType;
    controller.SelectedDelegate = ^(NSString *selectedValue)
    {
        BmobUser *user = [BmobUser currentUser];
        [weakSelf showHUD];
        BmobQuery *bquery = [BmobQuery queryWithClassName:@"UserSettings"];
        [bquery whereKey:@"userObjectId" equalTo:user.objectId];
        [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error)
         {
             [weakSelf hideHUD];
             if (!error)
             {
                 if (array.count)
                 {
                     BmobObject *obj1 = array[0];
                     [obj1 setObject:selectedValue forKey:@"countdownType"];
                     [obj1 updateInBackground];
                     
                     [Config shareInstance].settings.countdownType = selectedValue;
                     [PlanCache storePersonalSettings:[Config shareInstance].settings isNotify:YES];
                     [weakSelf alertToastMessage:STRCommonTip13];
                     [weakSelf.tableView reloadData];
                 }
             }
             else
             {
                 [AlertCenter alertToastMessage:@"更新倒计样式失败"];
             }
         }];
    };
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)toSetUseGestureLockViewController
{
    __weak typeof(self) weakSelf = self;
    BOOL hasPwd = [[Config shareInstance].settings.isUseGestureLock isEqualToString:@"1"];
    if (hasPwd)
    {
        //关闭手势解锁
        [CLLockVC showVerifyLockVCInVC:self isLogIn:NO forgetPwdBlock:^{
            
            LogInViewController *controller = [[LogInViewController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
            
        }
        successBlock:^(CLLockVC *lockVC, NSString *pwd)
        {
            [Config shareInstance].settings.isUseGestureLock = @"0";
            [Config shareInstance].settings.gesturePasswod = @"";
            [PlanCache storePersonalSettings:[Config shareInstance].settings isNotify:YES];
            [lockVC dismiss:.5f];
            [weakSelf.tableView reloadData];
        }];
    }
    else
    {
        //打开手势解锁
        [CLLockVC showSettingLockVCInVC:self successBlock:^(CLLockVC *lockVC, NSString *pwd)
        {
             [weakSelf alertToastMessage:STRSettingsViewTips11];
             [lockVC dismiss:.5f];
             [weakSelf.tableView reloadData];
        }];
    }
}

- (void)toSetShowGestureViewController
{
    __weak typeof(self) weakSelf = self;
    SingleSelectedViewController *controller = [[SingleSelectedViewController alloc] init];
    controller.viewTitle = STRSettingsViewTips4;
    controller.arrayData = self.arrayShowGesture;
    controller.selectedValue = [Config shareInstance].settings.isShowGestureTrack;
    controller.SelectedDelegate = ^(NSString *selectedValue)
    {
        [Config shareInstance].settings.isShowGestureTrack = selectedValue;
        [PlanCache storePersonalSettings:[Config shareInstance].settings isNotify:YES];
        [weakSelf alertToastMessage:STRCommonTip13];
        [weakSelf.tableView reloadData];
    };
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)toSetChangeGestureViewController
{
    __weak typeof(self) weakSelf = self;
    BOOL hasPwd = [[Config shareInstance].settings.isUseGestureLock isEqualToString:@"1"];
    if (hasPwd)
    {
        [CLLockVC showModifyLockVCInVC:self successBlock:^(CLLockVC *lockVC, NSString *pwd)
        {
            [weakSelf alertToastMessage:STRCommonTip15];
            [lockVC dismiss:.5f];
        }];
    }
}

- (void)toChangePasswordViewController
{
    ChangePasswordViewController *controller = [[ChangePasswordViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)setBirthday
{
    UIView *pickerView = [[UIView alloc] initWithFrame:self.view.bounds];
    pickerView.backgroundColor = [UIColor clearColor];
    
    {
        UIView *bgView = [[UIView alloc] initWithFrame:pickerView.bounds];
        bgView.backgroundColor = [UIColor blackColor];
        bgView.alpha = 0.3;
        [pickerView addSubview:bgView];
    }
    {
        UIToolbar* toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, pickerView.frame.size.height - kDatePickerHeight - kToolBarHeight, CGRectGetWidth(pickerView.bounds), kToolBarHeight)];
        toolbar.barStyle = UIBarStyleBlack;
        toolbar.translucent = YES;
        UIBarButtonItem* item1 = [[UIBarButtonItem alloc] initWithTitle:STRCommonTip27 style:UIBarButtonItemStylePlain target:nil action:@selector(onPickerCertainBtn)];
        UIBarButtonItem* item2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem* item3 = [[UIBarButtonItem alloc] initWithTitle:STRCommonTip28 style:UIBarButtonItemStylePlain target:nil action:@selector(onPickerCancelBtn)];
        NSArray* toolbarItems = [NSArray arrayWithObjects:item3, item2, item1, nil];
        [toolbar setItems:toolbarItems];
        [pickerView addSubview:toolbar];
    }
    {
        UIDatePicker *picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, pickerView.frame.size.height - kDatePickerHeight, CGRectGetWidth(pickerView.bounds), kDatePickerHeight)];
        picker.backgroundColor = [UIColor whiteColor];
        picker.locale = [NSLocale currentLocale];
        picker.datePickerMode = UIDatePickerModeDate;
        picker.maximumDate = [NSDate date];
        NSDateComponents *defaultComponents = [CommonFunction getDateTime:[NSDate date]];
        NSDate *minDate = [CommonFunction NSStringDateToNSDate:[NSString stringWithFormat:@"%zd-%zd-%zd",
                                                                defaultComponents.year - 100,
                                                                defaultComponents.month,
                                                                defaultComponents.day]
                                                     formatter:STRDateFormatterType4];
        
        picker.minimumDate = minDate;
        [pickerView addSubview:picker];
        self.datePicker = picker;
        
        NSString *birthday = [Config shareInstance].settings.birthday;
        
        if (birthday)
        {
            NSDate *date = [CommonFunction NSStringDateToNSDate:birthday formatter:STRDateFormatterType4];
            if (date)
            {
                [self.datePicker setDate:date animated:YES];
            }
        }
        else
        {
            NSDate *defaultDate = [CommonFunction NSStringDateToNSDate:[NSString stringWithFormat:@"%zd-%zd-%zd",
                                                                        defaultComponents.year - 20,
                                                                        defaultComponents.month,
                                                                        defaultComponents.day]
                                                             formatter:STRDateFormatterType4];
            self.datePicker.date = defaultDate;
        }
    }
    
    pickerView.tag = kDatePickerBgViewTag;
    [self.view addSubview:pickerView];
}

- (void)onPickerCertainBtn
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:STRDateFormatterType4];
    NSString *birthday = [dateFormatter stringFromDate:self.datePicker.date];
    
    UIView *pickerView = [self.view viewWithTag:kDatePickerBgViewTag];
    [pickerView removeFromSuperview];

    BmobUser *user = [BmobUser currentUser];
    __weak typeof(self) weakSelf = self;
    
    [self showHUD];
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"UserSettings"];
    [bquery whereKey:@"userObjectId" equalTo:user.objectId];
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error)
    {
        [weakSelf hideHUD];
        if (!error)
        {
            if (array.count)
            {
                BmobObject *obj1 = array[0];
                [obj1 setObject:birthday forKey:@"birthday"];
                [obj1 updateInBackground];
                
                [Config shareInstance].settings.birthday = birthday;
                [PlanCache storePersonalSettings:[Config shareInstance].settings isNotify:YES];
                [weakSelf.tableView reloadData];
            }
        }
        else
        {
            [AlertCenter alertToastMessage:@"更新生日失败"];
        }
    }];
}

- (void)onPickerCancelBtn
{
    UIView *pickerView = [self.view viewWithTag:kDatePickerBgViewTag];
    [pickerView removeFromSuperview];
}

- (void)saveAvatar:(NSData *)icon
{
    if (icon == nil)
    {
        return;
    }
    BmobUser *user = [BmobUser currentUser];
    __weak typeof(self) weakSelf = self;
    
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"UserSettings"];
    [bquery whereKey:@"userObjectId" equalTo:user.objectId];
    
    [self showHUD];
    BmobFile *file = [[BmobFile alloc] initWithFileName:@"avatar.png" withFileData:icon];
    [file saveInBackground:^(BOOL isSuccessful, NSError *error)
    {
        [weakSelf hideHUD];
         if (isSuccessful)
         {
             [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error)
             {
                 if (!error)
                 {
                     if (array.count)
                     {
                         BmobObject *obj1 = array[0];
                         [obj1 setObject:file.url forKey:@"avatarURL"];
                         [obj1 updateInBackground];
                         
                         [Config shareInstance].settings.avatar = icon;
                         [PlanCache storePersonalSettings:[Config shareInstance].settings isNotify:YES];
                         [weakSelf.tableView reloadData];
                     }
                 }
                 else
                 {
                     [AlertCenter alertToastMessage:@"更新头像失败"];
                 }
             }];
         }
         else
         {
             [AlertCenter alertButtonMessage:@"上传头像失败"];
         }
     }
     withProgressBlock:^(CGFloat progress)
     {
#if DEBUG
         //上传进度
         NSLog(@"上传头像进度： %f",progress);
#endif
     }];
}

- (void)exitAction
{
    [BmobUser logout];
    [Config shareInstance].settings = [PlanCache getPersonalSettings];
    [NotificationCenter postNotificationName:NTFLogOut object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    [self saveAvatar:[CommonFunction compressImage:image]];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==[actionSheet cancelButtonIndex])
    {
        
    }
    else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:STRCommonTip46])
    {
        //拍照
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor darkGrayColor]};
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            picker.allowsEditing = YES;
            picker.delegate = self;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self presentViewController:picker animated:YES completion:nil];
            });
            
        }
        else
        {
            [self alertButtonMessage:STRCommonTip2];
        }
    }
    else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:STRCommonTip45])
    {
        //从相册选择
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
        {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor darkGrayColor]};
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            picker.allowsEditing = YES;
            picker.delegate = self;
            
            dispatch_async(dispatch_get_main_queue(), ^{//如果不这样写，在iPad上会访问不了相册
                [self presentViewController:picker animated:YES completion:nil];
            });
        }
        else
        {
            [self alertButtonMessage:STRCommonTip1];
        }
    }
}

@end
