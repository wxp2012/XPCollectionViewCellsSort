//
//  SortCollectionViewCell.m
//  XPCollectionViewCellsSort
//
//  Created by Carlw on 2017/2/16.
//  Copyright © 2017年 wxp2012. All rights reserved.
//

#import "SortCollectionViewCell.h"
#import <YYWebImage.h>
#import <Masonry.h>
#import "UIColor+Additions.h"

@interface SortCollectionViewCell ()
@property (nonatomic, strong) UIImageView *topRightImageV;
@end

@implementation SortCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame
    {
        self = [super initWithFrame:frame];
        if (self) {
            self.backgroundColor = [UIColor whiteColor];
            [self setupSubViews];
        }
        return self;
    }
    
- (void)setupSubViews
    {
        [self.contentView addSubview:self.imageButton];
        [self.contentView addSubview:self.titleButton];
        [self.contentView addSubview:self.topRightImageV];
        
        [self.imageButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.left.and.right.equalTo(self);
            make.height.mas_equalTo(CGRectGetWidth(self.bounds));
        }];
        
        [self.titleButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.and.left.and.right.equalTo(self);
            make.top.mas_equalTo(self.imageButton.mas_bottom);
        }];
        
        [self.topRightImageV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top).offset(6.);
            make.right.mas_equalTo(self.mas_right).offset(-6.);
            make.width.and.height.mas_equalTo(15.);
        }];
    }
    
#pragma mark - setter/getter methods
- (UIButton *)imageButton {
    if (_imageButton == nil) {
        _imageButton = [[UIButton alloc] init];
        _imageButton.userInteractionEnabled = NO;
    }
    return _imageButton;
}
    
- (UIButton *)titleButton {
    if (_titleButton == nil) {
        _titleButton = [[UIButton alloc] init];
        [_titleButton setTitleColor:[UIColor colorFromHexValue:0x777777] forState:UIControlStateNormal];
        _titleButton.titleLabel.font = [UIFont systemFontOfSize:13.];
        _titleButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _titleButton;
}
    
- (UIImageView *)topRightImageV {
    if (_topRightImageV == nil) {
        _topRightImageV = [[UIImageView alloc] init];
        _topRightImageV.hidden = YES;
    }
    return _topRightImageV;
}
    
#pragma mark - Public methods
- (void)setTheCellContent:(GameClassifyModel *)model {
    if (!model) {
        _topRightImageV.hidden = YES;
        [self.imageButton  setImage:[UIImage imageNamed:@"sortmore_btn"] forState:UIControlStateNormal];
        [self.titleButton setTitle:@"更多" forState:UIControlStateNormal];
        _imageButton.layer.masksToBounds = NO;
        return;
    }
    self.gameModel = model;
    [self.titleButton setTitle:model.gameName != nil ? model.gameName : @"" forState:UIControlStateNormal];
    [self.imageButton yy_setImageWithURL:[NSURL URLWithString:model.gameIcon] forState:UIControlStateNormal placeholder:nil options:YYWebImageOptionAvoidSetImage completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
        if (image) {
            image = [image yy_imageByResizeToSize:self.bounds.size];
            image = [image yy_imageByRoundCornerRadius:10.];
            [self.imageButton setImage:image forState:UIControlStateNormal];
        }
    }];
}
    
- (void)setTheCellRightTopImageContent:(TopRightImageShowType)type {
    _topRightImageV.hidden = NO;
    if (type == TopRightImageAdd_Type) {
        _topRightImageV.image = [UIImage imageNamed:@"sortimage_add"];
    }else if (type == TopRightImageDelete_Type) {
        _topRightImageV.image = [UIImage imageNamed:@"sortimage_delete"];
    }else if (type == TopRightImageHide_Type) {
        _topRightImageV.hidden = YES;
    }
}

@end
