//
//  main.m
//  dockify-listener
//
//  Created by Alex Zielenski on 1/26/14.
//  Copyright (c) 2014 Alex Zielenski. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

static NSString *payload;

static OSStatus LaunchTerminationNotifierProxyCallbackFunction(
                                                               EventHandlerCallRef nextHandler,
                                                               EventRef anEvent,
                                                               void *userData) {
	ProcessSerialNumber psn;
    
    (void) GetEventParameter(
							 anEvent,
							 kEventParamProcessID,
							 typeProcessSerialNumber,
							 NULL,
							 sizeof(psn),
							 NULL,
							 &psn);
    
	NSDictionary *dict =  (NSDictionary*)ProcessInformationCopyDictionary(&psn, kProcessDictionaryIncludeAllInformationMask);
    if (![[dict[@"CFBundleIdentifier"] lowercaseString] isEqualToString:@"com.apple.dock"])
        return noErr;
    
	// Find the process to target
	pid_t pid = [[dict objectForKey:@"pid"] intValue];
	xpc_connection_t connection = xpc_connection_create_mach_service("com.alexzielenski.dockify.mach", NULL, XPC_CONNECTION_MACH_SERVICE_PRIVILEGED);
    xpc_connection_set_event_handler(connection, ^(xpc_object_t event) {
        xpc_type_t type = xpc_get_type(event);
        
        if (type == XPC_TYPE_ERROR) {
            
            if (event == XPC_ERROR_CONNECTION_INTERRUPTED) {
                NSLog(@"XPC connection interupted.");
                
            } else if (event == XPC_ERROR_CONNECTION_INVALID) {
                NSLog(@"XPC connection invalid, releasing.");
                xpc_release(connection);
                
            } else {
                NSLog(@"Unexpected XPC connection error.");
            }
            
        } else {
            NSLog(@"Unexpected XPC connection event.");
        }
    });
    
    xpc_connection_resume(connection);
    
    xpc_object_t message = xpc_dictionary_create(NULL, NULL, 0);
    xpc_dictionary_set_string(message, "payload", payload.fileSystemRepresentation);
    xpc_dictionary_set_int64(message, "pid", pid);
    
    
    xpc_connection_send_message_with_reply(connection, message, dispatch_get_main_queue(), ^(xpc_object_t event) {
        const char* response = xpc_dictionary_get_string(event, "reply");
        NSLog(@"Received response: %s.", response);
    });
    
    [dict release];
	return noErr;
    
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        payload = [[NSBundle mainBundle] pathForResource:@"dockify" ofType:@"dylib"];

        // inject already running apps
        
        // Insert code here to initialize your application
        EventHandlerUPP launchTerminateCallbackUPP = NewEventHandlerUPP(LaunchTerminationNotifierProxyCallbackFunction);
        
        EventTypeSpec eventsToListenFor [1];
        eventsToListenFor[0].eventClass = kEventClassApplication;
        eventsToListenFor[0].eventKind = kEventAppLaunched;
        OSStatus functionResult = InstallApplicationEventHandler(launchTerminateCallbackUPP,
                                                                 2,
                                                                 eventsToListenFor,NULL, NULL);
        
        // Done with UPP so dispose of it.
        DisposeEventHandlerUPP(launchTerminateCallbackUPP);
        
        if (functionResult != noErr) {
            NSLog(@"error");
        }
        
        system("killall Dock");
        
        [[NSRunLoop currentRunLoop] run];
    }
    return 0;
}
