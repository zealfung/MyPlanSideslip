//
//  PersonalCenterTaskStatisticsViewController.m
//  plan
//
//  Created by Fengzy on 16/8/12.
//  Copyright © 2016年 Fengzy. All rights reserved.
//

#import "TaskStatistics.h"
#import "SZCalendarPicker.h"
#import "PersonalCenterTaskStatisticsViewController.h"

@interface PersonalCenterTaskStatisticsViewController () <UITableViewDelegate, UITableViewDataSource> {
    NSDate *monthDate;
    NSArray *statisticsArray;
}

@end

@implementation PersonalCenterTaskStatisticsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"任务统计";
    
    [self loadCustomView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)loadCustomView {
    statisticsArray = [NSArray array];
    
    self.tableStatistics.dataSource = self;
    self.tableStatistics.delegate = self;
    self.tableStatistics.backgroundColor = [UIColor clearColor];
    self.tableStatistics.tableFooterView = [[UIView alloc] init];
    self.tableStatistics.showsVerticalScrollIndicator = NO;
    
    self.labelDate.layer.borderWidth = 1;
    self.labelDate.layer.cornerRadius = 15;
    self.labelDate.layer.borderColor = [color_dedede CGColor];
    self.labelDate.backgroundColor = color_dedede;
    self.labelDate.layer.masksToBounds = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapDateAction:)];
    self.labelDate.userInteractionEnabled = YES;
    [self.labelDate addGestureRecognizer:tap];
    
    [self setMonthWithDate:[NSDate date]];
}

- (IBAction)btnLeftAction:(id)sender {
    NSDate *date_start = [self dateByAddingMonth:-1 date:monthDate];
    [self setMonthWithDate:date_start];
}

- (IBAction)btnRightAction:(id)sender {
    NSDate *date_start = [self dateByAddingMonth:1 date:monthDate];
    [self setMonthWithDate:date_start];
}

- (NSDate *)dateByAddingMonth:(int)month date:(NSDate *)date {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];

    NSDateComponents *adcomps = [[NSDateComponents alloc] init];
    [adcomps setYear:0];
    [adcomps setMonth:month];
    [adcomps setDay:0];
    
    return [calendar dateByAddingComponents:adcomps toDate:date options:0];
}

- (void)tapDateAction:(UITapGestureRecognizer *)sender {
    SZCalendarPicker *calendarPicker = [SZCalendarPicker showOnView:self.view];
    calendarPicker.today = [NSDate date];
    calendarPicker.date = calendarPicker.today;
    calendarPicker.frame = CGRectMake(22, 100, WIDTH_FULL_SCREEN - 44, HEIGHT_FULL_VIEW - 200);
    
    __weak typeof(self) weakSelf = self;
    calendarPicker.calendarBlock = ^(NSInteger day,NSInteger month,NSInteger year){

        NSString *str_month, *str_day;
        if (day <= 9) {
            NSString *str = [NSString stringWithFormat:@"%ld",day];
            str_day = [@"0" stringByAppendingString:str];
        } else {
            str_day = [NSString stringWithFormat:@"%ld",day];
        }
        if (month <= 9) {
            NSString *str = [NSString stringWithFormat:@"%ld",month];
            str_month = [@"0" stringByAppendingString:str];
        } else {
            str_month = [NSString stringWithFormat:@"%ld",month];
        }
        NSString *str_year = [NSString stringWithFormat:@"%ld/",year];
        NSString *datetTime = [[[str_year stringByAppendingString:str_month]stringByAppendingString:@"/"] stringByAppendingString:str_day];
        
        [weakSelf requestMonthDataWithTime:datetTime];
    };
}

- (void)setMonthWithDate:(NSDate *)date {
    NSDateFormatter *formater_start = [NSDateFormatter new];
    [formater_start setLocale:[NSLocale currentLocale]];
    [formater_start setDateFormat:@"yyyy/MM/dd"];
    NSString *str_start = [formater_start stringFromDate:date];
    
    [formater_start setDateFormat:@"MM"];
    NSString *show_start_M = [formater_start stringFromDate:date];
    
    show_start_M = [self setStrPrefixByStr:show_start_M];
    show_start_M = [[show_start_M stringByAppendingString:@"."]stringByAppendingString:@"1"];
    [formater_start setDateFormat:@"yyyy"];
    
    NSDateFormatter *formater_end = [[NSDateFormatter alloc]init];
    [formater_end setLocale:[NSLocale currentLocale]];
    [formater_end setDateFormat:@"yyyy/MM/dd"];
    [formater_end setDateFormat:@"MM"];
    
    NSString *show_end_M = [formater_end stringFromDate:date];
    [formater_end setDateFormat:@"dd"];
    NSString *show_end_D;
    NSInteger month = [show_start_M integerValue];
    if (month == 4 || month == 6 || month == 9
        || month == 11 ) {
        show_end_D = @".30";
    } else if(month == 2) {
        [formater_start setDateFormat:@"yyyy"];
        NSString *year = [formater_start stringFromDate:date];
        if ([self bissextile:[year intValue]] ) {
            show_end_D = @".28";
        }else{
            show_end_D = @".29";
        }
    } else {
        show_end_D = @".31";
    }
    
    show_end_M = [self setStrPrefixByStr:show_end_M];
    show_end_D = [self setStrPrefixByStr:show_end_D];
    if (show_end_D) {
        show_end_M = [show_end_M stringByAppendingString:show_end_D];
    }
    
    if (show_end_M) {
        NSString *showDate = [[show_start_M stringByAppendingString:@"~"]stringByAppendingString:show_end_M];
        self.labelDate.text = showDate;
    }
    
    monthDate = date;
    if (str_start.length > 8 && show_end_D.length > 2) {
        NSString *start_month = [str_start substringToIndex:8];
        start_month = [start_month stringByAppendingString:@"01"];
        
        NSString *end_day = [show_end_D substringFromIndex:1];
        NSString *end_yearMonth = [start_month substringToIndex:8];
        end_yearMonth = [end_yearMonth stringByAppendingString:end_day];
        
        NSString *startDate = [[start_month stringByReplacingOccurrencesOfString:@"/" withString:@"-"] stringByAppendingString:@" 00:00:00"];
        
        NSString *endDate = [[end_yearMonth stringByReplacingOccurrencesOfString:@"/" withString:@"-"] stringByAppendingString:@" 23:59:59"];
        
        statisticsArray = [PlanCache getTaskStatisticsByStartDate:startDate endDate:endDate];
        [self.tableStatistics reloadData];
    }
}

- (void)requestMonthDataWithTime:(NSString *)time {
    NSString *str = [time stringByReplacingOccurrencesOfString:@"/" withString:@""];
    NSDateFormatter *formater = [NSDateFormatter new];
    [formater setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [formater setDateFormat:@"yyyyMMdd"];
    NSDate *date = [formater dateFromString:str];
    monthDate = [date dateByAddingTimeInterval:8 * 3600];
    
    if (time && time.length > 8) {
        NSString *end;
        NSString *start = [time substringWithRange:NSMakeRange(5, 2)];
        start = [self setStrPrefixByStr:start];
        NSInteger month = [start integerValue];
        if ( month == 4 || month == 6 || month == 9
            || month == 11 ) {
            end = [start stringByAppendingString:@".30"];
        } else if(month == 2) {
            NSString *year = [time substringToIndex:3];
            if ([self bissextile:[year intValue]] ) {
                end = [start stringByAppendingString:@".28"];
            } else {
                end = [start stringByAppendingString:@".29"];
            }
        } else {
            end = [start stringByAppendingString:@".31"];
        }
        
        NSString *timeStr = [start stringByAppendingString:@".1"];
        if (end) {
            self.labelDate.text = [[timeStr stringByAppendingString:@" ~ "] stringByAppendingString:end];
        }
        
        if (time.length > 8 && end.length > 2) {
            NSString *start_month = [time substringToIndex:8];
            start_month = [start_month stringByAppendingString:@"01"];
            NSString *end_day = [end substringFromIndex:2];
            NSString *end_yearMonth = [time substringToIndex:8];
            end_yearMonth = [end_yearMonth stringByAppendingString:end_day];
            
            NSString *startDate = [[start_month stringByReplacingOccurrencesOfString:@"/" withString:@"-"] stringByAppendingString:@" 00:00:00"];
            
            NSString *endDate = [[end_yearMonth stringByReplacingOccurrencesOfString:@"/" withString:@"-"] stringByAppendingString:@" 23:59:59"];
            
            statisticsArray = [PlanCache getTaskStatisticsByStartDate:startDate endDate:endDate];
            [self.tableStatistics reloadData];
        }
    }
}

- (NSString *)setStrPrefixByStr:(NSString *)str {
    if ([str hasPrefix:@"0"]) {
        str = [str substringFromIndex:1];
    }
    return str;
}

- (BOOL)bissextile:(int)year {
    if ((year % 4 == 0 && year % 100 !=0) || year %400 == 0) {
        return YES;
    } else {
        return NO;
    }
    return NO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (statisticsArray.count > 0) {
        return statisticsArray.count;
    } else {
        return 2;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kTableViewCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (statisticsArray.count > 0) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[UITableViewCell description]];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:[UITableViewCell description]];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = @"";
        }
        if (statisticsArray.count > indexPath.row) {
            
            TaskStatistics *statistics = statisticsArray[indexPath.row];
            
            cell.textLabel.text = statistics.taskContent;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"本月完成次数：%ld", statistics.taskCount];
            cell.textLabel.font = font_Normal_16;
            cell.textLabel.textColor = color_333333;
            cell.detailTextLabel.font = font_Normal_14;
            cell.detailTextLabel.textColor = color_0BA32A;
        }
        
        return cell;
        
    } else {
        
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        static NSString *noDataCellIdentifier = @"noDataCellIdentifier";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:noDataCellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:noDataCellIdentifier];
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = @"";
            cell.textLabel.frame = cell.contentView.bounds;
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.textColor = [UIColor lightGrayColor];
            cell.textLabel.font = font_Bold_16;
        }
        if (indexPath.row == 1) {
            cell.textLabel.text = @"暂无数据";
        }
        return cell;
    }
}

@end
