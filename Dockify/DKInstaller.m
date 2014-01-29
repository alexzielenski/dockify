//
//  DKInstaller.m
//  Dockify
//
//  Created by Alex Zielenski on 1/26/14.
//  Copyright (c) 2014 Alex Zielenski. All rights reserved.
//

#import <ServiceManagement/ServiceManagement.h>
#import "DKInstaller.h"

NSString *const DKLoaderExecutableLabel = @"com.alexzielenski.dockify.loader";

@interface DKInstaller ()
+ (BOOL)askPermission:(AuthorizationRef *)authRef toRemove:(BOOL)willRemove error:(NSError **)error;
+ (BOOL)installHelperTool:(NSString *)executableLabel authorizationRef:(AuthorizationRef)authRef error:(NSError **)error;
+ (BOOL)removeHelperTool:(NSString *)executableLabel authorizationRef:(AuthorizationRef)authRef error:(NSError **)error;
@end

@implementation DKInstaller

+ (BOOL)isInstalled {
    NSString *versionInstalled = [[NSUserDefaults standardUserDefaults] stringForKey:DKInstalledVersionKey];
    NSString *currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    NSDictionary *dict = CFBridgingRelease(SMJobCopyDictionary(kSMDomainUserLaunchd, (CFStringRef)@"com.alexzielenski.dockify-listener"));
    return ([currentVersion compare:versionInstalled] == NSOrderedSame && dict);
}

+ (BOOL)install:(NSError **)error {
    AuthorizationRef authRef = NULL;
    BOOL result = YES;
    
    result = [self askPermission:&authRef toRemove:NO error:error];
    
    if (result == YES) {
        result = [self installHelperTool:DKLoaderExecutableLabel authorizationRef:authRef error:error];
    }
    
    if (result == YES) {
        result = (BOOL)SMLoginItemSetEnabled((CFStringRef)@"com.alexzielenski.dockify-listener", true);
    }

    if (result == YES) {
        NSString *currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        [[NSUserDefaults standardUserDefaults] setObject:currentVersion forKey:DKInstalledVersionKey];
        
        NSLog(@"Installed v%@", currentVersion);
    }
    
    return result;
}

+ (BOOL)uninstall:(NSError **)error {
    AuthorizationRef authRef = NULL;
    BOOL result = YES;
    
    result = [self askPermission:&authRef toRemove:YES error:error];
    
    if (result == YES) {
        result = [self removeHelperTool:DKLoaderExecutableLabel authorizationRef:authRef error:error];
    }
    
    if (result == YES) {
        result = (BOOL)SMLoginItemSetEnabled((CFStringRef)@"com.alexzielenski.dockify-listener", false);
    }
    
    if (result == YES) {
        NSNumber *currentVersion = [[NSUserDefaults standardUserDefaults] objectForKey:DKInstalledVersionKey];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:DKInstalledVersionKey];
        
        NSLog(@"Removed v%@", currentVersion);
    }
        
    return result;
}

+ (BOOL)askPermission:(AuthorizationRef *)authRef toRemove:(BOOL)willRemove error:(NSError **)error {
    // Creating auth item to bless helper tool and install framework

    AuthorizationItem authItem = {kSMRightBlessPrivilegedHelper, 0, NULL, 0};
    AuthorizationItem modify   = {kSMRightModifySystemDaemons, 0, NULL, 0};
    
    AuthorizationItem items[2] = { authItem, modify };
    
    // Creating a set of authorization rights
	AuthorizationRights authRights = {2, items};
    
    // Specifying authorization options for authorization
	AuthorizationFlags flags = kAuthorizationFlagDefaults | kAuthorizationFlagInteractionAllowed | kAuthorizationFlagExtendRights;
    
    // Open dialog and prompt user for password
	OSStatus status = AuthorizationCreate(&authRights, kAuthorizationEmptyEnvironment, flags, authRef);
    
    if (status == errAuthorizationSuccess) {
        return YES;
    } else {
        NSLog(@"%@ (error code: %@)", DKErrPermissionDeniedDescription, [NSNumber numberWithInt:status]);
        
        *error = [[NSError alloc] initWithDomain:DKErrorDomain
                                            code:DKErrPermissionDenied
                                        userInfo:@{NSLocalizedDescriptionKey: DKErrPermissionDeniedDescription}];
        
        return NO;
    }
}

+ (BOOL)installHelperTool:(NSString *)executableLabel authorizationRef:(AuthorizationRef)authRef error:(NSError **)error {
    CFErrorRef blessError = NULL;
    BOOL result;
    
    result = SMJobBless(kSMDomainSystemLaunchd, (__bridge CFStringRef)executableLabel, authRef, &blessError);
    
    if (result == NO) {
        CFIndex errorCode = CFErrorGetCode(blessError);
        CFStringRef errorDomain = CFErrorGetDomain(blessError);
        
        NSLog(@"an error occurred while installing %@ (domain: %@ (%@))", executableLabel, errorDomain, [NSNumber numberWithLong:errorCode]);
        
        *error = [[NSError alloc] initWithDomain:DKErrorDomain
                                            code:DKErrInstallHelperTool
                                        userInfo:@{NSLocalizedDescriptionKey: DKErrInstallDescription}];
    } else {
        NSLog(@"Installed %@ successfully", executableLabel);
    }
    
    return result;
}

+ (BOOL)removeHelperTool:(NSString *)executableLabel authorizationRef:(AuthorizationRef)authRef error:(NSError **)error {
    CFErrorRef blessError = NULL;
    BOOL result;
    
    result = SMJobRemove(kSMDomainSystemLaunchd, (__bridge CFStringRef)executableLabel, authRef, true, &blessError);
    
    if (result != NO) {
        // Use SMJobSubmit to remove leftover files
        // /Library/LaunchDaemons/com.alexzielenski.dockify.loader.plist
        // /Library/PrivilegedHelperTools/com.alexzielenski.dockify.loader
        NSDictionary *job = @{ @"Label": @"com.alexzielenski.dockify.cleanup",
                               @"RunAtLoad": @YES,
                               @"ProgramArguments": @[ @"/bin/rm", @"/Library/LaunchDaemons/com.alexzielenski.dockify.loader.plist", @"/Library/PrivilegedHelperTools/com.alexzielenski.dockify.loader" ] };
        SMJobSubmit(kSMDomainSystemLaunchd, (__bridge CFDictionaryRef)job, authRef, &blessError);
        SMJobRemove(kSMDomainSystemLaunchd, (CFStringRef)@"com.alexzielenski.dockify.cleanup", authRef, true, NULL);
    }
    
    if (result == NO) {
        CFIndex errorCode = CFErrorGetCode(blessError);
        CFStringRef errorDomain = CFErrorGetDomain(blessError);
        
        NSLog(@"an error occurred while uninstalling %@ (domain: %@ (%@))", executableLabel, errorDomain, [NSNumber numberWithLong:errorCode]);
        
        *error = [[NSError alloc] initWithDomain:DKErrorDomain
                                            code:DKErrRemoveHelperTool
                                        userInfo:@{NSLocalizedDescriptionKey: DKErrRemoveDescription}];
    } else {
        NSLog(@"Uninstalled %@ successfully", executableLabel);
    }
    
    return result;
}

@end
