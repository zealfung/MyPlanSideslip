//
//  PostsDetailViewController.m
//  plan
//
//  Created by Fengzy on 15/12/27.
//  Copyright © 2015年 Fengzy. All rights reserved.
//

#import "PostsDetailContentCell.h"
#import "PostsDetailViewController.h"

@interface PostsDetailViewController () <UITableViewDelegate, UITableViewDataSource> {
    
    CGFloat cell0Height;
}

@end

@implementation PostsDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)getCommets {
//    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Posts"];
//    [bquery includeKey:@"author"];
//    [bquery whereKey:@"objectId" equalTo:self.posts.objectId];
////    __weak typeof(self) weakSelf = self;
//    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
//        
//        if (!error && array.count == 1) {
//            
//        }
//    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    BmobObject *author = [self.posts objectForKey:@"author"];
    NSString *nickName = [author objectForKey:@"nickName"];
    if (!nickName || nickName.length == 0) {
        nickName = @"匿名者";
    }
    NSString *avatarURL = [author objectForKey:@"avatarURL"];
//    NSString *content = [self.posts objectForKey:@"content"];
//    NSString *isTop = [self.posts objectForKey:@"isTop"];
//    NSString *isHighlight = [self.posts objectForKey:@"isHighlight"];
//    NSArray *imgURLArray = [NSArray arrayWithArray:[self.posts objectForKey:@"imgURLArray"]];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH_FULL_SCREEN, 50)];
    view.backgroundColor = [UIColor whiteColor];
    view.layer.borderWidth = 1;
    view.layer.borderColor = [color_dedede CGColor];
    //图像
    UIImageView *avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 5, 40, 40)];
    avatarView.layer.cornerRadius = 20;
    avatarView.clipsToBounds = YES;
    [avatarView sd_setImageWithURL:[NSURL URLWithString:avatarURL] placeholderImage:[UIImage imageNamed:png_AvatarDefault1]];
    avatarView.contentMode = UIViewContentModeScaleAspectFit;
    [view addSubview:avatarView];
    //昵称
    UILabel *labelNickName = [[UILabel alloc] initWithFrame:CGRectMake(57, 0, WIDTH_FULL_SCREEN / 2, 30)];
    labelNickName.textColor = color_Blue;
    labelNickName.font = font_Normal_16;
    labelNickName.text = nickName;
    [view addSubview:labelNickName];
    //发表时间
    UILabel *labelDate = [[UILabel alloc] initWithFrame:CGRectMake(57, 30, WIDTH_FULL_SCREEN / 2, 20)];
    labelDate.textColor = color_666666;
    labelDate.font = font_Normal_13;
    labelDate.text = [CommonFunction NSDateToNSString:self.posts.createdAt formatter:str_DateFormatter_yyyy_MM_dd_HHmm];
    [view addSubview:labelDate];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        if (cell0Height > 0) {
            return cell0Height;
        } else {
            cell0Height = [self cellHeight:self.posts];
            return cell0Height;
        }
    } else {
        return 44.f;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        PostsDetailContentCell *cell = [PostsDetailContentCell cellView:self.posts];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)cellHeight:(BmobObject *)obj {
    NSString *content = [obj objectForKey:@"content"];
    CGFloat yOffset = 10;
    if (content && content.length > 0) {
        UIFont *font = font_Normal_16;
        CGSize size = CGSizeMake(WIDTH_FULL_SCREEN - 24, 2000);
        CGSize labelsize = [content sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
        yOffset = labelsize.height + 20;
    }
    NSArray *imgURLArray = [NSArray arrayWithArray:[obj objectForKey:@"imgURLArray"]];
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
                }
                CGFloat kWidth = fabs(size.width);
                CGFloat kHeight = fabs(size.height);
                if (kWidth > WIDTH_FULL_SCREEN) {
                    kHeight = WIDTH_FULL_SCREEN * size.height / size.width;
                }
                yOffset += kHeight + 10;
            }
        }
    }
    return fabs(yOffset);
}

@end
