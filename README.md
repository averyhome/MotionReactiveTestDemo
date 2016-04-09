# MotionReactiveTestDemo


### 此Demo涉及到reactivecocoa的练习和加速计和陀螺仪的练习 均第一次使用 欢迎使用


			

		#import <Foundation/Foundation.h>
		#import "ReactiveCocoa.h"
		#import <CoreMotion/CoreMotion.h>
		#import "RACEXTScope.h"
@interface motionViewModel : NSObject<br>

		这个为加速计的信号
		
@property (strong, nonatomic) RACSubject *accelerationSingel;

		陀螺仪的信号
		
@property (strong, nonatomic) RACSubject *gyroSingel;

		把上面2个混合后处理的信号
		
@property (strong, nonatomic) RACSignal *zipMotionSingel;


		以下为加速计和陀螺仪对应的标准值 可以自己设置
		 
@property (assign, nonatomic) float gyro;

@property (assign, nonatomic) float acceleration;


		构造方法
- (id)initWithStandardGyro:(float)gyro acceleration:(float)acceleration;


		不用解释也懂
- (void)stopMotion;

- (void)startMotion;<br>
@end


