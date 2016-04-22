//
//  AppDelegate.m
//  AutoCrash
//
//  Created by HItesh on 4/22/16.
//  Copyright © 2016 Hitesh. All rights reserved.
//

#import "AppDelegate.h"
#import "SOLocationManager.h"
#import "SOMotionDetector.h"
#import "SOStepDetector.h"
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
@interface AppDelegate ()

@end

@implementation AppDelegate

{
    int stepCount;
    BOOL nowRunning;
    BOOL isSuddenStop;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeSound
                                                                                    categories:nil]];
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
        UILocalNotification *note = [UILocalNotification new];
        note.alertBody = @"Are you safe??";
        note.soundName = UILocalNotificationDefaultSoundName;
        [application presentLocalNotificationNow:note];
    }
    
    [[SOLocationManager sharedInstance] startSignificant];
    
    UIDevice *device = [UIDevice currentDevice];
    device.batteryMonitoringEnabled = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryChanged:) name:@"UIDeviceBatteryStateDidChangeNotification" object:device];
    
    isSuddenStop=false;
    nowRunning=false;
    [SOMotionDetector sharedInstance].motionTypeChangedBlock = ^(SOMotionType motionType) {
        NSString *type = @"";
        switch (motionType) {
            case MotionTypeNotMoving:
                type = @"Not moving";
                if (nowRunning) {
                    isSuddenStop=true;
                }
                break;
            case MotionTypeWalking:
                type = @"Walking";
                nowRunning=true;
                break;
            case MotionTypeRunning:
                type = @"Running";
                break;
            case MotionTypeAutomotive:
                type = @"Automotive";
                break;
        }
        
        
        NSString *motionTypeLabel = type;
        NSLog(motionTypeLabel);
        
        if (isSuddenStop)
        {
            isSuddenStop=false;
            
            UILocalNotification *note = [UILocalNotification new];
            note.alertBody = @"Are you safe??";
            note.soundName = UILocalNotificationDefaultSoundName;
            [[UIApplication sharedApplication] presentLocalNotificationNow:note];
        }
        NSLog( @"type %@",type);
        
        
    };
    
    [SOMotionDetector sharedInstance].locationChangedBlock = ^(CLLocation *location) {
        NSString *speed = [NSString stringWithFormat:@"%.2f km/h",[SOMotionDetector sharedInstance].currentSpeed * 3.6f];
        NSLog(speed);
    };
    
    [SOMotionDetector sharedInstance].accelerationChangedBlock = ^(CMAcceleration acceleration) {
        BOOL isShaking = [SOMotionDetector sharedInstance].isShaking;
        // NSLog(@"not shaking");
    };
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        [SOMotionDetector sharedInstance].useM7IfAvailable = YES; //Use M7 chip if available, otherwise use lib's algorithm
    }
    
    //This is required for iOS > 9.0 if you want to receive location updates in the background
    [SOLocationManager sharedInstance].allowsBackgroundLocationUpdates = YES;
    
    //Starting motion detector
    [[SOMotionDetector sharedInstance] startDetection];
    
    //Starting pedometer
    [[SOStepDetector sharedInstance] startDetectionWithUpdateBlock:^(NSError *error) {
        if (error) {
            NSLog(@"%@", error.localizedDescription);
            return;
        }
        
        stepCount++;
        NSString *stepCountLabel = [NSString stringWithFormat:@"Step count: %d", stepCount];
          NSLog(stepCountLabel);
    }];
    
    return YES;
}
- (void)batteryChanged:(NSNotification *)notification
{
    UIDevice *device = [UIDevice currentDevice];
    NSLog(@"state: %i ", device.batteryState);
    
    
    if (device.batteryState==2) {
        
        
        UILocalNotification *note = [UILocalNotification new];
        note.alertBody = @"Are you driving??";
        note.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] presentLocalNotificationNow:note];
        
    }
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
