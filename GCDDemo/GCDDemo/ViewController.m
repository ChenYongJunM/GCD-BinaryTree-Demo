//
//  ViewController.m
//  GCDDemo
//
//  Created by CYJ on 16/6/14.
//  Copyright © 2016年 CYJ. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self dispatch_set_targetDemo];
}

//可以设置优先级，也可以设置队列层级体系，比如让多个串行和并行队列在统一一个串行队列里串行执行
- (void)dispatch_set_targetDemo
{
    dispatch_queue_t serialQueue = dispatch_queue_create("com.gcddemo.serial", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t firstQueue = dispatch_queue_create("com.gcddemo.first", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t secondQueue = dispatch_queue_create("com.gcddemo.second", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_set_target_queue(firstQueue, serialQueue);
    dispatch_set_target_queue(secondQueue, serialQueue);
    
    dispatch_async(firstQueue, ^{
        NSLog(@"1");
        [NSThread sleepForTimeInterval:3.f];
    });
    dispatch_async(secondQueue, ^{
        NSLog(@"2");
        [NSThread sleepForTimeInterval:2.f];
    });
    dispatch_async(serialQueue, ^{
        NSLog(@"3");
        [NSThread sleepForTimeInterval:1.f];
    });
}

//让当前任务等待queue其他任务完成再执行的函数
- (void)dispatch_barrierDemo
{
    dispatch_queue_t queue = dispatch_queue_create("com.gcddemo.queue", DISPATCH_QUEUE_CONCURRENT);

    dispatch_async(queue, ^{
        NSLog(@"写入1");
        [NSThread sleepForTimeInterval:2.f];
    });
    dispatch_async(queue, ^{
        NSLog(@"写入2");
    });
    
    //等待前面任务完成
    dispatch_barrier_async(queue, ^{
        NSLog(@"开始读取");
    });
    
    dispatch_async(queue, ^{
        NSLog(@"写入3");
    });
}

//提交一个block到队列中，多次调用
- (void)dispatch_applyDemo
{
    dispatch_queue_t queue = dispatch_queue_create("com.gcddemo.queue", DISPATCH_QUEUE_CONCURRENT);
    
    //相比for循环 性能提升明显
    dispatch_apply(100, queue, ^(size_t t) {
        NSLog(@"%zu",t);
    });
    
    NSLog(@"打印完成");
    
    //dispatch_apply会阻塞主线程，可以套一个dispatch_async即可异步操作
}

//dispatch_block
- (void)dispatch_CreateBlockDemo
{
    dispatch_queue_t queue = dispatch_queue_create("com.gcddemo.queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_block_t block = dispatch_block_create(0, ^{
        NSLog(@"block");
    });
    dispatch_async(queue, block);
    
    //QOS way
    dispatch_block_t qosBlock = dispatch_block_create_with_qos_class(0, QOS_CLASS_USER_INTERACTIVE, -1, ^{
        NSLog(@"run qos block");
    });
    
    dispatch_async(queue, qosBlock);
}

//dispatch_block_wait
- (void)dispatch_blockWaitDemo
{
    dispatch_queue_t queue = dispatch_queue_create("com.gcddemo.queue", DISPATCH_QUEUE_SERIAL);
    dispatch_block_t block = dispatch_block_create(0, ^{
        NSLog(@"开始");
        [NSThread sleepForTimeInterval:5.f];
        NSLog(@"结束");
    });
    
    dispatch_async(queue, block);
    //dispatch_block_wait   一直等待block执行结束
    dispatch_block_wait(block, DISPATCH_TIME_FOREVER);
    NSLog(@"可以继续");
}

//dispatch_block_notify
- (void)dispatch_blockNotifyDemo
{
    dispatch_queue_t queue = dispatch_queue_create("com.gcddemo.queue", DISPATCH_QUEUE_SERIAL);
    dispatch_block_t firstBlock = dispatch_block_create(0, ^{
        NSLog(@"firstBlock 开始执行");
        [NSThread sleepForTimeInterval:2.f];
        NSLog(@"firstBlock 结束执行");
    });
    
    dispatch_async(queue, firstBlock);
    
    dispatch_block_t secondBlock = dispatch_block_create(0, ^{
        NSLog(@"secondBlock开始");
    });
    
    //当firstBlock执行完成通知secondBlock开始执行
    dispatch_block_notify(firstBlock, queue, secondBlock);
}

//取消执行block   ios8以上支持
- (void)dispatch_BlockCanleDemo
{
    dispatch_queue_t queue = dispatch_queue_create("com.gcddemo.queue", DISPATCH_QUEUE_SERIAL);
    dispatch_block_t firstBlock = dispatch_block_create(0, ^{
        NSLog(@"firstBlock开始执行");
        [NSThread sleepForTimeInterval:2.0];
        NSLog(@"firstBlock执行完成");
    });
    
    dispatch_block_t secondBlock = dispatch_block_create(0, ^{
        NSLog(@"secondBlock开始执行");
    });
    
    dispatch_async(queue, firstBlock);
    dispatch_async(queue, secondBlock);

    //取消secondBlock执行
    dispatch_block_cancel(secondBlock);
}

//dispatch_group_wait
- (void)dispatch_GroupWaitDemo
{
    dispatch_queue_t queue = dispatch_queue_create("com.gcddemo.queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, queue, ^{
        NSLog(@"11");
    });
    dispatch_group_async(group, queue, ^{
        [NSThread sleepForTimeInterval:2.0];
        NSLog(@"22");
    });
    
    //一直等待group执行完成
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    NSLog(@"group执行结束");
    
    dispatch_group_notify(group, queue, ^{
        NSLog(@"gropu执行完成通知");
    });
}

- (void)dispatch_semaphoreDemo
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(3);
    
    //并行队列下地异步函数会开启N条子线程，且执行任务的顺序我们无法控制
    dispatch_queue_t queue = dispatch_queue_create("chen.com", DISPATCH_QUEUE_CONCURRENT);
    //并行队列虽然可以并发的执行多个任务，但是任务开始执行的顺序和其加入队列的顺序相同
    dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    dispatch_async(concurrentQueue, ^{
        [self task_first:semaphore];
    });
    dispatch_async(concurrentQueue, ^{
        [self task_second:semaphore];
    });
    dispatch_async(concurrentQueue, ^{
        [self task_third:semaphore];
    });
}

//dispatch_semaphore_wait信号量+1
//dispatch_semaphore_signal 信号量-1
//一般成对使用，当信号量等于0停止运行-等待大于0继续运行
//主要用于保证同步，解决资源抢占问题
- (void)task_first:(dispatch_semaphore_t)semaphore
{
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSLog(@"First task starting");
    [NSThread sleepForTimeInterval:1.f];
    NSLog(@"First task is done");
    dispatch_semaphore_signal(semaphore);
}
- (void)task_second:(dispatch_semaphore_t)semaphore
{
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSLog(@"second task starting");
    [NSThread sleepForTimeInterval:1.f];
    NSLog(@"second task is done");
    dispatch_semaphore_signal(semaphore);
}
- (void)task_third:(dispatch_semaphore_t)semaphore
{
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    NSLog(@"third task starting");
    [NSThread sleepForTimeInterval:1.f];
    NSLog(@"third task is done");
    dispatch_semaphore_signal(semaphore);
}

- (void)dispatch_sourceEventDemo
{
    dispatch_queue_t queue = dispatch_queue_create("com.gcddemo.queue", DISPATCH_QUEUE_SERIAL);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), 10*NSEC_PER_SEC, 1*NSEC_PER_SEC); //每10秒触发timer，误差1秒
    
    dispatch_source_set_event_handler(timer, ^{
        NSLog(@"timer");
        
    });
    dispatch_resume(timer);
}

//dispatch source timer demo
- (void)dispatchSourceTimerDemo {
    //NSTimer在主线程的runloop里会在runloop切换其它模式时停止，这时就需要手动在子线程开启一个模式为NSRunLoopCommonModes的runloop，如果不想开启一个新的runloop可以用不跟runloop关联的dispatch source timer
    dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,0, 0, DISPATCH_TARGET_QUEUE_DEFAULT);
    dispatch_source_set_event_handler(source, ^(){
        NSLog(@"Time flies.");
    });
    dispatch_source_set_timer(source, DISPATCH_TIME_NOW, 5ull * NSEC_PER_SEC,100ull * NSEC_PER_MSEC);
    dispatch_resume(source);
}

//Dead Lock case 1
- (void)deadLockCase1 {
    NSLog(@"1");
    //主队列的同步线程，按照FIFO的原则（先入先出），2排在3后面会等3执行完，但因为同步线程，3又要等2执行完，相互等待成为死锁。
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSLog(@"2");
    });
    NSLog(@"3");
}

//Dead Lock case 2
- (void)deadLockCase2 {
    NSLog(@"1");
    //3会等2，因为2在全局并行队列里，不需要等待3，这样2执行完回到主队列，3就开始执行
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSLog(@"2");
    });
    NSLog(@"3");
}

//Dead Lock case 3
- (void)deadLockCase3 {
    dispatch_queue_t serialQueue = dispatch_queue_create("com.starming.gcddemo.serialqueue", DISPATCH_QUEUE_SERIAL);
    NSLog(@"1");
    dispatch_async(serialQueue, ^{
        NSLog(@"2");
        //串行队列里面同步一个串行队列就会死锁
        dispatch_sync(serialQueue, ^{
            NSLog(@"3");
        });
        NSLog(@"4");
    });
    NSLog(@"5");
}

//Dead Lock case 4
- (void)deadLockCase4 {
    NSLog(@"1");
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"2");
        //将同步的串行队列放到另外一个线程就能够解决
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSLog(@"3");
        });
        NSLog(@"4");
    });
    NSLog(@"5");
}

//Dead Lock case 5
- (void)deadLockCase5 {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"1");
        //回到主线程发现死循环后面就没法执行了
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSLog(@"2");
        });
        NSLog(@"3");
    });
    NSLog(@"4");
    //死循环
    while (1) {
        //
    }
}

@end
