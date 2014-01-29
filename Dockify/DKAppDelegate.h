//
//  DKAppDelegate.h
//  Dockify
//
//  Created by Alex Zielenski on 1/26/14.
//  Copyright (c) 2014 Alex Zielenski. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface DKAppDelegate : NSObject <NSApplicationDelegate, NSMenuDelegate>
@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSButton *action;
@property (assign) IBOutlet WebView *aboutView;

@property (copy) NSString *theme;
@property (assign, getter = isEnabled) BOOL enabled;
@property (nonatomic, retain) NSArray *themes;

- (NSString *)applicationSupport;
- (IBAction)action:(NSButton *)sender;
- (IBAction)about:(id)sender;
@end
