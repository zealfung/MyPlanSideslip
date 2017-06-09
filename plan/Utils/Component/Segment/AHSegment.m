//
//  AHSegment.m
//  plan
//
//  Created by Fengzy on 2017/6/3.
//  Copyright © 2017年 Fengzy. All rights reserved.
//

#import "AHSegment.h"


@interface AHSegment ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSArray *widthArray;
@property (nonatomic, assign) NSInteger allButtonW;
@property (nonatomic, strong) UIView *divideView;
@property (nonatomic, strong) UIView *divideLineView;

@end

@implementation AHSegment

- (instancetype)initWithFrame:(CGRect)frame
{
    
    if (self = [super initWithFrame:frame])
    {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height-0.5)];
        _scrollView.clipsToBounds = YES;
        _scrollView.backgroundColor = [UIColor whiteColor];
        _scrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:_scrollView];
        
        _divideLineView = [[UIView alloc] init];
        _divideLineView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [_scrollView addSubview:_divideLineView];
        
        _divideView  = [[UIView alloc] init];
        _divideView.backgroundColor = [Utils getGenderColor];
        [_scrollView addSubview:_divideView];
        
    }
    return self;
}

- (UIFont*)textFont
{
    return _textFont ? : font_Bold_18;
}


- (void)updateChannels:(NSArray*)array
{
    NSMutableArray *widthMutableArray = [NSMutableArray array];
    NSInteger totalW = 0;
    
    for (int i = 0; i < array.count; i++)
    {
        NSString *string = [array objectAtIndex:i];
        CGFloat buttonW = [string boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.textFont} context:nil].size.width + 20;
        [widthMutableArray addObject:@(buttonW)];
        totalW += buttonW;
    }
    
    if (totalW > WIDTH_FULL_SCREEN)
    {
        for (int i = 0; i < widthMutableArray.count; i++)
        {
            NSString *string = [array objectAtIndex:i];
            CGFloat buttonW = [[widthMutableArray objectAtIndex:i] floatValue];
            
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(totalW, 0, buttonW, self.bounds.size.height)];
            button.tag = 1000 + i;
            [button.titleLabel setFont:self.textFont];
            [button setTitleColor:color_666666 forState:UIControlStateNormal];
            [button setTitleColor:[Utils getGenderColor] forState:UIControlStateSelected];
            [button setTitle:string forState:UIControlStateNormal];
            [button addTarget:self action:@selector(clickSegmentButton:) forControlEvents:UIControlEventTouchUpInside];
            [self.scrollView addSubview:button];
            totalW += buttonW;
            
            if (i == 0)
            {
                [button setSelected:YES];
                _divideView.frame = CGRectMake(0, _scrollView.bounds.size.height-2, buttonW, 2);
                _selectedIndex = 0;
            }
        }
    }
    else
    {
        totalW = WIDTH_FULL_SCREEN;
        widthMutableArray = [NSMutableArray array];
        for (int i = 0; i < array.count; i++)
        {
            NSString *string = [array objectAtIndex:i];
            CGFloat buttonW = WIDTH_FULL_SCREEN / array.count;
            [widthMutableArray addObject:@(buttonW)];
            
            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(buttonW * i, 0, buttonW, self.bounds.size.height)];
            button.tag = 1000 + i;
            [button.titleLabel setFont:self.textFont];
            [button setTitleColor:color_666666 forState:UIControlStateNormal];
            [button setTitleColor:[Utils getGenderColor] forState:UIControlStateSelected];
            [button setTitle:string forState:UIControlStateNormal];
            [button addTarget:self action:@selector(clickSegmentButton:) forControlEvents:UIControlEventTouchUpInside];
            [self.scrollView addSubview:button];
            
            if (i == 0)
            {
                [button setSelected:YES];
                _divideView.frame = CGRectMake(0, _scrollView.bounds.size.height-2, buttonW, 2);
                _selectedIndex = 0;
            }
        }
    }
    
    _allButtonW = totalW;
    _scrollView.contentSize = CGSizeMake(totalW, 0);
    _widthArray = [widthMutableArray copy];
    _divideLineView.frame = CGRectMake(0, _scrollView.frame.size.height-2, totalW, 2);
}

- (void)clickSegmentButton:(UIButton*)selectedButton
{
    UIButton *oldSelectButton = (UIButton*)[_scrollView viewWithTag:(1000 + _selectedIndex)];
    [oldSelectButton setSelected:NO];
    
    [selectedButton setSelected:YES];
    _selectedIndex = selectedButton.tag - 1000;
    
    NSInteger totalW = 0;
    for (int i=0; i<_selectedIndex; i++)
    {
        totalW += [[_widthArray objectAtIndex:i] integerValue];
    }
    
    //处理边界
    CGFloat selectW = [[_widthArray objectAtIndex:_selectedIndex] integerValue];
    CGFloat offset = totalW + (selectW - self.bounds.size.width) *0.5 ;
    offset = MIN(_allButtonW - self.bounds.size.width, MAX(0, offset));
    
    [_scrollView setContentOffset:CGPointMake(offset, 0) animated:YES];
    if ([_delegate respondsToSelector:@selector(AHSegment:didSelectedIndex:)])
    {
        [_delegate AHSegment:self didSelectedIndex:_selectedIndex];
    }
    
    //滑块
    [UIView animateWithDuration:0.1 animations:^{
        _divideView.frame = CGRectMake(totalW, _divideView.frame.origin.y, selectW, _divideView.frame.size.height);
    }];
}

- (void)didChengeToIndex:(NSInteger)index
{
    UIButton *selectedButton = [_scrollView viewWithTag:(1000 + index)];
    [self clickSegmentButton:selectedButton];
}

@end
