//
//  DKAppDelegate.m
//  Dockify
//
//  Created by Alex Zielenski on 1/26/14.
//  Copyright (c) 2014 Alex Zielenski. All rights reserved.
//

#import "DKAppDelegate.h"
#import "DKInstaller.h"

@interface DKAppDelegate ()
@property (nonatomic, retain) NSMutableDictionary *prefs;
- (void)savePrefs;
@end

@implementation DKAppDelegate

- (void)awakeFromNib {
    self.action.tag = [DKInstaller isInstalled];
    self.action.title = self.action.tag ? @"Uninstall" : @"Install";
}

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *contents = [manager contentsOfDirectoryAtPath:self.applicationSupport error:nil];
    
    // Loop through the file names in our directory and
    // accept all of the files with no extension or .
    NSMutableArray *names = [NSMutableArray array];
    for (NSString *title in contents) {
        if ([title pathExtension].length > 0 || [title hasPrefix:@"."])
            continue;
        names[names.count] = title;
    }
    
    
    self.themes = names.copy;
    self.prefs = [NSMutableDictionary dictionaryWithContentsOfFile:[self.applicationSupport stringByAppendingPathComponent:@"com.alexzielenski.dockify.plist"]];
    
    // If the selected theme is unavailable, set it to nil
    self.theme = self.prefs[@"theme"] ?: self.themes.firstObject;
    if (![self.themes containsObject:self.theme])
        self.theme = nil;
    
    self.enabled = [self.prefs[@"enabled"] boolValue];
}

- (void)savePrefs {
    [@{ @"theme": self.theme, @"enabled": @(self.isEnabled) } writeToFile:[self.applicationSupport stringByAppendingPathComponent:@"com.alexzielenski.dockify.plist"] atomically:NO];
    
    if ([DKInstaller isInstalled])
        system("killall Dock");
}

- (NSString *)applicationSupport {
    @synchronized(self) {
        static NSString *path = nil;
        if (!path) {
            NSFileManager *manager = [NSFileManager defaultManager];
            NSArray *appSupportDirs = [manager URLsForDirectory: NSApplicationSupportDirectory inDomains: NSUserDomainMask];
            NSString *appSupport = [[appSupportDirs[0] path] stringByAppendingPathComponent: @"Dockify"];
            
            path = appSupport.copy;
        }
        return  path;
    }
}

- (IBAction)action:(NSButton *)sender {
    NSError *error;

    if ([DKInstaller isInstalled]) {
        if ([DKInstaller uninstall:&error] == NO && error) {
            NSLog(@"Couldn't install Dockify (domain: %@ code: %@)", error.domain, [NSNumber numberWithInteger:error.code]);
            NSAlert *alert = [NSAlert alertWithError:error];
            [alert runModal];
            [NSApp terminate:self];
        }
    } else {
        // Install helper tools
        if ([DKInstaller install:&error] == NO && error) {
            
            NSLog(@"Couldn't install Dockify (domain: %@ code: %@)", error.domain, [NSNumber numberWithInteger:error.code]);
            NSAlert *alert = [NSAlert alertWithError:error];
            [alert runModal];
            [NSApp terminate:self];
        }
        
        [[NSFileManager defaultManager] createDirectoryAtPath:self.applicationSupport
                                  withIntermediateDirectories:NO
                                                   attributes:nil
                                                        error:nil];
    }
    
    if (!error) {
        system("killall Dock");
    }
    
    sender.tag = [DKInstaller isInstalled];
    sender.title = sender.tag ? @"Uninstall" : @"Install";
}

- (IBAction)about:(id)sender {
    self.aboutView.mainFrameURL = [[[NSBundle mainBundle] URLForResource:@"Credits" withExtension:@"html"] absoluteString];
    self.aboutView.policyDelegate = self;
    [self.aboutView.window makeKeyAndOrderFront:self];
}

- (void)webView:(WebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id < WebPolicyDecisionListener >)listener
{
    NSString *host = [[request URL] host];
    if (host) {
        [[NSWorkspace sharedWorkspace] openURL:[request URL]];
    } else {
        [listener use];
    }
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    [self savePrefs];
}

@end
