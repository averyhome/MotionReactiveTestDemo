//
//  motionViewModel.h
//  CoreMotionDemo
//
//  Created by 朱小亮 on 16/4/9.
//  Copyright © 2016年 zhusven. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReactiveCocoa.h"
#import <CoreMotion/CoreMotion.h>
#import "RACEXTScope.h"
@interface motionViewModel : NSObject

@property (strong, nonatomic) RACSubject *accelerationSingel;

@property (strong, nonatomic) RACSubject *gyroSingel;

@property (strong, nonatomic) RACSignal *zipMotionSingel;


//以下为加速计和陀螺仪对应的标准值 可以自己设置
@property (assign, nonatomic) float gyro;

@property (assign, nonatomic) float acceleration;

- (id)initWithStandardGyro:(float)gyro acceleration:(float)acceleration;

- (void)stopMotion;

- (void)startMotion;
@end
