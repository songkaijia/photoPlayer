//
//  SKPlayerCell.m
//  SKsinaWeibo
//
//  Created by jiasongkai on 14/4/14.
//  Copyright (c) 2014年 jiasongkai. All rights reserved.
//

#import "SKPlayerCell.h"
#import <UIImageView+WebCache.h>
#import "SKProgressView.h"
@interface SKPlayerCell () <UIScrollViewDelegate>

@property (nonatomic, weak) UIScrollView *sc;
@property (nonatomic, assign, getter=isShortImage) BOOL shortImage;
@property (nonatomic, strong) SKProgressView *progressView;


@end
@implementation SKPlayerCell



- (UIImageView *)imageView
{
    if (!_imageView) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.userInteractionEnabled = YES;
        [self.sc addSubview:imageView];
        [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close)]];
        //[imageView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(transformview)]];
        _imageView = imageView;
    
    }
    return _imageView;
}


- (UIScrollView *)sc
{
    if (!_sc) {
        UIScrollView *sc = [[UIScrollView alloc] init];
        sc.showsHorizontalScrollIndicator = NO;
        sc.showsVerticalScrollIndicator = NO;
        sc.bounces = NO;
        sc.minimumZoomScale = 0.5;
        sc.maximumZoomScale = 2.0;
        sc.backgroundColor = [UIColor clearColor];
        sc.delegate = self;
       
        [sc addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close)]];
        [self addSubview:sc];
        _sc = sc;

    }
    return _sc;
}

- (void)close
{
    [[NSNotificationCenter defaultCenter] postNotificationName:CLOSE object:nil];
   
}
#warning 为什么不调用这个方法。
//- (void)awakeFromNib
//{
//        self.sc = sc;
//   
//    self.imageView = imageView;
//    
//    
//    
//}

- (void)setPhotoURL:(NSString *)photoURL
{
    _photoURL = photoURL;
    self.sc.contentSize = CGSizeZero;
    self.sc.contentInset = UIEdgeInsetsZero;
    
#warning 这里的图片不应该去缓存池里面取的吗，怎么回事。
    __weak typeof(self) weakSelf = self;

    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:[NSURL URLWithString:self.palceURL] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        [weakSelf setupImageviewSize:image];
        weakSelf.imageView.image = image;
        
        
        __weak typeof(weakSelf) weakSSelf = weakSelf;

        [manager downloadImageWithURL:[NSURL URLWithString:_photoURL] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            weakSSelf.progressView.frame = CGRectMake((weakSSelf.imageView.width - 40) * 0.5, (weakSSelf.imageView.height - 40) * 0.5, 40, 40);
            
            [weakSSelf.imageView addSubview:self.progressView];
            
            weakSSelf.progressView.progress = (CGFloat)receivedSize / expectedSize;
            if (weakSSelf.progressView.progress == 1) {
                [weakSSelf.progressView removeFromSuperview];
            }
            
            
            
        }completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (finished) {
                
                weakSSelf.imageView.image = image;
            }
        }];
        DDLogInfo(@"%@", image);
    }];
    
    
}

- (void)setupImageviewSize:(UIImage *)image
{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if (image == nil) {
        return;
    }
    CGFloat imageHeight = image.size.height / image.size.width * screenSize.width;
    self.imageView.frame = CGRectMake(0, 0, screenSize.width, imageHeight);
    if (imageHeight < screenSize.height) {
        CGFloat imageX = (screenSize.height - imageHeight) * 0.5;
        self.sc.contentInset = UIEdgeInsetsMake(imageX, 0, 0, 0);
    }else{
        self.sc.contentSize = CGSizeMake(screenSize.width, imageHeight);
    }
    //self.imageView.image = image;
}


- (void)willMoveToWindow:(UIWindow *)newWindow
{
    [super willMoveToWindow:newWindow];
    self.sc.frame = self.bounds;
    
}
- (void)didMoveToWindow
{
    [super didMoveToWindow];
//    [UIView animateWithDuration:1 animations:^{
//        
//        
//        self.imageView.frame = CGRectMake(100, 100, 200, 200);
//    }];
    self.autoresizingMask = YES;
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    CGFloat imageY = 0;
    CGFloat imageX = 0;
    if (self.imageView.width < scrollView.width) {
        imageY = (scrollView.width - self.imageView.width) * 0.5;
    }
    if (self.imageView.height < scrollView.height) {
        
         imageX = (scrollView.height - self.imageView.height) * 0.5;
    
    }
    [UIView animateWithDuration:0.2 animations:^{
        self.sc.contentInset = UIEdgeInsetsMake(imageX, imageY, 0, 0);
    }];
}
- (void)prepareForReuse
{
    [super prepareForReuse];
    self.imageView.image = nil;
}
- (SKProgressView *)progressView
{
    if (!_progressView) {
        _progressView = [[SKProgressView alloc] init];
        _progressView.backgroundColor = [UIColor whiteColor];
    }
    return _progressView;
}
@end
