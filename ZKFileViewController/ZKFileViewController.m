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
#define DOCUMENT_PATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]

@interface ZKFileViewController ()<UIAlertViewDelegate>
{
    NSFileManager *_fileManager;
    UITableView *_fileTable;
    NSArray *_paths;
    
    NSString *_currentPath;
    NSString *_parentPath;
    
    BOOL _isRoot;
    BOOL _deleteIndex;
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
        _rootDirectory = DOCUMENT_PATH;
    }
    return _rootDirectory;
}

- (void)viewDidLoad {
    [super viewDidLoad];
   _currentPath = self.rootDirectory;
    self.title = [_currentPath lastPathComponent];
    
    
    _fileManager = [NSFileManager defaultManager];
    
    _fileTable = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _fileTable.delegate = self;
    _fileTable.dataSource = self;
    [_fileTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:_fileTable];
    
    
    if ([ _fileTable respondsToSelector:@selector(setSeparatorInset:)]) {
        [ _fileTable setSeparatorInset:UIEdgeInsetsZero];
        
    }
    if ([ _fileTable respondsToSelector:@selector(setLayoutMargins:)])  {
        [ _fileTable setLayoutMargins:UIEdgeInsetsZero];
    }
    
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
    

    
    for (NSString *path in _paths) {
        BOOL isDectory;
        BOOL flag = [_fileManager fileExistsAtPath:[_currentPath stringByAppendingPathComponent:path] isDirectory:&isDectory];
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
    
    NSString *pathComponent= [path lastPathComponent];
    
    if (flag) {
        if (isDirectory) {
            
             image = [UIImage imageNamed:@"directory.png"];
        }else{
            
            if ([directoryPath hasSuffix:@".png"]) {
                image = [UIImage imageNamed:@"image.png"];
            }else if ([directoryPath hasSuffix:@".mov"]||[path hasSuffix:@".mp4"]){
                image = [UIImage imageNamed:@"video.png"];
            }else{
                image = [UIImage imageNamed:@"file.png"];
            }
        }
        CGFloat fileSize = [self folderSizeAtPath:[_currentPath stringByAppendingPathComponent:pathComponent]];
        if (fileSize > 0 && self.showFileSize) {
            pathComponent = [NSString stringWithFormat:@"%@ ( %.2fm )",pathComponent,fileSize];
        }
        
    }else{
        image = [UIImage imageNamed:@"directory.png"];
    }
    cell.imageView.image = image;
    
    cell.textLabel.text = pathComponent;


    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *path = _paths[indexPath.row];
    
    if (!_isRoot && indexPath.row == 0) {
        _currentPath = _parentPath;
        [self loadPath];
    }
    else{
        
        BOOL isDiretory;
        BOOL flag = [_fileManager fileExistsAtPath:[_currentPath stringByAppendingPathComponent:path] isDirectory:&isDiretory];
        if (flag && isDiretory) {
            _currentPath = [_currentPath stringByAppendingPathComponent:path];
            [self loadPath];
            
        }else if(flag){
            
        }

    }
    
    self.title = [_currentPath lastPathComponent];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *path = [_currentPath stringByAppendingPathComponent:_paths[indexPath.row]];
        NSLog(@"%@",path);
#ifdef __IPHONE_8_0
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"刪除" message:@"刪除后無法恢復，是否刪除?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cacelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *submitAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSError *error;
           
            [_fileManager removeItemAtPath:path error:&error];
            [self loadPath];
        }];
        [alertC addAction:cacelAction];
        [alertC addAction:submitAction];
        [self presentViewController:alertC animated:YES completion:nil];
#else
        _deleteIndex = indexPath.row;
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"刪除" message:@"刪除后無法恢復，是否刪除?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"確定", nil];
        [alertView show];
#endif
        
        
    }

}

- (long long) fileSizeAtPath:(NSString*) filePath{
    
    NSFileManager* manager = [NSFileManager defaultManager];
    
    if ([manager fileExistsAtPath:filePath]){
        
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

- (float ) folderSizeAtPath:(NSString*) folderPath{
    
    NSFileManager* manager = [NSFileManager defaultManager];
    
    if (![manager fileExistsAtPath:folderPath]) return 0;
    
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    
    NSString* fileName;
    
    long long folderSize = 0;
    
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        BOOL isDir;
        if ([_fileManager fileExistsAtPath:fileAbsolutePath isDirectory:&isDir]) {
            if (isDir) {
                folderSize += [self folderSizeAtPath:fileAbsolutePath];
            }else{
                folderSize += [self fileSizeAtPath:fileAbsolutePath];
            }
        }
    }
    
    return folderSize/(1024.0*1024.0);
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *path = [_currentPath stringByAppendingPathComponent:_paths[_deleteIndex]];
    [_fileManager removeItemAtPath:path error:nil];
    [self loadPath];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
