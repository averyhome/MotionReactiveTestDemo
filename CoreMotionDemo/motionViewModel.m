//
//  motionViewModel.m
//  CoreMotionDemo
//
//  Created by 朱小亮 on 16/4/9.
//  Copyright © 2016年 zhusven. All rights reserved.
//

#import "motionViewModel.h"

@interface motionViewModel()
@property (strong, nonatomic) CMMotionManager *motionManager;

@end


@implementation motionViewModel


- (id)initWithStandardGyro:(float)gyro acceleration:(float)acceleration{
    if (self == [super init]) {
        self.gyro = gyro;
        self.acceleration = acceleration;
        [self initLoad];
    }
    return self;
}

- (id)init{
    if (self == [super init]) {

        [self initLoad];

    }
    return self;
}

- (void)initLoad{
    self.gyro               = 1;
    self.acceleration       = 1;
    self.motionManager      = [[CMMotionManager alloc] init];
    self.accelerationSingel = [RACSubject subject];
    self.gyroSingel         = [RACSubject subject];
}

- (void)stopMotion{
    [self.motionManager stopGyroUpdates];
    [self.motionManager stopAccelerometerUpdates];
}


- (void)startMotion{

    @weakify(self)
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIDeviceOrientationDidChangeNotification object:nil] subscribeNext:^(id x) {
    }];

     NSOperationQueue *queue = [NSOperationQueue mainQueue];
    
    //陀螺仪
    [self.motionManager setGyroUpdateInterval:1/30];
    [self.motionManager startGyroUpdatesToQueue:queue withHandler:^(CMGyroData * _Nullable gyroData, NSError * _Nullable error) {
        @strongify(self)
        [self.gyroSingel sendNext:gyroData];
    }];

    //加速计
    [self.motionManager setAccelerometerUpdateInterval:1/30];
    [self.motionManager startAccelerometerUpdatesToQueue:queue withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
        @strongify(self)
        [self.accelerationSingel sendNext:accelerometerData];
    }];

    
}


- (RACSignal *)zipMotionSingel{
   __block CMGyroData *firstBase;
   __block CMAccelerometerData *secondBase;
    @weakify(self)
    RACSignal *singel = [[self.gyroSingel zipWith:self.accelerationSingel] map:^id(RACTuple *value) {
        @strongify(self)
        CMGyroData *first = value.first;
        CMAccelerometerData *second = value.second;
        
         float x = 0,y=0,z=0,a=0,b=0,c=0;
        if (firstBase){
         x       = fabs(firstBase.rotationRate.x - first.rotationRate.x);
         y       = fabs(firstBase.rotationRate.y - first.rotationRate.y);
         z       = fabs(firstBase.rotationRate.z - first.rotationRate.z);
        }

        if (secondBase) {
         a       = fabs(secondBase.acceleration.x - second.acceleration.x);
         b       = fabs(secondBase.acceleration.y -second.acceleration.y);
         c       = fabs(secondBase.acceleration.z -second.acceleration.z);
        }
                
        float gyro = (x+y+z)*self.gyro;
        float acceleration = (a+b+c)*self.acceleration;
        
        firstBase =[value.first copy];
        secondBase = [value.second copy];
        
        return [NSNumber numberWithFloat:(gyro+acceleration)/20];
    }];
    
   
    return singel;
}



@end
