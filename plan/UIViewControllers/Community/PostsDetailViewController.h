//
//  PostsDetailViewController.h
//  plan
//
//  Created by Fengzy on 15/12/27.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import "BmobQuery.h"
#import <UIKit/UIKit.h>

@interface PostsDetailViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) BmobObject *posts;

@end
