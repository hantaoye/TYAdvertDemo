//
//  WCHomeAdvertView.m
//  WCHomeTset
//
//  Created by Mac on 15/9/11.
//  Copyright (c) 2015年 TY. All rights reserved.
//

#import "TYAdvertView.h"
#import "UIImageView+WebCache.h"

@interface TYAdvertView () <UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) NSMutableArray *imageViews;

//@property (strong, nonatomic) RSAdvertProgressBar *progressView;

@property (strong, nonatomic) UIPageControl *pageControl;

@property (copy, nonatomic) WCHomeAdvertAction action;

@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) NSTimeInterval interval;

@end

@implementation TYAdvertView

- (void)dealloc {
    [self _stopTimer];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self _setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self _setup];
    }
    return self;
}

#pragma mark - action

- (void)startAnimation {
    [self _startTimer];
}

- (void)stopAnimation {
    [self _stopTimer];
}

- (void)setAdvertInterval:(NSTimeInterval)interval {
    if (interval == 0) {
        return;
    }
    _interval = interval;
    if (_images.count) {
        [self _stopTimer];
        [self _startTimer];
    }
}

- (void)setAdvertAction:(WCHomeAdvertAction)action {
    if (action) {
        _action = [action copy];
    }
}

- (void)setCurrentPageColor:(UIColor *)currentPageColor {
    if (currentPageColor) {
        _currentPageColor = currentPageColor;
        _pageControl.currentPageIndicatorTintColor = currentPageColor;
    }
}

- (void)setPageIndicatorTintColor:(UIColor *)pageIndicatorTintColor {
    if (pageIndicatorTintColor) {
        _pageIndicatorTintColor = pageIndicatorTintColor;
        _pageControl.pageIndicatorTintColor = pageIndicatorTintColor;
    }
}

- (void)_imageView:(UIImageView *)imageView loadImage:(id)image {
    [imageView sd_cancelCurrentImageLoad];
    if ([image isKindOfClass:[NSString class]]) {
        NSString *imageURLString = image;
        [imageView sd_setImageWithURL:[NSURL URLWithString:imageURLString] placeholderImage:nil];
    } else if ([image isKindOfClass:[NSURL class]]) {
        NSURL *imageURL = image;
        [imageView sd_setImageWithURL:imageURL placeholderImage:nil];
    } else if ([image isKindOfClass:[UIImage class]]) {
        imageView.image = image;
    } else {
        assert(0 && @"image错误");
    }
}

- (void)setAdvertImagesOrUrls:(NSArray *)images {
    if (!images.count) {
        return;
    }
    _images = images;

    [_imageViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_imageViews removeAllObjects];
    [self _stopTimer];
    
    for (int idx = 0; idx < images.count + 2; idx++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.userInteractionEnabled = YES;
        [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_clickImageView:)]];
        if (idx == 0) {
            [self _imageView:imageView loadImage:[images lastObject]];
            imageView.tag = images.count;
        } else if (idx == images.count + 1) {
            [self _imageView:imageView loadImage:[images firstObject]];
            imageView.tag = 0;
        } else {
            [self _imageView:imageView loadImage:images[idx - 1]];
            imageView.tag = idx - 1;
        }
        [_scrollView addSubview:imageView];
        [_imageViews addObject:imageView];
    }
    
    _pageControl.numberOfPages = images.count;
    _pageControl.currentPage = 0;
//    [self _setupFrame];
    
    if (images.count < 2) {
        return;
    }
    [self _startTimer];
}

- (void)_clickImageView:(UITapGestureRecognizer *)gesture {
    if (_action) {
        _action(gesture.view.tag);
    }
}


#pragma mark- UISrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //当展示最后一个的时候
    if (scrollView.contentOffset.x / scrollView.bounds.size.width >= (_imageViews.count - 1)) {
        [scrollView setContentOffset:CGPointMake(scrollView.frame.size.width, 0) animated:NO];
    }
    //显示位置为0，0的时候
    if (scrollView.contentOffset.x <= 0) {
        [scrollView setContentOffset:CGPointMake(scrollView.frame.size.width * (_imageViews.count - 2), 0) animated:NO];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    _pageControl.currentPage = _scrollView.contentOffset.x / _scrollView.frame.size.width - 1;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self _stopTimer];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //等下一次runloop的时候再更新， 因为手动拖动时候scrollViewDidScroll方法里的if语句执行完后会直接来到这个方法，此时的runloop没有刷新。
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _pageControl.currentPage = _scrollView.contentOffset.x / _scrollView.frame.size.width - 1;
    });
    [self _startTimer];
}

#pragma mark - setup

- (void)_startAnimation:(NSTimer *)timer {
    [_scrollView setContentOffset:CGPointMake(_scrollView.contentOffset.x + _scrollView.bounds.size.width, 0) animated:YES];
}

- (void)_startTimer {
    if (!_timer) {
        _timer = [NSTimer timerWithTimeInterval:_interval target:self selector:@selector(_startAnimation:) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
}

- (void)_stopTimer {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self _setupFrame];
}

- (void)_setupFrame {
    _scrollView.frame = self.bounds;
    _scrollView.contentSize = CGSizeMake(_imageViews.count * _scrollView.bounds.size.width, 0);
    _scrollView.contentOffset = CGPointMake(_scrollView.bounds.size.width, 0);

    _pageControl.frame = CGRectMake(0, 0, 100, 20);
    _pageControl.center = CGPointMake(self.center.x, self.bounds.size.height - _pageControl.bounds.size.height - 20);
    
    for (int idx = 0; idx < _imageViews.count; idx++) {
        UIImageView *imageView = _imageViews[idx];
        imageView.frame = CGRectMake(idx * self.bounds.size.width, 0, _scrollView.bounds.size.width, _scrollView.bounds.size.height);
    }
}

- (void)_setup {
    _interval = 3.0;
    [_imageViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _imageViews = [NSMutableArray array];
    
    [_scrollView removeFromSuperview];
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.delegate = self;
    _scrollView.scrollsToTop = NO;
    [self addSubview:_scrollView];
    
    [_pageControl removeFromSuperview];
    _pageControl = [[UIPageControl alloc] init];
    _pageControl.pageIndicatorTintColor = [UIColor blackColor];
    _pageControl.currentPageIndicatorTintColor = [UIColor redColor];
    [self addSubview:_pageControl];
}

@end
