# NEDownloader
* NEDownloader support Breakpoint continuingly

![](https://github.com/XieXieZhongxi/CATransition/blob/master/screenshot/UIViewController.gif)


###sample code
* rsume
```objective-c
__weak typeof(self) weakSelf = self;
self.downloader = [[NEDownloader alloc]init];
[self.downloader startWithURL:url progressHandler:^(long long completedUnitCount, long long totalUnitCount) {

} completeBlock:^(NSString *filePath, NSString *url, BOOL completed, NSError *error) {

}];
```


* suspend
```objective-c
[self.downloader suspend];
```

