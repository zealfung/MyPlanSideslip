//
//  ThemeNewCell.h
//  plan
//
//  Created by Fengzy on 16/9/5.
//  Copyright © 2016年 Fengzy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ImgView1ClickedBlock)();
typedef void(^ImgView2ClickedBlock)();
typedef void(^ImgView3ClickedBlock)();
typedef void(^ImgView4ClickedBlock)();
typedef void(^ImgView5ClickedBlock)();
typedef void(^ImgView6ClickedBlock)();


@interface ThemeNewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imgView1;
@property (strong, nonatomic) IBOutlet UIImageView *imgView2;
@property (strong, nonatomic) IBOutlet UIImageView *imgView3;
@property (strong, nonatomic) IBOutlet UIImageView *imgView4;
@property (strong, nonatomic) IBOutlet UIImageView *imgView5;
@property (strong, nonatomic) IBOutlet UIImageView *imgView6;
@property (strong, nonatomic) IBOutlet UILabel *label1;
@property (strong, nonatomic) IBOutlet UILabel *label2;
@property (strong, nonatomic) IBOutlet UILabel *label3;
@property (strong, nonatomic) IBOutlet UILabel *label4;
@property (strong, nonatomic) IBOutlet UILabel *label5;
@property (strong, nonatomic) IBOutlet UILabel *label6;
@property (strong, nonatomic) ImgView1ClickedBlock imgView1ClickedBlock;
@property (strong, nonatomic) ImgView2ClickedBlock imgView2ClickedBlock;
@property (strong, nonatomic) ImgView3ClickedBlock imgView3ClickedBlock;
@property (strong, nonatomic) ImgView4ClickedBlock imgView4ClickedBlock;
@property (strong, nonatomic) ImgView5ClickedBlock imgView5ClickedBlock;
@property (strong, nonatomic) ImgView6ClickedBlock imgView6ClickedBlock;

+ (ThemeNewCell *)cellView;

@end
