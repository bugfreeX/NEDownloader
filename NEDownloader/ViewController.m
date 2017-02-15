//
//  ViewController.m
//  NEDownloader
//
//  Created by Nelson on 2017/2/14.
//  Copyright © 2017年 Nelson. All rights reserved.
//

#import "ViewController.h"
#import "NEDownloader.h"
@interface ViewController (){
    NSString * url;
    NSString * downloadFilePath;
}
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (nonatomic , strong) NEDownloader * downloader;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"NEDownloader";
    url = @"https://mac-installer.github.com/mac/GitHub%20Desktop%20222.zip";
}
- (IBAction)startAction:(id)sender {
    __weak typeof(self) weakSelf = self;
    self.downloader = [[NEDownloader alloc]init];
    [self.downloader startWithURL:url progressHandler:^(long long completedUnitCount, long long totalUnitCount) {
        weakSelf.progressView.progress = 1.0 * completedUnitCount / totalUnitCount;
        weakSelf.progressLabel.text = [NSString stringWithFormat:@"%lld / %lld",completedUnitCount,totalUnitCount];
    } completeBlock:^(NSString *filePath, NSString *url, BOOL completed, NSError * error) {
        if (completed) {
            downloadFilePath = filePath;
            weakSelf.progressView.progress = 1.0;
            [self showAlertWithMessage:@"download completed"];
        }else{
            [self showAlertWithMessage:error.description];
        }
    }];
    
    [self.downloader startWithURL:url progressHandler:^(long long completedUnitCount, long long totalUnitCount) {
        
    } completeBlock:^(NSString *filePath, NSString *url, BOOL completed, NSError *error) {
        
    }];
}

- (IBAction)suspendAction:(id)sender {
    if (self.downloader) {
        [self.downloader suspend];
    }
}

- (IBAction)deleteAction:(id)sender {
    if (downloadFilePath) {
        NSError * error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:downloadFilePath error:&error];
        if (error) {
            [self showAlertWithMessage:error.description];
        }else{
            [self showAlertWithMessage:@"delete success"];
            self.progressView.progress = 0.0;
        }
    }
}

-(void)showAlertWithMessage:(NSString *)message{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * alert = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:alert];
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
