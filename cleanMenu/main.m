//
//  main.m
//  cleanMenu
//
//  Created by Wolfgang Baird on 3/12/17.
//  Copyright © 2017 Kevin M Beaulieu. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"

int main(int argc, const char * argv[]) {
    AppDelegate * delegate = [[AppDelegate alloc] init];
    [[NSApplication sharedApplication] setDelegate:delegate];
    [NSApp run];
    return EXIT_SUCCESS;
    //    return NSApplicationMain(argc, argv);
}
