//
//  SKPlayerView.h
//  SKsinaWeibo
//
//  Created by jiasongkai on 14/4/14.
//  Copyright (c) 2014年 jiasongkai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SKPlayerView : UIView



@property (nonatomic, strong) NSArray *photoes;

@property (nonatomic, strong) NSArray *viewes;

@property (nonatomic, strong) NSArray *placePhotoes;


+ (instancetype)playerViewWithView:(UIView *)view image:(UIImage *)image atIndex:(NSUInteger)index;

- (void)show;

@end
