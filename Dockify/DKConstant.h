//
//  DKConstant.h
//  Dockify
//
//  Created by Alex Zielenski on 1/26/14.
//  Copyright (c) 2014 Alex Zielenski. All rights reserved.
//

FOUNDATION_EXPORT NSString *const DKInstalledVersionKey;
FOUNDATION_EXPORT NSString *const DKErrorDomain;
enum {
    DKErrPermissionDenied  = 0,
    DKErrInstallHelperTool = 1,
    DKErrRemoveHelperTool  = 2,
    DKErrInjection         = 3
};

FOUNDATION_EXPORT NSString *const DKErrPermissionDeniedDescription;
FOUNDATION_EXPORT NSString *const DKErrInstallDescription;
FOUNDATION_EXPORT NSString *const DKErrRemoveDescription;
FOUNDATION_EXPORT NSString *const DKErrInjectionDescription;