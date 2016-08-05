//
//  AddPostsViewController.h
//  plan
//
//  Created by Fengzy on 15/10/6.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "FatherViewController.h"

@interface AddPostsViewController : FatherViewController

@property (strong, nonatomic) IBOutlet UITextView *textViewContent;
@property (strong, nonatomic) IBOutlet UIView *viewPhoto;
@property (strong, nonatomic) IBOutlet UIButton *btnCheckbox;
@property (strong, nonatomic) IBOutlet UILabel *labelCheckbox;

@end
