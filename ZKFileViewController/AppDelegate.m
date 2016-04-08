//
//  AppDelegate.m
//  ZKFileViewController
//
//  Created by lee on 16/3/31.
//  Copyright (c) 2016年 sanchun. All rights reserved.
//

#import "AppDelegate.h"
#import "ZKFileViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self createDirectory];
    
    ZKFileViewController *fileVC = [[ZKFileViewController alloc]init];
    fileVC.showFileSize = YES;
    UINavigationController *naviga = [[UINavigationController alloc]initWithRootViewController:fileVC];
    self.window.rootViewController = naviga;
    return YES;
}

-(void)createDirectory{
    NSFileManager *fileManger = [NSFileManager defaultManager];
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSArray *paths = @[@"one",@"one/1",@"two/2",@"one/1/1111",@"ffff",@"teo",@"in",@"in/inin",@"in/in2/in3"];
    
    for (NSString *path in paths) {
        NSString *directoryPath = [documentPath stringByAppendingPathComponent:path];
        [fileManger createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSData *data = [NSData data];
    
    NSString *path = documentPath;
    [fileManger createFileAtPath:[path stringByAppendingPathComponent:@"rere.png"] contents:data attributes:nil];
    [fileManger createFileAtPath:[path stringByAppendingPathComponent:@"ffdsf.mov"] contents:data attributes:nil];
    [fileManger createFileAtPath:[path stringByAppendingPathComponent:@"fgfgs.png"] contents:data attributes:nil];
    [fileManger createFileAtPath:[path stringByAppendingPathComponent:@"fdfd.aud"] contents:data attributes:nil];

    path = [documentPath stringByAppendingPathComponent:paths[0]];
    [fileManger createFileAtPath:[path stringByAppendingPathComponent:@"rere.png"] contents:data attributes:nil];
    [fileManger createFileAtPath:[path stringByAppendingPathComponent:@"ffdsf.mov"] contents:data attributes:nil];
    [fileManger createFileAtPath:[path stringByAppendingPathComponent:@"fgfgs.png"] contents:data attributes:nil];
    [fileManger createFileAtPath:[path stringByAppendingPathComponent:@"fdfd.aud"] contents:data attributes:nil];
    
    path = [documentPath stringByAppendingPathComponent:paths[1]];
    [fileManger createFileAtPath:[path stringByAppendingPathComponent:@"44e.png"] contents:data attributes:nil];
    [fileManger createFileAtPath:[path stringByAppendingPathComponent:@"5f.m5ov"] contents:data attributes:nil];
    [fileManger createFileAtPath:[path stringByAppendingPathComponent:@"f55fgs.png"] contents:data attributes:nil];
    [fileManger createFileAtPath:[path stringByAppendingPathComponent:@"fdfd.aud"] contents:data attributes:nil];
    
    path = [documentPath stringByAppendingPathComponent:paths[3]];
    [fileManger createFileAtPath:[path stringByAppendingPathComponent:@"44e.mov"] contents:data attributes:nil];
    [fileManger createFileAtPath:[path stringByAppendingPathComponent:@"5f.mov"] contents:data attributes:nil];
    [fileManger createFileAtPath:[path stringByAppendingPathComponent:@"gs.png"] contents:data attributes:nil];
    [fileManger createFileAtPath:[path stringByAppendingPathComponent:@"fdfd.aud"] contents:data attributes:nil];

    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
