#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import "GoogleMaps/GoogleMaps.h"

@import Firebase;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    if (@available(iOS 10.0, *)) {
       [UNUserNotificationCenter currentNotificationCenter].delegate =
           (id<UNUserNotificationCenterDelegate>)self;
     }


    [FIRApp configure];
    [GMSServices provideAPIKey:@"AIzaSyC2GyigAWazOTJtOcR6XM1UfJLGl2eqQd0"];
    [GeneratedPluginRegistrant registerWithRegistry:self];

  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end

 
