//
//  PostsDetailViewController.h
//  plan
//
//  Created by Fengzy on 15/12/27.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import "BmobQuery.h"
#import "ThreeSubView.h"
#import "GrowingTextView.h"
#import "FatherViewController.h"

@interface PostsDetailViewController : FatherViewController

@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet ThreeSubView *bottomBtnView;
@property (strong, nonatomic) IBOutlet GrowingTextView *inputView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *inputViewConstraint;
@property (nonatomic, strong) NSLayoutConstraint *inputViewHeightConstraint;
@property (strong, nonatomic) BmobObject *posts;

@end
