//
//  ThemeNewCell.m
//  plan
//
//  Created by Fengzy on 16/9/5.
//  Copyright © 2016年 Fengzy. All rights reserved.
//

#import "ThemeNewCell.h"

@implementation ThemeNewCell

- (void)awakeFromNib {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

+ (ThemeNewCell *)cellView {
    ThemeNewCell *cellView = [[NSBundle mainBundle] loadNibNamed:@"ThemeNewCell" owner:self options:nil].lastObject;
    
    cellView.imgView1.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap1 = [[UITapGestureRecognizer alloc] initWithTarget:cellView action:@selector(imgView1ClieckedAction)];
    [cellView.imgView1 addGestureRecognizer:singleTap1];

    cellView.imgView2.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap2 = [[UITapGestureRecognizer alloc] initWithTarget:cellView action:@selector(imgView2ClieckedAction)];
    [cellView.imgView2 addGestureRecognizer:singleTap2];

    cellView.imgView3.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap3 = [[UITapGestureRecognizer alloc] initWithTarget:cellView action:@selector(imgView3ClieckedAction)];
    [cellView.imgView3 addGestureRecognizer:singleTap3];

    cellView.imgView4.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap4 = [[UITapGestureRecognizer alloc] initWithTarget:cellView action:@selector(imgView4ClieckedAction)];
    [cellView.imgView4 addGestureRecognizer:singleTap4];

    cellView.imgView5.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap5 = [[UITapGestureRecognizer alloc] initWithTarget:cellView action:@selector(imgView5ClieckedAction)];
    [cellView.imgView5 addGestureRecognizer:singleTap5];
    
    cellView.imgView6.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap6 = [[UITapGestureRecognizer alloc] initWithTarget:cellView action:@selector(imgView6ClieckedAction)];
    [cellView.imgView6 addGestureRecognizer:singleTap6];
    
    return cellView;
}

- (void)imgView1ClieckedAction {
    if (self.imgView1ClickedBlock) {
        self.imgView1ClickedBlock ();
    }
}

- (void)imgView2ClieckedAction {
    if (self.imgView2ClickedBlock) {
        self.imgView2ClickedBlock ();
    }
}

- (void)imgView3ClieckedAction {
    if (self.imgView3ClickedBlock) {
        self.imgView3ClickedBlock ();
    }
}

- (void)imgView4ClieckedAction {
    if (self.imgView4ClickedBlock) {
        self.imgView4ClickedBlock ();
    }
}

- (void)imgView5ClieckedAction {
    if (self.imgView5ClickedBlock) {
        self.imgView5ClickedBlock ();
    }
}

- (void)imgView6ClieckedAction {
    if (self.imgView6ClickedBlock) {
        self.imgView6ClickedBlock ();
    }
}

@end
