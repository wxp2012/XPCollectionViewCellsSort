//
//  ViewController.m
//  XPCollectionViewCellsSort
//
//  Created by Carlw on 2017/2/13.
//  Copyright © 2017年 wxp2012. All rights reserved.
//

#import "MainViewController.h"
#import "GameClassifyModel.h"
#import "SortCollectionViewCell.h"
#import "SortCollectionReusableView.h"
#import "SortBasicCollectionCellLayout.h"
#import "UIColor+Additions.h"

static NSString * const kSortCollectionCell   = @"kSortCollectionCell";
static NSString * const kSortHeadReusableView = @"kSortHeadReusableView";

@interface MainViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,SortBasicCollectionCellLayoutDelegate>
@property (nonatomic, strong) UIButton *manageButton;
@property (nonatomic, assign) BOOL isSelectManageButton;
@property (nonatomic, strong) UICollectionView *sortCollectionView;
@property (nonatomic, strong) SortBasicCollectionCellLayout *collectionViewLayout;
@property (nonatomic, strong) NSMutableArray *commonArray;
@property (nonatomic, strong) NSMutableArray *moreArray;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *imageArray = @[@"http://pic.58pic.com/58pic/15/67/84/05f58PICUAF_1024.jpg",
                            @"http://upload.cbg.cn/2017/0126/1485413365497.jpg",
                            @"http://ossweb-img.qq.com/images/lol/wallpapers/wallpaper_1680x1050_55.jpg",
                            @"http://images.yeyou.com/2014/news/2014/06/09/x0609er01s.jpg",
                            @"http://hc16.aipai.com/user/752/5829752/4242169/card/15714797/15714797_400.jpg",
                            @"http://upload.gezila.com/data/20160729/12031469759090.jpg",
                            @"http://pc.duowan.com/uploads/allimg/2010-05/06133315-6-363Y.jpg",
                            @"http://f.hiphotos.baidu.com/zhidao/pic/item/b8389b504fc2d5629808817ae21190ef76c66c20.jpg",
                            @"http://img.lenovomm.com/s3/img/icon/app/app-img-lestore/6939-2016-03-17025807-1458197887562.png",
                            @"http://www.fenglingou.com/images/201603/source_img/2077_G_1458278745587.jpg",
                            @"http://img3.duitang.com/uploads/item/201605/17/20160517220750_PMKCJ.thumb.700_0.jpeg",
                            @"http://i2.17173cdn.com/2fhnvk/YWxqaGBf/cms3/NbQOHqbliDiqhod.jpg",
                            @"http://pic1.win4000.com/wallpaper/5/51749b73b0d69.jpg",
                            @"http://i1.hdslb.com/bfs/archive/5dca8968107c8e72ec6dfb5fd315212de68549cc.jpg",
                            @"http://cdn103.img.lizhi.fm/audio_cover/2016/11/17/2568701012160726023_320x320.jpg",
                            @"http://n1.itc.cn/img8/wb/recom/2016/08/05/147038644273687650.png",
                            @"http://wy.77l.com/d/file/2016-08/05/4700914afd35eec0723366b954228ff01918.jpg",
                            @"http://i0.hdslb.com/bfs/archive/e49f20093a3a2f182059c71dda64d37d55e4c0e4.jpg",
                            @"http://pic.coolchuan.com/anzhuoyuan/download/coolchuan/1bffe6120647414ea56b0d8cab794fca.png",
                            @"http://img.25pp.com/uploadfile/app/icon/20160606/1465151194807274.jpg",
                            @"http://pic.58pic.com/58pic/13/19/26/65658PICIbd_1024.jpg",
                            @"http://www.cnidea.net/toutiao/u/20160926/162691031329654701093.jpg",
                            @"http://pic66.nipic.com/file/20150511/6993258_171300425246_2.jpg",
                            @"http://img1.mydrivers.com/img/20150409/1997187aa8d446d28ff51f3150fc5a4a.jpg",
                            @"http://www.anwan.com/uploadfile/2016/0114/20160114013626455.jpg",
                            @"http://images.17173.com/2014/news/2014/08/12/mj0812af02s.jpg",
                            @"http://att.gamefy.cn/201212/135476138586357.jpg",
                            @"http://p2.qhimg.com/t01418e2610d0e6f89b.jpg",
                            @"http://i0.hdslb.com/video/96/96b3a009133ffb53abb7d1712ad14ca1.jpg"];
    
    NSArray *titleArray = @[@"穿越火线",@"我的世界",@"英雄联盟",@"生死狙击",@"主播联萌",@"王者荣耀",@"单机游戏",@"DNF",@"球球大作战",@"逆战",@"守望先锋",@"阴阳师",@"QQ飞车",@"MCPE",@"火影忍者",@"捕鱼来了",@"少女咖啡枪",@"崩坏3",@"怪兽大作战",@"蛇蛇大作战",@"手绘",@"水果隐者",@"愤怒的小鸟",@"GAT5",@"大话西游",@"征途2",@"Dota2",@"炉石传说",@"CS:GO"];
    
    for (int i = 0; i < titleArray.count; i++) {
        GameClassifyModel *model = [GameClassifyModel new];
        model.gameName = [titleArray objectAtIndex:i];
        model.gameIcon = [imageArray objectAtIndex:i];
        [self.commonArray addObject:model];
    }
    
    [self setUpTheViewFrame];
}

#pragma mark - setter/getter methods
- (UIButton *)manageButton {
    if (_manageButton == nil) {
        _manageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_manageButton setExclusiveTouch:YES];
        [_manageButton setFrame:CGRectMake(0, 0, 40, 44)];
        [_manageButton addTarget:self action:@selector(manageButtonEvent) forControlEvents:UIControlEventTouchUpInside];
        [_manageButton setTitle:@"管理" forState:UIControlStateNormal];
        [_manageButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_manageButton setTitleColor:[UIColor colorFromHexValue:0xfea700] forState:UIControlStateHighlighted];
        _manageButton.titleLabel.font = [UIFont systemFontOfSize:16.];
    }
    return _manageButton;
}

- (SortBasicCollectionCellLayout *)collectionViewLayout
{
    if (_collectionViewLayout == nil) {
        _collectionViewLayout = [[SortBasicCollectionCellLayout alloc] init];
        _collectionViewLayout.minimumLineSpacing = 15;
        _collectionViewLayout.minimumInteritemSpacing = 20;
        _collectionViewLayout.sectionInset = UIEdgeInsetsMake(15, 15, 15, 15);
        _collectionViewLayout.datasource = self;
    }
    return _collectionViewLayout;
}

- (NSMutableArray *)commonArray {
    if (_commonArray == nil) {
        _commonArray = [NSMutableArray array];
    }
    return _commonArray;
}

- (NSMutableArray *)moreArray {
    if (_moreArray == nil) {
        _moreArray = [NSMutableArray array];
    }
    return _moreArray;
}

#pragma mark - Private methods
- (void)manageButtonEvent {
    if (!self.commonArray.count && !self.moreArray.count) { //如果没有内容为不可编辑
        return;
    }
    if (!self.isSelectManageButton) {
        [_manageButton setTitle:@"完成" forState:UIControlStateNormal];
        self.isSelectManageButton = YES;
        self.collectionViewLayout.commonCount = self.commonArray.count;
    }else{
        [_manageButton setTitle:@"管理" forState:UIControlStateNormal];
        self.isSelectManageButton = NO;
    }
    [self.sortCollectionView reloadData];
}

- (void)setUpTheViewFrame {
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"游戏";
    //导航栏右边按钮
    UIBarButtonItem *rightBarButtonitem = [[UIBarButtonItem alloc] initWithCustomView:self.manageButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    negativeSpacer.width = -8;
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,rightBarButtonitem];
    
    //集合视图
    self.sortCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.collectionViewLayout];
    self.sortCollectionView.backgroundColor = [UIColor whiteColor];
    self.sortCollectionView.dataSource = self;
    self.sortCollectionView.delegate = self;
    [self.sortCollectionView registerClass:[SortCollectionViewCell class] forCellWithReuseIdentifier:kSortCollectionCell];
    [self.sortCollectionView registerClass:[SortCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kSortHeadReusableView];
    self.sortCollectionView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds));
    self.collectionViewLayout.itemSize = CGSizeMake((CGRectGetWidth(self.view.bounds) - 90)/4, (CGRectGetWidth(self.view.bounds) - 90)/4 + 22);
    [self.view addSubview:self.sortCollectionView];
    
}

#pragma mark - UICollectionViewDelegate methods
- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        return self.commonArray.count;
    }else{
        return self.moreArray.count + 1 ; //1用于显示更多按钮
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SortCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kSortCollectionCell forIndexPath:indexPath];
    if (indexPath.section == 0) {
        [cell setTheCellRightTopImageContent:self.isSelectManageButton ? TopRightImageDelete_Type : TopRightImageHide_Type];
        [cell setTheCellContent:self.commonArray[indexPath.item]];
    }else if (indexPath.section == 1 ) {
        [cell setTheCellRightTopImageContent:self.isSelectManageButton ? TopRightImageAdd_Type : TopRightImageHide_Type];
        if (indexPath.item < self.moreArray.count) {
            [cell setTheCellContent:self.moreArray[indexPath.item]];
        }else{
            [cell setTheCellContent:nil];
        }
    }
    return cell;
}
//头视图大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return CGSizeMake(CGRectGetWidth(self.view.bounds), 40);
            break;
        case 1:
            return CGSizeMake(CGRectGetWidth(self.view.bounds), 50);
            break;
        default:
            return CGSizeMake(CGRectGetWidth(self.view.bounds),0.000001);
            break;
    }
    
}
//头视图
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    SortCollectionReusableView *headerView = (SortCollectionReusableView *)[collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kSortHeadReusableView forIndexPath:indexPath];
    headerView.isSelectManageButton = self.isSelectManageButton;
    headerView.sectionIndex = indexPath.section;
    return headerView;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.item == self.moreArray.count) { //选取了更多按钮
        NSLog(@"selected more button");
        return;
    }
    if (!self.isSelectManageButton) {
        SortCollectionViewCell *cell = (SortCollectionViewCell *)[self.sortCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.item inSection:indexPath.section]];
        NSLog(@"selected %@",cell.gameModel.gameName);
        return;
    }
    id removeItem;
    if (indexPath.section == 0) {
        removeItem = self.commonArray[indexPath.item];
        [self.commonArray removeObjectAtIndex:indexPath.item];
    }
    if (indexPath.section == 1) {
        removeItem = self.moreArray[indexPath.item];
        [self.moreArray removeObjectAtIndex:indexPath.item];
    }
    SortCollectionViewCell *cell = (SortCollectionViewCell *)[self.sortCollectionView cellForItemAtIndexPath:indexPath];
    if (indexPath.section == 0) {
        [self.moreArray insertObject:removeItem atIndex:0];
        [self.sortCollectionView moveItemAtIndexPath:indexPath toIndexPath:[NSIndexPath indexPathForItem:0 inSection:1]];
        [cell setTheCellRightTopImageContent:TopRightImageAdd_Type]; //需要更新cell右上角的图片状态为添加
    }
    if (indexPath.section == 1) {
        [self.commonArray insertObject:removeItem atIndex:0];
        [self.sortCollectionView moveItemAtIndexPath:indexPath toIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        [cell setTheCellRightTopImageContent:TopRightImageDelete_Type]; //需要更新cell右上角的图片状态为删除
    }
    self.collectionViewLayout.commonCount = self.commonArray.count;
    [self.sortCollectionView reloadData];
}

#pragma APHomePageSortBasicLayoutDataSource methods
- (BOOL)canMoveSortCollectionViewItemAtIndex {
    return self.isSelectManageButton;
}

- (void)moveSortCollectionViewItemDone {
    [self.sortCollectionView reloadData];
}

- (void)currentIndexPath:(NSIndexPath *)fromeIndexPath movedToIndexPath:(NSIndexPath *)toIndexPath {
    GameClassifyModel *tempModel = [self.commonArray objectAtIndex:fromeIndexPath.item];
    [self.commonArray removeObjectAtIndex:fromeIndexPath.item];
    [self.commonArray insertObject:tempModel atIndex:toIndexPath.item];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
