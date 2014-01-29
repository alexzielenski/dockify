//
//  DKInstaller.h
//  Dockify
//
//  Created by Alex Zielenski on 1/26/14.
//  Copyright (c) 2014 Alex Zielenski. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *const DKLoaderExecutableLabel;

@interface DKInstaller : NSObject

+ (BOOL)isInstalled;
+ (BOOL)install:(NSError **)error;
+ (BOOL)uninstall:(NSError **)error;

@end
