//
//  SortCollectionViewCell.h
//  XPCollectionViewCellsSort
//
//  Created by Carlw on 2017/2/16.
//  Copyright © 2017年 wxp2012. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameClassifyModel.h"

typedef enum : NSUInteger {
    TopRightImageDelete_Type,
    TopRightImageAdd_Type,
    TopRightImageHide_Type
} TopRightImageShowType;

@interface SortCollectionViewCell : UICollectionViewCell
    
@property (nonatomic, strong) UIButton *imageButton;
@property (nonatomic, strong) UIButton *titleButton;
@property (nonatomic, strong) GameClassifyModel *gameModel;

- (void)setTheCellContent:(GameClassifyModel *)model;
- (void)setTheCellRightTopImageContent:(TopRightImageShowType)type;
    
    
@end
