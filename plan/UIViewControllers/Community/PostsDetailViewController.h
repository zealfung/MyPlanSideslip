//
//  PostsDetailViewController.h
//  plan
//
//  Created by Fengzy on 15/12/27.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import "BmobQuery.h"
#import "FatherViewController.h"

@interface PostsDetailViewController : FatherViewController

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) BmobObject *posts;

@end
