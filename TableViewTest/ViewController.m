//
//  ViewController.m
//  TableViewTest
//
//  Created by 张猛 on 16/3/26.
//  Copyright © 2016年 ZongSuo. All rights reserved.
//

#import "ViewController.h"
#import "NSString+PPExtension.h"
#import "SearchDetailController.h"
#define kScreenSize [UIScreen mainScreen].bounds.size.width
@interface ViewController ()<UITableViewDataSource , UITableViewDelegate,UITextFieldDelegate,UISearchBarDelegate,UISearchControllerDelegate,UISearchResultsUpdating>

@property(nonatomic,strong)UITableView *hisTableView;
@property(nonatomic,strong)NSMutableArray *historySearchArray;
@property(nonatomic,copy)NSString *filePath;
//searchController
@property (strong, nonatomic)  UISearchController *searchController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"搜索测试";
    [self setSearchBar];
    [self setupTableView];
    
   // [self setSearchVC];
    //创建缓存列表
    [self createDataSource];
   

}
- (void)setSearchBar
{
    UISearchBar *searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 20, kScreenSize, 44)];
    searchBar.showsCancelButton = YES;
    searchBar.placeholder = @"请输入搜索内容";
    searchBar.delegate = self;
    self.navigationItem.titleView = searchBar;
}

- (void)setupTableView
{
   // self.searchController.active
   
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0, kScreenSize, 667-64)];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.hisTableView = tableView;
    self.hisTableView.tableFooterView = [self tableViewFooterView];
    
    
 }
- (void)createDataSource
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //历史搜索文件夹路径
    NSString *tempStr = [@"/SearchHistoryList" cacheDir];
    NSLog(@"tempStr = %@",tempStr);
    //文件路径
    NSString *filePath = [tempStr stringByAppendingString:@"/SearchHistory.plist"];
    self.filePath = filePath;
    BOOL isExists = [fileManager fileExistsAtPath:filePath];
    if (!isExists)
    {
        //不存在,创建文件夹
        [fileManager createDirectoryAtPath:tempStr withIntermediateDirectories:YES attributes:nil error:nil];
        
    }
    else
    {
        //直接使用(根据路径初始化数组)
        _historySearchArray = [[NSMutableArray alloc]initWithContentsOfFile:filePath];
    }
    //判断tableView是否隐藏
    [self isHidenTableView];
}
- (void)isHidenTableView
{
    if (_historySearchArray.count) {
        _hisTableView.hidden = NO;
    }
    else
    {
        _hisTableView.hidden = YES;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.historySearchArray.count;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellID = @"cellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.textLabel.text = self.historySearchArray[indexPath.row];
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

#pragma mark - UISerachBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar endEditing:YES];
    if ([self.historySearchArray containsObject:searchBar.text]) {
        //将该元素移除
        [self.historySearchArray removeObject:searchBar.text];
    }
    //历史搜索的列表中插入元素
    [_historySearchArray insertObject:searchBar.text atIndex:0];
    //将该数组缓存的本地
    [_historySearchArray writeToFile:self.filePath atomically:YES];
    [self isHidenTableView];
    [self.hisTableView reloadData];

    SearchDetailController *detail = [[SearchDetailController alloc]init];
    detail.title = searchBar.text;
    [self.navigationController pushViewController:detail animated:YES];
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
   // NSLog(@"%@",searchText);
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
    [searchBar endEditing:YES];

}


- (NSMutableArray *)historySearchArray
{
    if (!_historySearchArray) {
        _historySearchArray = [NSMutableArray array];
    }
    return _historySearchArray;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}


- (UIView *)tableViewFooterView
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(self.view.frame.size.width/2-50, 7, 100, 30);
    [button setTitle:@"清除历史" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
    
    button.layer.borderColor = [UIColor orangeColor].CGColor;
    button.layer.borderWidth = 1.0f;
    [view addSubview:button];
  
    return view;
}

- (void)buttonAction
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:self.filePath error:nil];
    [self.historySearchArray removeAllObjects];
    [self isHidenTableView];
    [self.hisTableView reloadData];

}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 通过UISearchController也能设置
- (void)setSearchVC
{
    //创建UISearchController
    _searchController = [[UISearchController alloc]initWithSearchResultsController:nil];
    //设置代理
    _searchController.delegate = self;
    _searchController.searchResultsUpdater= self;
    _searchController.searchBar.delegate = self;
    
    //设置UISearchController的显示属性，以下3个属性默认为YES
    //搜索时，背景变暗色
    _searchController.dimsBackgroundDuringPresentation = YES;
    //搜索时，背景变模糊
    _searchController.obscuresBackgroundDuringPresentation = YES;
    //隐藏导航栏
    _searchController.hidesNavigationBarDuringPresentation = YES;
    
    _searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x, self.searchController.searchBar.frame.origin.y, self.searchController.searchBar.frame.size.width, 44.0);
    
    // 添加 searchbar 到 headerview
    self.hisTableView.tableHeaderView = _searchController.searchBar;
}

#pragma mark - UISearchControllerDelegate代理

//测试UISearchController的执行过程

//- (void)willPresentSearchController:(UISearchController *)searchController
//{
//    NSLog(@"willPresentSearchController");
//}
//
//- (void)didPresentSearchController:(UISearchController *)searchController
//{
//    NSLog(@"didPresentSearchController");
//}
//
//- (void)willDismissSearchController:(UISearchController *)searchController
//{
//    NSLog(@"willDismissSearchController");
//}
//
//- (void)didDismissSearchController:(UISearchController *)searchController
//{
//    NSLog(@"didDismissSearchController");
//}

//- (void)presentSearchController:(UISearchController *)searchController
//{
//    NSLog(@"presentSearchController");
//}



#pragma mark - UISearchResultsUpdating代理
//@required

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    NSLog(@"updateSearchResultsForSearchController");
    //    NSString *searchString = [self.searchController.searchBar text];
    //    NSPredicate *preicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS[c] %@", searchString];
    //    if (self.searchList!= nil) {
    //        [self.searchList removeAllObjects];
    //    }
    //    //过滤数据
    //    self.searchList= [NSMutableArray arrayWithArray:[_dataList filteredArrayUsingPredicate:preicate]];
    //    //刷新表格
    //    [self.tableView reloadData];
}



@end
