//
//  WCHomeAdvertView.h
//  WCHomeTset
//
//  Created by Mac on 15/9/11.
//  Copyright (c) 2015年 TY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TYAdvertView : UIView

typedef void (^WCHomeAdvertAction)(NSInteger idx);

@property (strong, nonatomic, readonly) NSArray *images;

@property (strong, nonatomic) UIColor *currentPageColor;
@property (strong, nonatomic) UIColor *pageIndicatorTintColor;

- (void)setAdvertImagesOrUrls:(NSArray *)images;

- (void)setAdvertAction:(WCHomeAdvertAction)action;

/**
 *  default 3.0
 */
- (void)setAdvertInterval:(NSTimeInterval)interval;

- (void)startAnimation;

- (void)stopAnimation;

@end
