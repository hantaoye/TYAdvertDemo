//
//  ViewController.m
//  TYAdvertDemo
//
//  Created by Mac on 15/10/2.
//  Copyright © 2015年 TY. All rights reserved.
//

#import "ViewController.h"
#import "TYAdvertView.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet TYAdvertView *advertView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableArray *images = [NSMutableArray array];
    for (NSInteger idx = 0; idx < 4; idx++) {
        [images addObject:[UIImage imageNamed:[NSString stringWithFormat:@"%ld.jpg", (long)(idx + 1)]]];
    }
    
    [_advertView setAdvertImagesOrUrls:images];
    
//    __weak typeof(self) weakSelf = self;
    
    [_advertView setAdvertAction:^(NSInteger idx) {
        //里面用到的self需要使用weakSelf。

        NSLog(@"link image idx ====== %ld", (long)idx);
    }];
    
    [_advertView setCurrentPageColor:[UIColor redColor]];
    [_advertView setPageIndicatorTintColor:[UIColor greenColor]];
    
    [_advertView setAdvertInterval:1.0];
    
    [_advertView startAnimation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
