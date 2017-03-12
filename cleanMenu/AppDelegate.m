//
//  AppDelegate.m
//  cleanMenu
//
//  Created by Wolfgang Baird on 3/12/17.
//  Copyright © 2017 Kevin M Beaulieu. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
@property (strong, nonatomic) NSStatusItem *statusItem;
@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    NSStatusBar *sys = [NSStatusBar systemStatusBar];
    _statusItem = [sys statusItemWithLength:NSVariableStatusItemLength];
    _statusItem.highlightMode = YES;
    [_statusItem setImage:[NSImage imageNamed:@"icon"]];
    
    NSMenu *myMenu = [[NSMenu alloc] initWithTitle:@""];
    
    [[myMenu addItemWithTitle:@"About cleanMenu" action:@selector(showHelp:) keyEquivalent:@""] setTarget:self];
    [[myMenu addItemWithTitle:@"Check for updates..." action:@selector(toggleHidden:) keyEquivalent:@""] setTarget:self];
    [[myMenu addItemWithTitle:@"Start at Login" action:@selector(toggleHidden:) keyEquivalent:@""] setTarget:self];
    [myMenu addItem:[NSMenuItem separatorItem]];
    
    CFArrayRef windowList = CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements, kCGNullWindowID);
    NSArray *myArray=[(__bridge NSArray *)windowList copy];
    for (int i = 0; i < myArray.count; i++) {
        NSDictionary *winInfo = [myArray objectAtIndex:i];
        NSLog(@"%@", [winInfo objectForKey:@"kCGWindowLayer"]);

        if ([[winInfo objectForKey:@"kCGWindowLayer"] integerValue] == 25) {
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
            NSMenuItem *newItem = [[NSMenuItem alloc] initWithTitle:appName action:@selector(toggleHidden:) keyEquivalent:@""];
            [newItem setTarget:self];
            [myMenu addItem:newItem];
            NSLog(@"%@", [myArray objectAtIndex:i]);
        }
    }
    
    [myMenu addItem:[NSMenuItem separatorItem]];
    [[myMenu addItemWithTitle:@"Quit" action:@selector(toggleHidden:) keyEquivalent:@""] setTarget:self];
    
    [_statusItem setMenu:myMenu];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction)toggleHidden:(id)sender {
    CFNotificationCenterRef center = CFNotificationCenterGetDistributedCenter();
    CFDictionaryKeyCallBacks keyCallbacks = {0, NULL, NULL, CFCopyDescription, CFEqual, NULL};
    CFDictionaryValueCallBacks valueCallbacks  = {0, NULL, NULL, CFCopyDescription, CFEqual};
    CFMutableDictionaryRef dictionary = CFDictionaryCreateMutable(kCFAllocatorDefault, 1, &keyCallbacks, &valueCallbacks);
    NSString *s = [(NSMenuItem*)sender title];
    CFDictionaryAddValue(dictionary, CFSTR("bundleID"), (__bridge const void *)(s));
    CFNotificationCenterPostNotification(center, CFSTR("cleanMenu"), NULL, dictionary, TRUE);
    CFRelease(dictionary);
    [sender setState:![sender state]];
}

//- (void)sendNotification:(CFMutableDictionaryRef)dict {
//    CFNotificationCenterRef center = CFNotificationCenterGetDistributedCenter(); //CFNotificationCenterGetLocalCenter();
//    CFNotificationCenterPostNotification(center, CFSTR("wb_updateMenubar"), NULL, dict, TRUE);
//    CFRelease(dict);
//}

//CIImage* ciImage = [[CIImage alloc] initWithData:[yourImage TIFFRepresentation]];
//if ([yourImage isFlipped])
//{
//    CGRect cgRect    = [ciImage extent];
//    CGAffineTransform transform;
//    transform = CGAffineTransformMakeTranslation(0.0,cgRect.size.height);
//    transform = CGAffineTransformScale(transform, 1.0, -1.0);
//    ciImage   = [ciImage imageByApplyingTransform:transform];
//}
//CIFilter* filter = [CIFilter filterWithName:@"CIColorInvert"];
//[filter setDefaults];
//[filter setValue:ciImage forKey:@"inputImage"];
//CIImage* output = [filter valueForKey:@"outputImage"];
//[output drawAtPoint:NSZeroPoint fromRect:NSRectFromCGRect([output extent]) operation:NSCompositeSourceOver fraction:1.0];

@end
