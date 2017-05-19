//
//  SortBasicCollectionCellLayout.m
//  XPCollectionViewCellsSort
//
//  Created by Carlw on 2017/2/16.
//  Copyright © 2017年 wxp2012. All rights reserved.
//

#import "SortBasicCollectionCellLayout.h"
#import "SortCollectionViewCell.h"
#import "UIColor+Additions.h"

typedef NS_ENUM(NSInteger, DragScrollDirction) {
    DragScrollDirctionNone,
    DragScrollDirctionUp, //往上滚动
    DragScrollDirctionDown //往下滚动
};

@interface SortCollectionFakeView : UIView
    
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
    
@end

@implementation SortCollectionFakeView
    
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetWidth(frame))];
        self.imageView.layer.cornerRadius = 10.f;
        self.imageView.layer.masksToBounds = YES;
        [self addSubview:self.imageView];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.imageView.frame), CGRectGetWidth(self.imageView.frame), CGRectGetHeight(frame) - CGRectGetWidth(frame))];
        self.titleLabel.textColor = [UIColor colorFromHexValue:0x777777];
        self.titleLabel.font = [UIFont systemFontOfSize:13.];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.titleLabel];
    }
    return self;
}
    
    @end


@interface SortBasicCollectionCellLayout ()<UIGestureRecognizerDelegate>
@property (nonatomic, strong) SortCollectionFakeView *cellFakeView;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) DragScrollDirction dragScrollDirection;
@property (nonatomic, strong) NSIndexPath *reorderingCellIndexPath;
@property (nonatomic, assign) CGPoint cellFakeViewCenter;
@property (nonatomic, assign) CGPoint panTranslation;
@property (nonatomic, assign) BOOL setUped;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) NSMutableArray *indexPathsToAnimate;
@property (nonatomic, assign) NSInteger fakeViewOldyoffset;
@property (nonatomic, assign) NSInteger fakeViewOldxoffset;
@property (nonatomic, assign) CGRect fakeViewFrame;
@end

@implementation SortBasicCollectionCellLayout

- (void)prepareLayout {
    [super prepareLayout];
    
    [self setUpCollectionViewGesture];
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    UICollectionViewLayoutAttributes *attr = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
    if ([_indexPathsToAnimate containsObject:itemIndexPath]) {
        [_indexPathsToAnimate removeObject:itemIndexPath]; //确保只会出现一次
    }
    return attr;
}

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems
{
    [super prepareForCollectionViewUpdates:updateItems];
    NSMutableArray *indexPaths = [NSMutableArray array];
    for (UICollectionViewUpdateItem *updateItem in updateItems) {
        switch (updateItem.updateAction) {
            case UICollectionUpdateActionInsert:
                [indexPaths addObject:updateItem.indexPathAfterUpdate];
                break;
            case UICollectionUpdateActionDelete:
                [indexPaths addObject:updateItem.indexPathBeforeUpdate];
                break;
            case UICollectionUpdateActionMove:
                [indexPaths addObject:updateItem.indexPathBeforeUpdate];
                [indexPaths addObject:updateItem.indexPathAfterUpdate];
                break;
            default:
                break;
        }
    }
    self.indexPathsToAnimate = indexPaths;
}

- (void)finalizeCollectionViewUpdates
{
    [super finalizeCollectionViewUpdates];
    self.indexPathsToAnimate = nil;
}

#pragma mark - 添加手势
- (void)setUpCollectionViewGesture
{
    if (!_setUped) {
        _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        _longPressGesture.delegate = self;
        _panGesture.delegate = self;
        for (UIGestureRecognizer *gestureRecognizer in self.collectionView.gestureRecognizers) {
            if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
                [gestureRecognizer requireGestureRecognizerToFail:_longPressGesture]; }}
        [self.collectionView addGestureRecognizer:_longPressGesture];
        [self.collectionView addGestureRecognizer:_panGesture];
        _setUped = YES;
    }
}

- (void)setUpDisplayLink
{
    if (_displayLink) {
        return;
    }
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(autoScroll)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

-  (void)stopScroll
{
    [_displayLink invalidate];
    _displayLink = nil;
}

- (void)autoScroll
{
    CGPoint contentOffset = self.collectionView.contentOffset;
    UIEdgeInsets contentInset = self.collectionView.contentInset;
    CGFloat increment = 0;
    
    if (self.dragScrollDirection == DragScrollDirctionDown) {
        increment = 10.f;
    }else if (self.dragScrollDirection == DragScrollDirctionUp) {
        increment = -10.f;
    }
    
    //获取到最后一排cell的y轴
    NSInteger line = 0;
    if (self.commonCount%4 == 0) {
        line = self.commonCount/4;
    }else{
        line = self.commonCount/4+1;
    }
    CGFloat yoffset = 40 + 15 + CGRectGetHeight(self.fakeViewFrame)*(line-1) + 15*(line-1);
    if (CGRectGetMidY(_cellFakeView.frame) >= yoffset) { //如果刚好拖动到最后一排cell的y轴
        _cellFakeViewCenter = CGPointMake(_cellFakeViewCenter.x, _cellFakeViewCenter.y);
        _cellFakeView.center = CGPointMake(_cellFakeViewCenter.x + _panTranslation.x, _cellFakeViewCenter.y + _panTranslation.y);
        [self stopScroll];
        return;
    }
    
    if (contentOffset.y + increment <= -contentInset.top) { //到达最顶端时
        [UIView animateWithDuration:.07f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            CGFloat diff = -contentInset.top - contentOffset.y;
            self.collectionView.contentOffset = CGPointMake(contentOffset.x, -contentInset.top);
            _cellFakeViewCenter = CGPointMake(_cellFakeViewCenter.x, _cellFakeViewCenter.y + diff);
            _cellFakeView.center = CGPointMake(_cellFakeViewCenter.x + _panTranslation.x, _cellFakeViewCenter.y + _panTranslation.y);
        } completion:nil];
        [self stopScroll];
        return;
    }
    
    [self.collectionView performBatchUpdates:^{
        _cellFakeViewCenter = CGPointMake(_cellFakeViewCenter.x, _cellFakeViewCenter.y + increment);
        _cellFakeView.center = CGPointMake(_cellFakeViewCenter.x + _panTranslation.x, _cellFakeViewCenter.y + _panTranslation.y);
        self.collectionView.contentOffset = CGPointMake(contentOffset.x, contentOffset.y + increment);
    } completion:nil];
    [self moveItemIfNeeded];
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)longPress
{
    switch (longPress.state) {
        case UIGestureRecognizerStateBegan: {
            //索引的cell
            NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:[longPress locationInView:self.collectionView]];
            //索引的cell
            _reorderingCellIndexPath = indexPath;
            //是否能够拖动
            if ([self.datasource respondsToSelector:@selector(canMoveSortCollectionViewItemAtIndex)]) {
                if (![self.datasource canMoveSortCollectionViewItemAtIndex]) {
                    return;
                }
            }
            //第二个section禁用
            if (indexPath.section != 0) {
                return;
            }
            
            //滚动到顶部关闭
            self.collectionView.scrollsToTop = NO;
            //cell的tempview
            SortCollectionViewCell *cell = (SortCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
            cell.alpha = 0.3;
            self.fakeViewOldyoffset = CGRectGetMinY(cell.frame);
            self.fakeViewOldxoffset = CGRectGetMinX(cell.frame);
            _cellFakeView = [[SortCollectionFakeView alloc] initWithFrame:cell.frame];
            _cellFakeView.layer.shadowColor = [UIColor blackColor].CGColor;
            _cellFakeView.layer.shadowOffset = CGSizeMake(0, 0);
            _cellFakeView.layer.shadowOpacity = .5f;
            _cellFakeView.layer.shadowRadius = 3.f;
            _cellFakeView.backgroundColor = [UIColor clearColor];
            cell.highlighted = YES;
            cell.highlighted = NO;
            
            [self.collectionView addSubview:_cellFakeView];
            
            self.cellFakeViewCenter = _cellFakeView.center;
            
            //将图片和title放到fakeview上
            _cellFakeView.imageView.image = cell.imageButton.imageView.image;
            _cellFakeView.titleLabel.text = cell.titleButton.titleLabel.text;
            //
            _cellFakeViewCenter = _cellFakeView.center;
            [self invalidateLayout];
            
            
            //长按动画
            CGRect fakeViewRect = CGRectMake(cell.center.x - (cell.bounds.size.width / 2.f), cell.center.y - (cell.bounds.size.height / 2.f), cell.bounds.size.width, cell.bounds.size.height);
            self.fakeViewFrame = fakeViewRect;
            [UIView animateWithDuration:.3f delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
                _cellFakeView.center = cell.center;
                _cellFakeView.frame = fakeViewRect;
                _cellFakeView.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
            } completion:^(BOOL finished) {
                
            }];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            NSIndexPath *currentCellIndexPath = _reorderingCellIndexPath;
            
            //当前选择的cell
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:currentCellIndexPath];
            //是否能够拖动
            if ([self.datasource respondsToSelector:@selector(canMoveSortCollectionViewItemAtIndex)]) {
                if (![self.datasource canMoveSortCollectionViewItemAtIndex]) {
                    cell.alpha = 1.0f;
                    return;
                }
            }
            
            //滚动到顶部打开
            self.collectionView.scrollsToTop = YES;
            //禁用滚动
            [self stopScroll];
            //移除掉cell的tempview
            UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:currentCellIndexPath];
            [UIView animateWithDuration:.3f delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut animations:^{
                _cellFakeView.transform = CGAffineTransformIdentity;
                _cellFakeView.frame = attributes.frame;
            } completion:^(BOOL finished) {
                [_cellFakeView removeFromSuperview];
                _cellFakeView = nil;
                _reorderingCellIndexPath = nil;
                _cellFakeViewCenter = CGPointZero;
                [self invalidateLayout];
                
                //改变cell的透明
                cell.alpha = 1.0f;
                
                if ([self.datasource respondsToSelector:@selector(moveSortCollectionViewItemDone)]) {
                    [self.datasource moveSortCollectionViewItemDone];
                }
                
            }];
            
            break;
        }
        default:
            break;
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)pan
{
    switch (pan.state) {
        case UIGestureRecognizerStateChanged: {
            //变换移动的点
            _panTranslation = [pan translationInView:self.collectionView];
            //是否能够拖动
            if ([self.datasource respondsToSelector:@selector(canMoveSortCollectionViewItemAtIndex)]) {
                if (![self.datasource canMoveSortCollectionViewItemAtIndex]) {
                    return;
                }
            }
            
            //获取到最后一排cell的y轴
            NSInteger line = 0;
            if (self.commonCount%4 == 0) {
                line = self.commonCount/4;
            }else{
                line = self.commonCount/4+1;
            }
            CGFloat yoffset = 40 + 15 + CGRectGetHeight(self.fakeViewFrame)*(line-1) + 15*(line-1);
            if (CGRectGetMidY(_cellFakeView.frame) >= yoffset) { //如果刚好拖动到最后一排cell的y轴位置
                if ((yoffset - self.fakeViewOldyoffset) > _panTranslation.y) { //当到达最后一个cell后在往上拖动时
                    _cellFakeView.center = CGPointMake(_cellFakeViewCenter.x + _panTranslation.x, _cellFakeViewCenter.y + _panTranslation.y);
                }else{ //不让其越过最后一排cell的y轴位置
                    _cellFakeView.frame = CGRectMake(_fakeViewOldxoffset + _panTranslation.x, yoffset, CGRectGetWidth(self.fakeViewFrame), CGRectGetHeight(self.fakeViewFrame));
                    [self moveItemIfNeeded];
                    [self stopScroll];
                    return;
                }
            }else{ //还没有拖动到最后一排cell位置时
                _cellFakeView.center = CGPointMake(_cellFakeViewCenter.x + _panTranslation.x, _cellFakeViewCenter.y + _panTranslation.y);
            }
            //移动的布局
            [self moveItemIfNeeded];
            //自动滚动collectionview
            if (CGRectGetMaxY(_cellFakeView.frame) >= self.collectionView.contentOffset.y + self.collectionView.bounds.size.height) {
                if (ceilf(self.collectionView.contentOffset.y) < self.collectionView.contentSize.height - self.collectionView.bounds.size.height) {
                    self.dragScrollDirection = DragScrollDirctionDown;
                    [self setUpDisplayLink]; //往下滚动
                }
            }else if (CGRectGetMinY(_cellFakeView.frame) <= self.collectionView.contentOffset.y) {
                if (self.collectionView.contentOffset.y > -self.collectionView.contentInset.top) {
                    self.dragScrollDirection = DragScrollDirctionUp;
                    [self setUpDisplayLink]; //往上滚动
                }
            }else {
                self.dragScrollDirection = DragScrollDirctionNone;
                [self stopScroll];
            }
            break;
        }
        case UIGestureRecognizerStateCancelled: {
            NSLog(@"cancle");
        }
        case UIGestureRecognizerStateEnded:
            [self stopScroll];
            break;
            
        default:
            break;
    }
}

- (void)moveItemIfNeeded
{
    NSIndexPath *atIndexPath = _reorderingCellIndexPath;
    NSIndexPath *toIndexPath = [self.collectionView indexPathForItemAtPoint:_cellFakeView.center];
    //拖动时让cell透明度改为0.3
    UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:atIndexPath];
    cell.alpha = 0.3;
    
    if (toIndexPath == nil || [atIndexPath isEqual:toIndexPath]) {
        return;
    }
    
    //移动
    [self.collectionView performBatchUpdates:^{
        _reorderingCellIndexPath = toIndexPath;
        [self.collectionView moveItemAtIndexPath:atIndexPath toIndexPath:toIndexPath]; //移动到指定项
        //移动后需要更新外部数组
        if ([self.datasource respondsToSelector:@selector(currentIndexPath:movedToIndexPath:)]) {
            [self.datasource currentIndexPath:atIndexPath movedToIndexPath:toIndexPath];
        }
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([_panGesture isEqual:gestureRecognizer]) {
        if (_longPressGesture.state == 0 || _longPressGesture.state == 5) {
            return NO;
        }
    }else if ([_longPressGesture isEqual:gestureRecognizer]) {
        if (self.collectionView.panGestureRecognizer.state != 0 && self.collectionView.panGestureRecognizer.state != 5) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([_panGesture isEqual:gestureRecognizer]) {
        if (_longPressGesture.state != 0 && _longPressGesture.state != 5) {
            if ([_longPressGesture isEqual:otherGestureRecognizer]) {
                return YES;
            }
            return NO;
        }
    }else if ([_longPressGesture isEqual:gestureRecognizer]) {
        if ([_panGesture isEqual:otherGestureRecognizer]) {
            return YES;
        }
    }else if ([self.collectionView.panGestureRecognizer isEqual:gestureRecognizer]) {
        if (_longPressGesture.state == 0 || _longPressGesture.state == 5) {
            return NO;
        }
    }
    return YES;
}

@end
