# NEDownloader
* NEDownloader support Breakpoint continuingly

![downloadExample](https://github.com/XieXieZhongxi/NEDownloader/blob/master/screenshot/downloadExample.gif)


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

