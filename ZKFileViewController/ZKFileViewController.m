//
//  ZKFileViewController.m
//  ZKFileViewController
//
//  Created by lee on 16/3/31.
//  Copyright (c) 2016年 sanchun. All rights reserved.
//

#import "ZKFileViewController.h"
#import <Masonry/Masonry.h>
#import <MobileCoreServices/MobileCoreServices.h>


#define SCREEN_FRAME [UIScreen mainScreen].bounds
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define DOCUMENT_PATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]

@interface ZKFileViewController ()<UIAlertViewDelegate>
{
    
    
    

    
    BOOL _deleteIndex;
}

@property (nonatomic,strong) UITableView *tableView;

//当前路径
@property (nonatomic,strong) NSString *currentPath;
//当前目录下路径
@property (nonatomic,strong) NSArray *paths;

@property (nonatomic,strong) NSFileManager *fileManager;

@end

@implementation ZKFileViewController

- (instancetype)initWithRootDirectory:(NSString *)rootDirectory{
    if (self = [super init]) {
        _rootDirectory = rootDirectory;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.fileManager = [NSFileManager defaultManager];
    [self initUI];
    [self loadPath];
    
}

#pragma -mark- 
- (void) initUI {
    self.currentPath = self.rootDirectory;
    
    self.title = [self.currentPath lastPathComponent];
    
    self.tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

//获取路径
-(void)loadPath{
    //获取当前目录所有路径（包括文件）
    self.paths = [self.fileManager contentsOfDirectoryAtPath:self.currentPath error:nil];
    
    //排序
    [self sortPath];
    
    if (![self.currentPath isEqualToString:self.rootDirectory]) {
        //不是根路径添加返回项
        self.paths = [@[@"..."] arrayByAddingObjectsFromArray:self.paths];
    }
    
    [self.tableView reloadData];
    
    
}

//目录或文件排序 （文件夹在上，文件在下）
-(void)sortPath{
    NSMutableArray *filePaths = [NSMutableArray new];
    NSMutableArray *directoryPaths = [NSMutableArray new];
    
    for (NSString *path in self.paths) {
        BOOL isDectory;
        BOOL flag = [self.fileManager fileExistsAtPath:[_currentPath stringByAppendingPathComponent:path] isDirectory:&isDectory];
        if (flag && isDectory) {
            [directoryPaths addObject:path];
        }else if (flag && !isDectory){
            [filePaths addObject:path];
        }
    }
    
    [filePaths sortUsingSelector:@selector(compare:)];
    [directoryPaths sortUsingSelector:@selector(compare:)];
    self.paths = [directoryPaths arrayByAddingObjectsFromArray:filePaths];
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.paths.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    NSString *path = self.paths[indexPath.row];
    
    UIImage *image;
    
    NSString *directoryPath = [self.currentPath stringByAppendingPathComponent:path];
    
    BOOL isDirectory;
    BOOL flag = [self.fileManager fileExistsAtPath:directoryPath isDirectory:&isDirectory];
    
    NSString *pathComponent= [path lastPathComponent];
    
    if (flag) {  //是否存在
        if (isDirectory) { //是否文件夾
             image = [UIImage imageNamed:@"directory.png"];
        }else{
            
            NSString *MIMEType = [self getMIMETypeWithCAPIAtFilePath:directoryPath];
            
            if ([MIMEType rangeOfString:@"image"].location != NSNotFound) {
                image = [UIImage imageNamed:@"image.png"];
            } else if ([MIMEType rangeOfString:@"video"].location != NSNotFound) {
                image = [UIImage imageNamed:@"video.png"];
            } else {
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

- (NSString *)getMIMETypeWithCAPIAtFilePath:(NSString *)path {
    if (![[[NSFileManager alloc] init] fileExistsAtPath:path]) {
        return nil;
    }
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[path pathExtension], NULL);
    CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    NSString *type = (__bridge_transfer NSString *)(MIMEType);
    //CFRelease(MIMEType);
    if (type == nil) {
        type = @"application/octet-stream";
    }
    return type;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *path = _paths[indexPath.row];
    
    NSString *parentPath = [self.currentPath stringByDeletingLastPathComponent];
    if (indexPath.row == 0 && ![self.currentPath isEqualToString:self.rootDirectory]) {
        self.currentPath = parentPath;
        [self loadPath];
    }
    else{
        
        BOOL isDiretory;
        BOOL flag = [self.fileManager fileExistsAtPath:[self.currentPath stringByAppendingPathComponent:path] isDirectory:&isDiretory];
        if (flag && isDiretory) {
            self.currentPath = [_currentPath stringByAppendingPathComponent:path];
            [self loadPath];
            
        }else if(flag){
            //这里处理点击文件事件
            
            NSString *MIMEType = [self getMIMETypeWithCAPIAtFilePath:[self.currentPath stringByAppendingPathComponent:path]];
            
            if ([MIMEType rangeOfString:@"image"].location != NSNotFound) {
                
            } else if ([MIMEType rangeOfString:@"video"].location != NSNotFound) {
               
            } else {
               
            }
        }

    }
    
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


#pragma -mark- getter
//默认为Document
- (NSString *)rootDirectory {
    if (_rootDirectory == nil) {
        _rootDirectory = DOCUMENT_PATH;
    }
    return _rootDirectory;
}

- (void)setCurrentPath:(NSString *)currentPath {
    _currentPath = currentPath;
    
    self.title = [_currentPath lastPathComponent];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
