//
//  CleanMenuBar.m
//  CleanMenuBar
//
//  Created by Kevin Beaulieu on 12/22/16.
//  Copyright © 2016 Kevin M Beaulieu. All rights reserved.
//

#import "CleanMenuBar.h"

Boolean hidden;
NSStatusItem *theKing;
CleanMenuBar *plugin;

@implementation CleanMenuBar

void notificationCallback (CFNotificationCenterRef center, void * observer, CFStringRef name, const void * object, CFDictionaryRef userInfo) {
    NSDictionary *dict = (__bridge NSDictionary *)(userInfo);
    
    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
    NSString *processName = [processInfo processName];
    int processID = [processInfo processIdentifier];
    
    NSLog(@"wb_ Process Name: '%@' Process ID:'%d'", processName, processID);
    NSLog(@"wb_ %@", dict);
    
//    NSString *bundle = [dict objectForKey:@"bundleID"];
//    if (![bundle isEqualToString:@""]) {
//        [plugin toggleStatusItem];
//    }
}

+ (CleanMenuBar*) sharedInstance {
    static CleanMenuBar* plugin = nil;
    
    if (plugin == nil)
        plugin = [[CleanMenuBar alloc] init];
    
    return plugin;
}

+ (void) load {
    plugin = [CleanMenuBar sharedInstance];
    hidden = false;
    
    CFNotificationCenterRef center = CFNotificationCenterGetDistributedCenter();
    CFNotificationCenterAddObserver(center, NULL, notificationCallback, CFSTR("cleanMenu"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    
    NSArray *appsToHide = @[
            @"co.atlasinformatics.Recall",
            @"com.todoist.mac.Todoist",
            @"com.knock.mac",
            @"net.matthewpalmer.Rocket",
            @"com.lastpass.LastPass",
            @"com.prosofteng.DriveGenius2",
            @"com.prosofteng.DriveGenius2.DrivePulse",
            @"com.google.GoogleDrive"
    ];
    
    NSString *appID = [[NSBundle mainBundle] bundleIdentifier];
    if ([appsToHide containsObject:appID])
        [plugin disableStatusItem];
}

-(void)toggleStatusItem {
    NSString *appID = [[NSBundle mainBundle] bundleIdentifier];
//    if ([appsToHide containsObject:appID]) {
        if (!hidden)
            [plugin disableStatusItem];
        else
            [plugin enableStatusItem];
//    }
}

-(void)enableStatusItem {
    hidden = false;
    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    NSPointerArray *statusItems = [statusBar valueForKey:@"_items"];
    for (int i = 0; i < statusItems.count; i++) {
        NSStatusItem *item = [statusItems pointerAtIndex:i];
        [item setVisible:true];
    }
}

-(void)disableStatusItem {
    hidden = true;
    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    NSPointerArray *statusItems = [statusBar valueForKey:@"_items"];
    for (int i = 0; i < statusItems.count; i++) {
        NSStatusItem *item = [statusItems pointerAtIndex:i];
//        [statusBar removeStatusItem:item];
        [item setVisible:false];
    }
}

@end
