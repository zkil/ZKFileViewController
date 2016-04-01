//
//  ZKFileViewController.m
//  ZKFileViewController
//
//  Created by lee on 16/3/31.
//  Copyright (c) 2016年 sanchun. All rights reserved.
//

#import "ZKFileViewController.h"

#define SCREEN_FRAME [UIScreen mainScreen].bounds
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface ZKFileViewController ()
{
    NSFileManager *_fileManager;
    UITableView *_fileTable;
    NSArray *_paths;
    
    NSString *_currentPath;
    NSString *_parentPath;
    
        BOOL _isRoot;
}
@end

@implementation ZKFileViewController

-(id)initWithRootDirectory:(NSString *)rootDirectory{
    if (self = [super init]) {
        _rootDirectory = rootDirectory;
    }
    return self;
}

-(NSString *)rootDirectory{
    if (_rootDirectory == nil) {
        _rootDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject];
    }
    return _rootDirectory;
}

- (void)viewDidLoad {
    [super viewDidLoad];
   _currentPath = self.rootDirectory;
    
    
    _fileManager = [NSFileManager defaultManager];
    
    _fileTable = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _fileTable.delegate = self;
    _fileTable.dataSource = self;
    [_fileTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:_fileTable];
    
    [self loadPath];
    
}

-(void)loadPath{

    
    _parentPath = [_currentPath stringByDeletingLastPathComponent];
    
    _paths = [_fileManager contentsOfDirectoryAtPath:_currentPath error:nil];
    
    [self sortPath];
    
    if ([_currentPath isEqualToString:self.rootDirectory]) {
        _isRoot = YES;
    }else{
        _isRoot = NO;
        _paths = [@[@"..."] arrayByAddingObjectsFromArray:_paths];
    }
    
    [_fileTable reloadData];
    
    
}

-(void)sortPath{
    NSMutableArray *filePaths = [NSMutableArray new];
    NSMutableArray *directoryPaths = [NSMutableArray new];
    
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    for (NSString *path in _paths) {
        BOOL isDectory;
        BOOL flag = [_fileManager fileExistsAtPath:[_currentPath stringByAppendingPathComponent:path] isDirectory:&isDectory];
        NSLog(@"%@ %d %d",[documentPath stringByAppendingPathComponent:path],isDectory,flag);
        if (flag && isDectory) {
            [directoryPaths addObject:path];
        }else if (flag && !isDectory){
            [filePaths addObject:path];
        }
    }
    [filePaths sortUsingSelector:@selector(compare:)];
    [directoryPaths sortUsingSelector:@selector(compare:)];
    _paths = [directoryPaths arrayByAddingObjectsFromArray:filePaths];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _paths.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    NSString *path = _paths[indexPath.row];
    
    NSString *directoryPath = [_currentPath stringByAppendingPathComponent:path];
    UIImage *image;
    BOOL isDirectory;
    BOOL flag = [_fileManager fileExistsAtPath:directoryPath isDirectory:&isDirectory];
    if (flag && isDirectory) {
        image = [UIImage imageNamed:@"directory.png"];
    }else if(flag && !isDirectory){
        if ([directoryPath hasSuffix:@".png"]) {
            image = [UIImage imageNamed:@"image.png"];
        }else if ([directoryPath hasSuffix:@".mov"]||[path hasSuffix:@".mp4"]){
            image = [UIImage imageNamed:@"video.png"];
        }else{
            image = [UIImage imageNamed:@"file.png"];
        }
    }else if(!flag){
        image = [UIImage imageNamed:@"directory.png"];
    }
    cell.imageView.image = image;
    NSString *pathComponent= [path lastPathComponent];
    cell.textLabel.text = pathComponent;

    

    
    
    

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (!_isRoot && indexPath.row == 0) {
        _currentPath = _parentPath;
        [self loadPath];
    }
    else{
        NSString *path = _paths[indexPath.row];
        BOOL isDiretory;
        BOOL flag = [_fileManager fileExistsAtPath:[_currentPath stringByAppendingPathComponent:path] isDirectory:&isDiretory];
        if (flag && isDiretory) {
            _currentPath = [_currentPath stringByAppendingPathComponent:path];
            [self loadPath];
            
        }else if(flag){
            
        }

    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
