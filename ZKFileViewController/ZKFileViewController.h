//
//  ZKFileViewController.h
//  ZKFileViewController
//
//  Created by lee on 16/3/31.
//  Copyright (c) 2016年 sanchun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZKFileViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)NSString *rootDirectory;
@property(nonatomic)BOOL showFileSize;

-(id)initWithRootDirectory:(NSString *)rootDirectory;
@end
