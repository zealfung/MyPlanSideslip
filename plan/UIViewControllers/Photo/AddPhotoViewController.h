//
//  AddPhotoViewController.h
//  plan
//
//  Created by Fengzy on 15/10/6.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "Photo.h"
#import "FatherViewController.h"

@interface AddPhotoViewController : FatherViewController

@property (strong, nonatomic) IBOutlet UIView *viewTimeAndLocation;
@property (strong, nonatomic) IBOutlet UITextView *textViewContent;
@property (strong, nonatomic) IBOutlet UILabel *labelTime;
@property (strong, nonatomic) IBOutlet UILabel *labelLocation;
@property (strong, nonatomic) IBOutlet UITextField *textFieldTime;
@property (strong, nonatomic) IBOutlet UITextField *textFieldLocation;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *viewTimeAndLocationBottom;
@property (strong, nonatomic) IBOutlet UIView *viewPhoto;

@property (assign, nonatomic) OperationType operationType;
@property (strong, nonatomic) Photo *photo;

@end
