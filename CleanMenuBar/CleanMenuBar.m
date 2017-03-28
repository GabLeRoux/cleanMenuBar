//
//  CleanMenuBar.m
//  CleanMenuBar
//
//  Created by Kevin Beaulieu on 12/22/16.
//  Copyright © 2016 Kevin M Beaulieu. All rights reserved.
//

#define prefs    [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/org.w0lf.cleanMenuBar.plist"]

#import "ZKSwizzle.h"
@import AppKit;

@interface CleanMenuBar : NSObject
@end

@interface wb_cmb_NSStatusItem : NSObject
@end

NSMutableDictionary *pluginPrefs;
NSMutableDictionary *systemItems;
CleanMenuBar *plugin;

@implementation CleanMenuBar

void notificationCallback (CFNotificationCenterRef center, void * observer, CFStringRef name, const void * object, CFDictionaryRef userInfo) {
//    NSDictionary *dict = (__bridge NSDictionary *)(userInfo);
//    NSProcessInfo *processInfo = [NSProcessInfo processInfo];
//    NSString *processName = [processInfo processName];
//    int processID = [processInfo processIdentifier];
//    NSLog(@"wb_ Process Name: '%@' Process ID:'%d' Bundle ID:'%@'", processName, processID, bundleIdentifier);
//    NSLog(@"wb_ %@", dict);
    [plugin updateandApply];
}

+ (CleanMenuBar*)sharedInstance {
    static CleanMenuBar* plugin = nil;
    
    if (plugin == nil)
        plugin = [[CleanMenuBar alloc] init];
    
    return plugin;
}

+ (void)load {
    plugin = [CleanMenuBar sharedInstance];
    systemItems = [[ NSMutableDictionary alloc] init];
    ZKSwizzle(wb_cmb_NSStatusItem, NSStatusItem);
    
    CFNotificationCenterRef center = CFNotificationCenterGetDistributedCenter();
    CFNotificationCenterAddObserver(center, NULL, notificationCallback, CFSTR("cleanMenu"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
    
    BOOL apply = false;
    for (NSWindow *win in [NSApp windows])
        if ([[win className] isEqualToString:@"NSStatusBarWindow"])
            apply = true;
    
    if (apply)
        [plugin updateandApply];
}

-(void)updateandApply {
    [self updateItemList];
    [self applyStatusChanges];
}

-(void)updateItemList {
    // Update item window list
    /* CFArrayRef windowList = CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements, kCGNullWindowID); */
    CFArrayRef windowList = CGWindowListCopyWindowInfo(kCGWindowListOptionAll, kCGNullWindowID);
    NSArray *myArray=[(__bridge NSArray *)windowList copy];
    for (int i = 0; i < myArray.count; i++) {
        NSDictionary *winInfo = [myArray objectAtIndex:i];
        if ([[winInfo objectForKey:@"kCGWindowLayer"] integerValue] == 25) {
//            NSLog(@"wb_ %@", winInfo);
            NSString* appName = [winInfo objectForKey:@"kCGWindowOwnerName"];
            if ([appName isEqualToString:@"SystemUIServer"]) {
                appName = [winInfo objectForKey:@"kCGWindowName"];
                NSRange replaceRange = [appName rangeOfString:@"Apple"];
                if (replaceRange.location != NSNotFound)
                    appName = [appName stringByReplacingCharactersInRange:replaceRange withString:@""];
                replaceRange = [appName rangeOfString:@"Extra"];
                if (replaceRange.location != NSNotFound)
                    appName = [appName stringByReplacingCharactersInRange:replaceRange withString:@""];
            }
            [systemItems setObject:appName forKey:[winInfo objectForKey:@"kCGWindowNumber"]];
        }
    }
}

-(void)applyStatusChanges {
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    pluginPrefs = [NSMutableDictionary dictionaryWithContentsOfFile:prefs];
    if ([[pluginPrefs objectForKey:bundleIdentifier] boolValue]) {
        [plugin disableStatusItem];
    } else if ([bundleIdentifier isEqualToString:@"com.apple.systemuiserver"]) {
        [plugin systemUIStatusItem];
    } else {
        [plugin enableStatusItem];
    }
}

-(void)systemUIStatusItem {
    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    NSPointerArray *statusItems = [statusBar valueForKey:@"_items"];
    for (int i = 0; i < statusItems.count; i++) {
        NSStatusItem *item = [statusItems pointerAtIndex:i];
        NSString *appName = [systemItems objectForKey:[NSNumber numberWithLong:[(NSWindow*)[item performSelector:@selector(_window)] windowNumber]]];
        if ([[pluginPrefs objectForKey:appName] boolValue]) {
            [item setVisible:false];
        } else {
            [item setVisible:true];
        }
    }
}

-(void)enableStatusItem {
    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    NSPointerArray *statusItems = [statusBar valueForKey:@"_items"];
    for (int i = 0; i < statusItems.count; i++) {
        NSStatusItem *item = [statusItems pointerAtIndex:i];
        [item setVisible:true];
    }
}

-(void)disableStatusItem {
    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    NSPointerArray *statusItems = [statusBar valueForKey:@"_items"];
    for (int i = 0; i < statusItems.count; i++) {
        NSStatusItem *item = [statusItems pointerAtIndex:i];
        [item setVisible:false];
    }
}

@end

@implementation wb_cmb_NSStatusItem

- (void)_install {
    // Make sure SystemUIServer items are checked when added to the statusbar
    ZKOrig(void);
    [plugin updateandApply];
}

- (BOOL)_allowItemDragging {
    // Allow for system items to be dragged
    return true;
}

@end
