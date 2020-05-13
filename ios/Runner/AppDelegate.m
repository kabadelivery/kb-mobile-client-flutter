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
    [GMSServices provideAPIKey:@"AIzaSyBhDXLF0zLWJcjE4_9z_WkPQvq_drSUXyc"];
    [GeneratedPluginRegistrant registerWithRegistry:self];

  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end

 
