//
//  SortCollectionReusableView.m
//  XPCollectionViewCellsSort
//
//  Created by Carlw on 2017/2/16.
//  Copyright © 2017年 wxp2012. All rights reserved.
//

#import "SortCollectionReusableView.h"
#import <Masonry.h>
#import "UIColor+Additions.h"

@interface SortCollectionReusableView ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *titleSubLabel;
@property (nonatomic, strong) UIView *topLineView;
@end

@implementation SortCollectionReusableView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.zPosition = -1; //防止移动动画时被遮盖
        [self setUpTheViewFrame];
    }
    return self;
}
    
#pragma mark - Private methods
- (void)setUpTheViewFrame {
    [self addSubview:self.titleLabel];
    [self addSubview:self.titleSubLabel];
    [self addSubview:self.topLineView];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).offset(15.);
        make.bottom.mas_equalTo(self.mas_bottom);
        make.width.mas_equalTo(40.);
        make.height.mas_equalTo(25.);
    }];
    
    [self.titleSubLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel.mas_right).offset(5.);
        make.bottom.mas_equalTo(self.mas_bottom);
        make.width.mas_equalTo(200.);
        make.height.mas_equalTo(25.);
    }];
    
    [self.topLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.and.right.equalTo(self);
        make.height.mas_equalTo(10.);
    }];
}
    
#pragma mark - setter/getter methods
- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:18.];
        _titleLabel.textColor = [UIColor colorFromHexValue:0x444444];
    }
    return _titleLabel;
}
    
- (UILabel *)titleSubLabel {
    if (_titleSubLabel == nil) {
        _titleSubLabel = [[UILabel alloc] init];
        _titleSubLabel.font = [UIFont systemFontOfSize:13.];
        _titleSubLabel.textColor = [UIColor colorFromHexValue:0x8d8d8d];
    }
    return _titleSubLabel;
}
    
- (UIView *)topLineView {
    if (_topLineView == nil) {
        _topLineView = [[UIView alloc] init];
        _topLineView.backgroundColor = [UIColor colorFromHexValue:0xf5f5f5];
    }
    return _topLineView;
}
    
- (void)setSectionIndex:(NSInteger)sectionIndex {
    if (sectionIndex == 0) {
        _titleLabel.text = @"常用";
        _titleSubLabel.text = self.isSelectManageButton ? @"点击可删除，长按可拖动排序" : @"";
        _topLineView.hidden = YES;
    }
    if (sectionIndex == 1) {
        _titleLabel.text = @"更多";
        _titleSubLabel.text = self.isSelectManageButton ? @"点击可添加到常用" : @"";
        _topLineView.hidden = NO;
    }
}

@end
