//
//  SKPlayerView.m
//  SKsinaWeibo
//
//  Created by jiasongkai on 14/4/14.
//  Copyright (c) 2014年 jiasongkai. All rights reserved.
//

#import "SKPlayerView.h"
#import "SKPlayerCell.h"
#
@interface SKPlayerView () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *photoPlayerCollectionview;

@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *photoCellLayout;

@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (nonatomic, assign) NSIndexPath *index;
@property (nonatomic, strong) UIWindow *shandowWindow;
@property (nonatomic, assign) CGRect rect;
@property (nonatomic, weak) UIView *inview;

@property (nonatomic, assign) CGRect presentRect;
@property (nonatomic, strong) UIImage *image;

@end

@implementation SKPlayerView



+ (instancetype)playerViewWithView:(UIView *)view image:(UIImage *)image atIndex:(NSUInteger)index{
    SKPlayerView *playView = [[NSBundle mainBundle] loadNibNamed:@"SKPlayerView" owner:nil options:nil].lastObject;
    playView.index = [NSIndexPath indexPathForItem:index inSection:0];
    playView.inview = view;
    playView.rect = [playView.shandowWindow convertRect:view.frame fromView:view.superview];
    playView.image = image;
    
    return playView;
}
- (void)awakeFromNib
{
    [self.photoPlayerCollectionview registerClass:[SKPlayerCell class] forCellWithReuseIdentifier:@"photoPlayerCell"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeWindow:) name:CLOSE object:nil];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)closeWindow:(NSNotification *)note
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    SKPlayerCell *cell = [self.photoPlayerCollectionview.visibleCells lastObject];
    NSIndexPath *path = [self.photoPlayerCollectionview.indexPathsForVisibleItems lastObject];
    CGFloat marginY = (cell.height - cell.imageView.height) * 0.5;
    CGRect rect = [self.shandowWindow convertRect:cell.imageView.frame fromView:cell];
    CGRect marginRect = CGRectMake(0, marginY, rect.size.width, rect.size.height);
    self.shandowWindow = nil;
    
    UIView *view = self.viewes[path.item];
    DDLogDebug(@"%tu", path.item);
    CGRect cellRect = [keyWindow convertRect:view.frame fromView:view.superview];
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:marginRect];
    imageview.contentMode = UIViewContentModeScaleAspectFill;
    imageview.clipsToBounds = YES;
    imageview.image = cell.imageView.image;
    [keyWindow addSubview:imageview];
    [keyWindow bringSubviewToFront:imageview];
    
    view.hidden = YES;
    [UIView animateWithDuration:0.5 animations:^{
        imageview.frame = cellRect;
        
    } completion:^(BOOL finished) {
        view.hidden = NO;
        [imageview removeFromSuperview];
    }];

}
- (void)willMoveToWindow:(UIWindow *)newWindow
{
    [super willMoveToWindow:newWindow];
    self.photoCellLayout.itemSize = [UIScreen mainScreen].bounds.size;
    self.photoCellLayout.minimumInteritemSpacing = 0;
    self.photoCellLayout.minimumLineSpacing = 0;
    self.photoCellLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.photoPlayerCollectionview.pagingEnabled = YES;
    self.frame = [UIScreen mainScreen].bounds;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    [self.photoPlayerCollectionview scrollToItemAtIndexPath:self.index atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    SKPlayerCell *cell = (SKPlayerCell *)[self.photoPlayerCollectionview cellForItemAtIndexPath:self.index];
    /**
     * 理论：1，在需要开始动画的地方新创建一个imageview，并将显示出来的cell的imageview隐藏
     *      2，在设置图片的时候用传入的图片的尺寸，因为cell的imageview的图片是后台线程执行的可能还没有下载号。imageview的
     *         尺寸为0.
     *      3，利用屏幕的宽高和传入的图片的宽高来计算应该移动到的地方。
     *      4，创建动画。
     *      5，动画完成后则将imageview移除，并将cell的imageview显示。
     */
//    DDLogDebug(@"%@", cell.imageView);
    cell.hidden = YES;
    UIImageView *imageview = [[UIImageView alloc] init];
    imageview.frame = self.rect;
    imageview.image = self.image;
    [self.shandowWindow addSubview:imageview];
    [self.shandowWindow bringSubviewToFront:imageview];
    CGFloat imageviewY = 0;
    CGFloat imageWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat imageHeight = imageWidth / self.image.size.width * self.image.size.height;
    if (imageHeight < [UIScreen mainScreen].bounds.size.height) {
        imageviewY = ([UIScreen mainScreen].bounds.size.height - imageHeight) * 0.5;
           }
    CGFloat imageX = 0;
    CGRect imageViewframe = CGRectMake(imageX, imageviewY, imageWidth, imageHeight);
    [UIView animateWithDuration:0.5 animations:^{
        imageview.frame = imageViewframe;
       
    } completion:^(BOOL finished) {
        cell.hidden = NO;
        [imageview removeFromSuperview];
    }];
    self.countLabel.text = [NSString stringWithFormat:@"%tu/%tu", self.index.item + 1, self.photoes.count];
#warning 1.转化坐标系，使cell的transform改变，并是图片正好在原图片的位置。
    {
//    CGFloat scale = CGRectGetWidth(self.rect) / cell.width;
//    cell.transform = CGAffineTransformMakeScale(scale, scale);
////    CGFloat cellY = self.rect.origin.y + (cell.height - cell.imageView.height) * 0.5;
////    NSLog(@"imageViewHeith%tu, cellHeight%tu", cell.imageView.height, cell.height);
////    CGFloat cellX = [UIScreen mainScreen].bounds.size.width * self.index.item + self.rect.origin.x;
//   // CGFloat cellY = self.rect.origin.y + 20;
//    
//    CGFloat cellX = [UIScreen mainScreen].bounds.size.width * self.index.item + self.rect.origin.x;
//    CGFloat cellY;
//    
//    cellY = self.rect.origin.y + (cell.height - self.rect.size.height) * 0.5;
//   
//    cell.origin = CGPointMake(cellX, cellY);
//   // DDLogDebug(@"%@, %@", NSStringFromCGRect(cell.frame), NSStringFromCGRect(self.rect));
//    //DDLogDebug(@"转换前高度%tu, 调整后高度%tu" , self.rect.origin.y, cell.y);
//    [UIView animateWithDuration:0.5 animations:^{
//        cell.transform = CGAffineTransformIdentity;
//        cell.frame = self.presentRect;
//    }];
//    //
//    
//    self.countLabel.text = [NSString stringWithFormat:@"%tu/%tu", self.index.item + 1, self.photoes.count];
    }
#warning 2.考虑图片的填充效果，真实设置。
    {
//    CGFloat cellX, cellY, scale;
//    if (cell.imageView.image.size.width > cell.imageView.image.size.height) {
//        scale = CGRectGetHeight(self.rect) / cell.imageView.height;
//        cell.transform = CGAffineTransformMakeScale(scale, scale);
//        cellX = [UIScreen mainScreen].bounds.size.width * self.index.item + self.rect.origin.x - (cell.width - cell.imageView.width) * 0.5;
//        cellY = self.rect.origin.y - (cell.height - cell.imageView.height) * 0.5;
//    }else{
//        scale = CGRectGetWidth(self.rect) / cell.imageView.width;
//        cell.transform = CGAffineTransformMakeScale(scale, scale);
//        cellX = [UIScreen mainScreen].bounds.size.width * self.index.item + self.rect.origin.x;
//        cellY = self.rect.origin.y - (cell.height - CGRectGetHeight(self.rect)) * 0.5;
//    }
//    [UIView animateWithDuration:0.5 animations:^{
//                cell.transform = CGAffineTransformIdentity;
//                cell.frame = self.presentRect;
//            }];
//        
    }
    
}


- (IBAction)save:(id)sender {
    
    
    SKPlayerCell *cell = [self.photoPlayerCollectionview.visibleCells lastObject];
    UIImageWriteToSavedPhotosAlbum(cell.imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    
    
    
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error == nil) {
        
        [self dumpLabelWithAnimationWithString:@"保存图片成功"];
        
        
    }else
    {
        [self dumpLabelWithAnimationWithString:@"保存图片失败"];
    }
}

- (void)dumpLabelWithAnimationWithString:(NSString *)str
{
    CGFloat labelWidth = 150;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((SCREENWIDTH - labelWidth) * 0.5 , (SCREENHEIGHT - labelWidth * 0.5) * 0.5, labelWidth, labelWidth * 0.5)];
    label.backgroundColor = [UIColor whiteColor];
    label.text = str;
    label.textAlignment = NSTextAlignmentCenter;
    label.layer.cornerRadius = 20;
    label.layer.masksToBounds = YES;
    
    [self.shandowWindow addSubview:label];
    label.alpha = 0;
    [UIView animateWithDuration:0.8 animations:^{
        label.alpha = 0.7;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.8 delay:1 options:0 animations:^{
            label.alpha = 0;
        } completion:^(BOOL finished) {
            [label removeFromSuperview];
        }];
    }];
}
- (void)setPhotoes:(NSArray *)photoes
{
    _photoes = photoes;
    [self.photoPlayerCollectionview reloadData];
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photoes.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    SKPlayerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"photoPlayerCell" forIndexPath:indexPath];
#warning 未完成，待续
    
    //cell.backgroundColor = [UIColor clearColor];
    
    cell.palceURL = self.placePhotoes[indexPath.item];
    cell.photoURL = self.photoes[indexPath.item];
    
    return cell;

}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSIndexPath *indexpath = [self.photoPlayerCollectionview.indexPathsForVisibleItems lastObject];
    
    self.countLabel.text = [NSString stringWithFormat:@"%tu/%tu", indexpath.item + 1, self.photoes.count];
}

- (UIWindow *)shandowWindow
{
    if (!_shandowWindow) {
        UIWindow *window = [[UIWindow alloc] init];
        window.frame = [UIScreen mainScreen].bounds;
        
        // window.windowLevel = MAXFLOAT;
        [window addSubview:self];
        
        _shandowWindow = window;
    }
    return _shandowWindow;
}
- (void)show
{
   self.shandowWindow.hidden = NO;
}
- (IBAction)back:(UIButton *)sender {
    self.shandowWindow = nil;
}

- (void)setViewes:(NSArray *)viewes
{
    NSMutableArray *viewArray = [NSMutableArray array];
    for (UIView *view in viewes) {
        if (view.hidden == NO) {
            [viewArray addObject:view];
        }
    }
    _viewes = viewArray;
#warning 图片排序不需要用frame.origin,直接将y写入即可。
    NSSortDescriptor *viewY = [NSSortDescriptor sortDescriptorWithKey:@"y" ascending:YES];
    NSSortDescriptor *viewX = [NSSortDescriptor sortDescriptorWithKey:@"x" ascending:YES];
    NSArray *array = @[viewY, viewX];
    _viewes = [_viewes sortedArrayUsingDescriptors:array];

    
}
@end
