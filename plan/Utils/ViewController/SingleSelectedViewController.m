//
//  SingleSelectedViewController.m
//  plan
//
//  Created by Fengzy on 17/3/11.
//  Copyright © 2017年 Fengzy. All rights reserved.
//

#import "SingleSelectedViewController.h"

@interface SingleSelectedViewController ()

@end

@implementation SingleSelectedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.viewTitle;
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    __weak typeof(self) weakSelf = self;
    [self customRightButtonWithImage:[UIImage imageNamed:png_Btn_Save] action:^(UIButton *sender) {
        [weakSelf saveAction:sender];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDelegate & UITableViewDatasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.arrayData.count)
    {
        return self.arrayData.count;
    }
    else
    {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    if (self.arrayData.count > indexPath.row)
    {
        SelectItem *item = self.arrayData[indexPath.row];
        cell.textLabel.text = item.itemName;
        if ([self.selectedValue isEqualToString:item.itemValue])
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.arrayData.count > indexPath.row)
    {
        SelectItem *item = self.arrayData[indexPath.row];
        self.selectedValue = item.itemValue;
        [tableView reloadData];
    }
}

- (void)saveAction:(UIButton *)sender
{
    if (self.SelectedDelegate)
    {
        self.SelectedDelegate(self.selectedValue);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
