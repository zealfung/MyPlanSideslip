//
//  PostsDetailContentCell.m
//  plan
//
//  Created by Fengzy on 16/1/2.
//  Copyright © 2016年 Fengzy. All rights reserved.
//

#import "PostsDetailContentCell.h"

@implementation PostsDetailContentCell

- (void)awakeFromNib {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

+ (PostsDetailContentCell *)cellView:(BmobObject *)posts {
    PostsDetailContentCell *cellView = [[NSBundle mainBundle] loadNibNamed:@"PostsDetailContentCell" owner:self options:nil].lastObject;

    NSString *content = [posts objectForKey:@"content"];
    CGFloat yOffset = 10;
    if (content && content.length > 0) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,0,0,0)];
        [label setNumberOfLines:0];
        label.lineBreakMode = NSLineBreakByWordWrapping;
        [label setTextColor:color_333333];
        UIFont *font = font_Normal_16;
        [label setFont:font];
        [label setText:content];
        CGSize size = CGSizeMake(WIDTH_FULL_SCREEN - 24, 2000);
        CGSize labelsize = [content sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
        label.frame = CGRectMake(12, yOffset, labelsize.width, labelsize.height);
        [cellView addSubview:label];
        yOffset = labelsize.height + 20;
    }
    NSArray *imgURLArray = [NSArray arrayWithArray:[posts objectForKey:@"imgURLArray"]];
    if (imgURLArray && imgURLArray.count > 0) {
        
        for (NSInteger i=0; i < imgURLArray.count; i++) {
            NSURL *URL = nil;
            if ([imgURLArray[i] isKindOfClass:[NSString class]]) {
                URL = [NSURL URLWithString:imgURLArray[i]];
                NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:URL];
                NSString *pathExtendsion = [URL.pathExtension lowercaseString];
                
                CGSize size = CGSizeZero;
                if ([pathExtendsion isEqualToString:@"png"]) {
                    size =  [CommonFunction getPNGImageSizeWithRequest:request];
                } else if([pathExtendsion isEqual:@"gif"]) {
                    size =  [CommonFunction getGIFImageSizeWithRequest:request];
                } else {
                    size = [CommonFunction getJPGImageSizeWithRequest:request];
                }
                if (CGSizeEqualToSize(CGSizeZero, size)) { // 如果获取文件头信息失败,发送异步请求请求原图
                    NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:URL] returningResponse:nil error:nil];
                    UIImage *image = [UIImage imageWithData:data];
                    if (image) {
                        size = image.size;
                    }
                    CGFloat kWidth = size.width;
                    CGFloat kHeight = size.height;
                    if (kWidth > WIDTH_FULL_SCREEN) {
                        kWidth = WIDTH_FULL_SCREEN;
                        kHeight = WIDTH_FULL_SCREEN * size.height / size.width;
                    }
                    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, yOffset, kWidth, kHeight)];
                    imageView.backgroundColor = [UIColor clearColor];
                    imageView.image = image;
                    imageView.clipsToBounds = YES;
                    imageView.contentMode = UIViewContentModeScaleToFill;
                    [cellView addSubview:imageView];
                    yOffset += kHeight + 3;
                } else {
                    CGFloat kWidth = size.width;
                    CGFloat kHeight = size.height;
                    if (kWidth > WIDTH_FULL_SCREEN) {
                        kWidth = WIDTH_FULL_SCREEN;
                        kHeight = fabs(WIDTH_FULL_SCREEN * size.height / size.width);
                    }
                    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, yOffset, kWidth, kHeight)];
                    imageView.backgroundColor = [UIColor clearColor];
                    imageView.clipsToBounds = YES;
                    imageView.contentMode = UIViewContentModeScaleToFill;
                    [imageView sd_setImageWithURL:URL placeholderImage:[UIImage imageNamed:png_Bg_LaunchImage]];
                    [cellView addSubview:imageView];
                    yOffset += kHeight + 3;
                }
            }
        }
    }
    return cellView;
}

@end
