//
//  SKPlayerCell.h
//  SKsinaWeibo
//
//  Created by jiasongkai on 14/4/14.
//  Copyright (c) 2014年 jiasongkai. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *const CLOSE = @"closeWindow";
@interface SKPlayerCell : UICollectionViewCell


@property (nonatomic, copy) NSString *photoURL;

@property (nonatomic, copy) NSString *palceURL;
@property (nonatomic, weak) UIImageView *imageView;

@end
