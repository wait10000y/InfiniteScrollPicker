## InfiniteScrollPicker

程序修改自: https://github.com/Seitk/InfiniteScrollPicker <br>
已经改的面目全非了,只使用了源程序的无限循环的功能; 调用方法:<br><br>

``` object-c
 // 初始化
 InfiniteScrollPicker *ispicker = [[InfiniteScrollPicker alloc] initWithFrame:CGRectMake(0, 100, 320, 44)];
 // 设置背景色
 ispicker.backgroundColor = [UIColor greenColor];
 // 设置图片拼图
 ispicker.showImage = [UIImage imageNamed:@"image_part_default"];
// 设置 UIView拼图
ispicker.showView = nil;
// 设置初始value值
[ispicker setDefaultValue:100];
// 添加事件回调 UIScrollView 的事件
ispicker.delegate = self;
// 添加 value值 变化检测
[ispicker setValueCheckBlock:^(id sender, float value) {
NSLog(@"---- value chekced:%.2f ----",value);
}];
[self.view addSubview:ispicker];

#pragma mark ------ UIScrollView delegate ------
- (void)scrollViewDidScroll:(InfiniteScrollPicker *)scrollView
{
NSLog(@"------ scrollViewDidScroll : value: %f \t, pointX: %f \t--------",scrollView.value,scrollView.contentOffset.x);
}

- (void)scrollViewDidEndDragging:(InfiniteScrollPicker *)scrollView willDecelerate:(BOOL)decelerate
{
NSLog(@"------- scrollViewDidEndDragging willDecelerate %@ --------",decelerate?@"YES":@"NO");
}

- (void)scrollViewDidEndDecelerating:(InfiniteScrollPicker *)scrollView
{
NSLog(@"------- scrollViewDidEndDecelerating --------");
}

-(void)scrollViewWillBeginDecelerating:(InfiniteScrollPicker *)scrollView
{
NSLog(@"------- scrollViewWillBeginDecelerating --------");
}
- (void)scrollViewWillBeginDragging:(InfiniteScrollPicker *)scrollView
{
NSLog(@"------- scrollViewWillBeginDragging --------");
}
```
