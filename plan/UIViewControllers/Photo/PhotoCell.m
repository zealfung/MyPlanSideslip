//
//  PhotoCell.m
//  plan
//
//  Created by Fengzy on 15/10/6.
//  Copyright (c) 2015年 Fengzy. All rights reserved.
//

#import "PhotoCell.h"

CGFloat kPhotoCellHeight;


@implementation PhotoCell

- (void)awakeFromNib {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];

}

+ (PhotoCell *)cellView:(Photo *)photo {
    
    CGFloat contentHeight = [self setContentHeight:photo.content];
    
    PhotoCell *cell = [[PhotoCell alloc] initWithFrame:CGRectMake(0, 0, WIDTH_FULL_SCREEN, kPhotoCellHeight)];
    
    CGFloat xMargins = 8;
    CGFloat yMargins = 5;
    CGFloat xOffset = xMargins;
    CGFloat yOffset = yMargins;
    CGFloat dateWidth = 40;
    CGFloat dateHeight = 30;
    CGFloat btnAgeSize = 45;
    
    NSDate *photoDate = [CommonFunction NSStringDateToNSDate:photo.phototime formatter:str_DateFormatter_yyyy_MM_dd];
    
    UILabel *labelYear = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, dateWidth, dateHeight)];
    labelYear.textAlignment = NSTextAlignmentCenter;
    labelYear.font = font_Normal_16;
    labelYear.textColor = color_Blue;
    labelYear.text = [CommonFunction NSDateToNSString:photoDate formatter:@"yyyy"];
    [cell addSubview:labelYear];
    
    UILabel *labelMonthAndDay = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset + dateHeight / 2, dateWidth, dateHeight)];
    labelMonthAndDay.textAlignment = NSTextAlignmentCenter;
    labelMonthAndDay.font = font_Normal_13;
    labelMonthAndDay.textColor = color_Blue;
    labelMonthAndDay.text = [CommonFunction NSDateToNSString:photoDate formatter:@"MM/dd"];
    [cell addSubview:labelMonthAndDay];
    
    xOffset += dateWidth;
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(xOffset + btnAgeSize / 2 - 1, 0, 2, yOffset)];
    lineView.backgroundColor = color_Blue;
    [cell addSubview:lineView];
    
    UIView *lineView1 = [[UIView alloc] initWithFrame:CGRectMake(xOffset + btnAgeSize / 2 - 1, yOffset + btnAgeSize, 2, kPhotoCellHeight - yOffset -btnAgeSize)];
    lineView1.backgroundColor = color_Blue;
    [cell addSubview:lineView1];
    
    UIButton *btnAge = [[UIButton alloc] initWithFrame:CGRectMake(xOffset, yOffset, btnAgeSize, btnAgeSize)];
    btnAge.backgroundColor = color_Blue;
    btnAge.layer.cornerRadius = btnAgeSize / 2;
    btnAge.titleLabel.font = font_Bold_18;
    btnAge.tintColor = [UIColor whiteColor];
    [btnAge setTitle:[self getAge:photoDate] forState:UIControlStateNormal];
    [btnAge setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cell addSubview:btnAge];
    
    if (photo.location && photo.location.length > 0) {
        
        CGFloat locationWidth = WIDTH_FULL_SCREEN - xMargins - CGRectGetMaxX(btnAge.frame);
        UILabel *labelLocation = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(btnAge.frame), yOffset, locationWidth, dateHeight * 3 / 2)];
        labelLocation.textAlignment = NSTextAlignmentRight;
        labelLocation.font = font_Normal_16;
        labelLocation.textColor = color_Blue;
        labelLocation.text = [NSString stringWithFormat:@"%@%@", str_Photo_Location, photo.location];
        [cell addSubview:labelLocation];
        
    }

    xOffset = CGRectGetMaxX(lineView.frame) + xMargins;
    yOffset = CGRectGetMaxY(btnAge.frame) - yMargins;
    CGFloat contentWidth = WIDTH_FULL_SCREEN - xOffset - xMargins;
    
    if (contentHeight > 0) {

        UILabel *labelContent = [[UILabel alloc] initWithFrame:CGRectMake(xOffset, yOffset, contentWidth, contentHeight)];
        labelContent.textAlignment = NSTextAlignmentLeft;
        labelContent.font = font_Normal_13;
        labelContent.textColor = color_333333;
        labelContent.text = photo.content;
        if (contentHeight < 30) {
            
            labelContent.numberOfLines = 1;
            
        } else if (contentHeight < 60) {
            
            labelContent.numberOfLines = 2;
            
        } else {
            
            labelContent.numberOfLines = 3;
            
        }
        [cell addSubview:labelContent];
        
        yOffset = CGRectGetMaxY(labelContent.frame);
        
    } else {
        
        yOffset = CGRectGetMaxY(btnAge.frame) + yMargins;
    
    }
    
    NSInteger imageCount = photo.photoArray.count > 3 ? 3 : photo.photoArray.count;
    CGFloat imageSpace = 10;
    CGFloat imageWidth = (contentWidth - imageSpace * (imageCount - 1)) / imageCount;
    CGFloat photoHeight = kPhotoCellHeight - yOffset - yMargins * 2;

    UIView *photoView = [[UIView alloc] initWithFrame:CGRectMake(xOffset, yOffset, contentWidth, photoHeight)];
    [cell addSubview:photoView];
    
    CGFloat pXOffset = 0;
    for (NSInteger i = 0; i < imageCount; i++) {
        
        UIImage *image = photo.photoArray[i];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(pXOffset, 0, imageWidth, photoHeight)];
        imageView.image = image;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.layer.borderWidth = 1;
        imageView.layer.borderColor = [color_eeeeee CGColor];
        
        if (photo.photoArray.count > 3 && i == 2) {
            
            NSString *totalImgCount = [NSString stringWithFormat:@"%ld", (unsigned long)photo.photoArray.count];
            NSInteger btnTotalSize = 20;
            CGFloat btnX = imageWidth - btnTotalSize - xMargins;
            CGFloat btnY = photoHeight - btnTotalSize - yMargins;
            UIButton *btnTotal = [[UIButton alloc] initWithFrame:CGRectMake(btnX, btnY, btnTotalSize, btnTotalSize)];
            btnTotal.backgroundColor = color_57a4fe_05;
            btnTotal.layer.cornerRadius = btnTotalSize / 2;
            btnTotal.titleLabel.font = font_Normal_13;
            btnTotal.tintColor = [UIColor whiteColor];
            [btnTotal setTitle:totalImgCount forState:UIControlStateNormal];
            [btnTotal setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [imageView addSubview:btnTotal];
            
        }
        
        [photoView addSubview:imageView];
        
        pXOffset += imageWidth + imageSpace;
    }
    
    return cell;
    
}

+ (CGFloat)setContentHeight:(NSString *)content {
    
    CGFloat contentHeight = 0;
    
    if (!content || content.length == 0) {
        
        kPhotoCellHeight = 190;
        
    } else {
        
        CGFloat contentAutoHeight = [self autoContentHeight:content];
        
        if (contentAutoHeight < 30) {
            
            contentHeight = 25;
            
        } else if (contentAutoHeight < 60) {
            
            contentHeight = 50;
            
        } else {
            
            contentHeight = 75;
            
        }
        
        kPhotoCellHeight = 190 + contentHeight;
        
    }
    
    return contentHeight;
    
}

+ (CGFloat)autoContentHeight:(NSString *)content {
    
    CGSize  size = [content sizeWithFont:font_Normal_13 constrainedToSize:CGSizeMake(240, 2000)lineBreakMode:NSLineBreakByWordWrapping];
    
    return size.height + 10;
}

+ (NSString *)getAge:(NSDate *)photoDate {
    
    NSString *unknow = [NSString stringWithFormat:@"X%@", str_Photo_Age];
    if (![Config shareInstance].settings.birthday
        || [Config shareInstance].settings.birthday.length == 0) {
        
        return unknow;
    }
    
    NSDate *birthday = [CommonFunction NSStringDateToNSDate:[Config shareInstance].settings.birthday formatter:str_DateFormatter_yyyy_MM_dd];
    NSTimeInterval secondsBetweenDates= [photoDate timeIntervalSinceDate:birthday];

    if(secondsBetweenDates < 0) {
        
        return unknow;
        
    } else {
        
        long age = secondsBetweenDates / (365 * 24 * 60 * 60);
        return [NSString stringWithFormat:@"%ld%@", age, str_Photo_Age];
        
    }

}

@end
