//
//  InfiniteScrollPicker.m
//  InfiniteScrollPickerExample
//
//  Created by Philip Yu on 6/6/13.
//  Copyright (c) 2013 Philip Yu. All rights reserved.
//

#import "InfiniteScrollPicker.h"

@implementation InfiniteScrollPicker
{
  UIView *mShowView;
  UIImage *mShowImage;
  InfiniteScrollPickerBlock mCheckBlock;
  
  CGSize itemSize;
//  NSInteger itemNumber;
  NSMutableArray *imageStore; // 显示的 重复部分列表
  BOOL snapping; // 是否滚动结束
  
  // 重复利用的检查点和距离计算
  float minCheckPoint;
  float minSetPoint;
  float maxCheckPoint;
  float maxSetPoint;
  float minDistances;
  float maxDistances;
  
// 初始时 = contentOffset.x 偏移量
  float offsetDefault; // 用户设定 default value
  float offsetBalance; // 矫正 偏移量(循环时 自动平衡)
  float offsetShow; // 显示的偏移量
}

@synthesize value = offsetShow;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      offsetDefault = 0;
      offsetBalance = 0;
      offsetShow = 0;
      snapping = NO;
      imageStore = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)initInfiniteScrollView
{
  float maxHeight = self.frame.size.height;
  float maxWidth = self.frame.size.width;
  itemSize = CGSizeMake(maxWidth*2, maxHeight);
  
  if (mShowView) {
    if (mShowView.frame.size.height > maxHeight) {
      CGRect frame = mShowView.frame;
      frame.size.width = (frame.size.width*maxHeight)/frame.size.height;
      frame.size.height = maxHeight;
      mShowView.frame = frame;
    }
    itemSize = mShowView.frame.size;
  }else if (mShowImage)
  {
    if (mShowImage.size.height > maxHeight){
      itemSize.width = (mShowImage.size.width*maxHeight)/mShowImage.size.height;
      itemSize.height = maxHeight;
    }else{
      itemSize = mShowImage.size;
    }
  }else{
    mShowImage = [UIImage new];
  }
  // 计算最小添加的item个数(最少占满三个宽度)
  int itemNum = ceil(maxWidth*3/(itemSize.width*5));
  
  float sectionSize = itemNum * itemSize.width;
   minCheckPoint = (sectionSize - sectionSize/2);
   minSetPoint = sectionSize * 2 - sectionSize/2;
   maxCheckPoint = (sectionSize * 3 + sectionSize/2);
   maxSetPoint = sectionSize * 2 + sectionSize/2;
  minDistances = minSetPoint-minCheckPoint;
  maxDistances = maxCheckPoint-maxSetPoint;
  NSLog(@"------ initInfiniteScrollView item num:%d size: %@ ----------",itemNum,NSStringFromCGSize(itemSize));
//  NSLog(@"------- initInfiniteScrollView reset point: min[%f.1]->[%f.1]=%.1f , max[%f.1]->[%.1f]=%.1f --------",minCheckPoint,minSetPoint,minDistances,maxCheckPoint,maxSetPoint,maxDistances);
    self.pagingEnabled = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
  
  if (imageStore.count>0) {
    for (UIView *tItem in imageStore) {
      [tItem removeFromSuperview];
    }
    [imageStore removeAllObjects];
  }
  if (mShowView || mShowImage) {
    // Init 5 set of images, 3 for user selection, 2 for
    for (int i = 0; i < itemNum*5; i++)
    {
      // Place images into the bottom of view
      CGRect tFrame = CGRectMake(i * itemSize.width, (self.frame.size.height - itemSize.height)/2, itemSize.width, itemSize.height);
      UIView *tempItem;
      if(mShowView){
        UIView *tempView = [self duplicateView:mShowView];
        tempView.frame = tFrame;
        tempItem = tempView;
      }else{
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:tFrame];
        imgView.image = mShowImage;
        tempItem = imgView;
      }
//      NSLog(@"------ initScrollView add showView: %@ ----------",tempItem);
      [imageStore addObject:tempItem];
      [self addSubview:tempItem];
    }
    
    self.contentSize = CGSizeMake(itemNum * 5 * itemSize.width, self.frame.size.height);
    
    float viewMiddle = itemNum * 2 * itemSize.width;
    [self setContentOffset:CGPointMake(viewMiddle, 0)];
    offsetBalance = -self.contentOffset.x;
//    self.delegate = self;
  }
}

// Duplicate UIView
- (UIView*)duplicateView:(UIView*)view
{
  NSData * tempArchive = [NSKeyedArchiver archivedDataWithRootObject:view];
  return [NSKeyedUnarchiver unarchiveObjectWithData:tempArchive];
}

-(void)setDefaultValue:(float)theValue
{
  offsetDefault = theValue;
}

-(void)setValueCheckBlock:(InfiniteScrollPickerBlock)theBlock
{
  mCheckBlock = theBlock;
}

- (void)setShowView:(UIView *)showView
{
  if (showView) {
    mShowView = showView;
  }else{
    if (mShowView) {
      mShowView = nil;
    }
  }
    [self initInfiniteScrollView];
}

- (void)setShowImage:(UIImage *)showImage
{
  if (showImage) {
    mShowImage = showImage;
  }else{
    if (mShowImage) {
      mShowImage = nil;
    }
  }
  [self initInfiniteScrollView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
  
  float offsetX = self.contentOffset.x;
  if (offsetX <= minCheckPoint){
    offsetBalance -= minDistances;
    self.contentOffset = CGPointMake(minDistances+offsetX, 0);
  } else if (offsetX >= maxCheckPoint) {
    offsetBalance += (maxCheckPoint-maxSetPoint);
    self.contentOffset = CGPointMake(offsetX - maxDistances, 0);
  }
  [self reloadView:offsetX];
  float newOffset = offsetBalance+offsetX;
  offsetShow = newOffset + offsetDefault;
  mCheckBlock?mCheckBlock(self,offsetShow):nil;
//  NSLog(@"---===--- layoutSubviews : offset: %f \t, pointX: %f \t---===---",offsetShow,offsetX);
}

// 添加 每个cell的特效
- (void)reloadView:(float)offset
{
  return;
  
//  NSLog(@"----- reloadView offset:%f ------",offset);
    float biggestSize = 0;
    id biggestView;

    for (int i = 0; i < imageStore.count; i++) {
        
        UIImageView *view = [imageStore objectAtIndex:i];
        
        if (view.center.x > (offset - itemSize.width ) && view.center.x < (offset + self.frame.size.width + itemSize.width))
        {
            float tOffset = (view.center.x - offset) - self.frame.size.width/4;
            
            if (tOffset < 0 || tOffset > self.frame.size.width)
              tOffset = 0;
          // 设置 居中的view item的显示特效
          float addHeight = 0;
//            float addHeight = (-1 * fabsf((tOffset)*2 - self.frame.size.width/2) + self.frame.size.width/2)/4;
//            if (addHeight < 0) addHeight = 0;
          
          view.frame = CGRectMake(view.frame.origin.x,self.frame.size.height - itemSize.height,itemSize.width + addHeight,itemSize.height + addHeight);

            if (((view.frame.origin.x + view.frame.size.width) - view.frame.origin.x) > biggestSize)
            {
                biggestSize = ((view.frame.origin.x + view.frame.size.width) - view.frame.origin.x);
                biggestView = view;
            }
//          NSLog(@"------- reloadView biggestSize:%f , frame:%@ ----------",biggestSize,NSStringFromCGRect(view.frame));
          
        } else {
            view.frame = CGRectMake(view.frame.origin.x, self.frame.size.height, itemSize.width, itemSize.height);
            for (UIImageView *imageView in view.subviews)
            {
                imageView.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
            }
        }
    }
    
    for (int i = 0; i < imageStore.count; i++)
    {
        UIView *cBlock = [imageStore objectAtIndex:i];
        if (i > 0)
        {
            UIView *pBlock = [imageStore objectAtIndex:i-1];
            cBlock.frame = CGRectMake(pBlock.frame.origin.x + pBlock.frame.size.width, cBlock.frame.origin.y, cBlock.frame.size.width, cBlock.frame.size.height);
        }
    }

    [(UIView *)biggestView setAlpha:1.0];
}


@end
