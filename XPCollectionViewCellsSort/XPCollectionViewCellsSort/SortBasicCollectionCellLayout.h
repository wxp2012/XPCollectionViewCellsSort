//
//  SortBasicCollectionCellLayout.h
//  XPCollectionViewCellsSort
//
//  Created by Carlw on 2017/2/16.
//  Copyright © 2017年 wxp2012. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SortBasicCollectionCellLayoutDelegate <NSObject>
    
- (BOOL)canMoveSortCollectionViewItemAtIndex;
- (void)moveSortCollectionViewItemDone;
- (void)currentIndexPath:(NSIndexPath *)fromeIndexPath movedToIndexPath:(NSIndexPath *)toIndexPath;

@end

@interface SortBasicCollectionCellLayout : UICollectionViewFlowLayout

@property (nonatomic, weak) id<SortBasicCollectionCellLayoutDelegate> datasource;
@property (nonatomic, assign) NSInteger commonCount; //常用的游戏数量

@end
