//
//  ViewController.m
//  CoreMotionDemo
//
//  Created by 朱小亮 on 16/4/9.
//  Copyright © 2016年 zhusven. All rights reserved.
//

#import "ViewController.h"
#import <CoreMotion/CoreMotion.h>
#import "ReactiveCocoa.h"
#import "motionViewModel.h"
#import "RACEXTScope.h"

@interface ViewController ()

{
    CMMotionManager *_motionManager;
    
    motionViewModel *_viewModel;
    
}
@property (strong, nonatomic)IBOutlet UILabel *labelGyro;
@property (strong, nonatomic)IBOutlet UISlider *sliderGyro;
@property (strong, nonatomic)IBOutlet UILabel *labelAcceleration;
@property (strong, nonatomic)IBOutlet UISlider *sliderAcceleration;

@property (strong, nonatomic)IBOutlet UILabel *labelScore;

@property (strong, nonatomic)IBOutlet UIButton *btnStart;

@property (assign, nonatomic)float score;


@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.score = 0;
    
    [self UI];
    _viewModel = [[motionViewModel alloc] initWithStandardGyro:1 acceleration:1];

    @weakify(self)
    [_viewModel.zipMotionSingel subscribeNext:^(id x) {
        @strongify(self)
        self.score+=[x floatValue];

    }];
    
    [[RACObserve(self, score) map:^id(id value) {
        if ([value floatValue]>100) {
            value = [NSNumber numberWithFloat:100.];
        }
        return [NSString stringWithFormat:@"%.f",[value floatValue]];
    }] subscribeNext:^(id x) {
        @strongify(self)
        self.labelScore.text = x;
    }];
}


- (void)UI{
    @weakify(self)
    [[self.sliderGyro rac_newValueChannelWithNilValue:[NSNumber numberWithFloat:0.]] subscribeNext:^(NSNumber *value) {
        @strongify(self)
        self.labelGyro.text = [NSString stringWithFormat:@"%f",[value floatValue]];
    }];
    
    [[self.sliderAcceleration rac_newValueChannelWithNilValue:[NSNumber numberWithFloat:0.]] subscribeNext:^(NSNumber * value) {
        @strongify(self)
        self.labelAcceleration.text = [NSString stringWithFormat:@"%f",[value floatValue]];
    }];

    [[self.btnStart rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self)
        self.labelScore.textColor = [UIColor blackColor];
        self.btnStart.enabled = NO;
        self.sliderGyro.enabled = NO;
        self.sliderAcceleration.enabled = NO;
        
        self.score = 0.;
        _viewModel.acceleration = self.sliderAcceleration.value;
        _viewModel.gyro = self.sliderGyro.value;
        [_viewModel startMotion];
        
        [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(stop) userInfo:nil repeats:NO];
        
        [self btnCountDown];

    }];
}


- (void)stop{
    self.labelScore.textColor = [UIColor redColor];
    self.btnStart.enabled = YES;
    self.sliderGyro.enabled = YES;
    self.sliderAcceleration.enabled = YES;
    [_viewModel stopMotion];
}


- (void)btnCountDown{
    __block int timeout=10; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(timer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                [self.btnStart setTitle:@"Start" forState:UIControlStateNormal];
                
            });
        }else{
            //            int minutes = timeout / 60;
            int seconds = timeout % 60;
            NSString *strTime = [NSString stringWithFormat:@"%.2d", seconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                [self.btnStart setTitle:strTime forState:UIControlStateNormal];
            });
            timeout--;
        }
    });
    dispatch_resume(timer);
}


@end
