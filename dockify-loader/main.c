//
//  main.m
//  dockify-loader
//
//  Created by Alex Zielenski on 1/26/14.
//  Copyright (c) 2014 Alex Zielenski. All rights reserved.
//

#include <xpc/xpc.h>
#include <syslog.h>
#include "inject.h"

dispatch_source_t g_timer_source = NULL;

static void __XPC_Peer_Event_Handler(xpc_connection_t connection, xpc_object_t event) {
    syslog(LOG_NOTICE, "Received event in helper.");
    
	xpc_type_t type = xpc_get_type(event);
    
	if (type == XPC_TYPE_ERROR) {
		if (event == XPC_ERROR_CONNECTION_INVALID) {
			// The client process on the other end of the connection has either
			// crashed or cancelled the connection. After receiving this error,
			// the connection is in an invalid state, and you do not need to
			// call xpc_connection_cancel(). Just tear down any associated state
			// here.
            
		} else if (event == XPC_ERROR_TERMINATION_IMMINENT) {
			// Handle per-connection termination cleanup.
		}
        
	} else {
        xpc_connection_t remote = xpc_dictionary_get_remote_connection(event);
        
        pid_t pid = (pid_t)xpc_dictionary_get_int64(event, "pid");
        const char *payload = xpc_dictionary_get_string(event, "payload");
        
        kern_return_t rtn = inject(pid, payload);
        
        if (rtn == 0) {
            syslog(LOG_NOTICE, "Injection Succeeded");
        } else {
            syslog(LOG_ERR, "Injection Failed");
        }
        
        xpc_object_t reply = xpc_dictionary_create_reply(event);
        xpc_dictionary_set_string(reply, "reply", "Hi there, host application!");
        xpc_connection_send_message(remote, reply);
        xpc_release(reply);
	}
}


static void __XPC_Connection_Handler(xpc_connection_t connection)  {
    syslog(LOG_NOTICE, "Configuring message event handler for helper.");
    
	xpc_connection_set_event_handler(connection, ^(xpc_object_t event) {
        // Disarm timer while injecting
        dispatch_source_set_timer(g_timer_source, DISPATCH_TIME_FOREVER, 0llu, 0llu);
        
        // handle event
		__XPC_Peer_Event_Handler(connection, event);
        
        // Rearm timer
        dispatch_time_t t0 = dispatch_time(DISPATCH_TIME_NOW, 5llu * NSEC_PER_SEC);
        dispatch_source_set_timer(g_timer_source, t0, 0llu, 0llu);
	});
	
	xpc_connection_resume(connection);
}


int main(int argc, const char * argv[]) {
    // Init idle-exit timer
    dispatch_queue_t mq = dispatch_get_main_queue();
    g_timer_source = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, mq); 
    
    /* When the idle-exit timer fires, we just call exit(2) with status 0. */
    dispatch_set_context(g_timer_source, NULL);
    dispatch_source_set_event_handler_f(g_timer_source, (void (*)(void *))exit);
    /* We start off with our timer armed. This is for the simple reason that,
     * upon kicking off the GCD state engine, the first thing we'll get to is
     * a connection on our socket which will disarm the timer. Remember, handling
     * new connections and the firing of the idle-exit timer are synchronized.
     */
    dispatch_time_t t0 = dispatch_time(DISPATCH_TIME_NOW, 5llu * NSEC_PER_SEC);
    dispatch_source_set_timer(g_timer_source, t0, 0llu, 0llu);
    dispatch_resume(g_timer_source);
    
    xpc_connection_t service = xpc_connection_create_mach_service("com.alexzielenski.dockify.mach",
                                                                  dispatch_get_main_queue(),
                                                                  XPC_CONNECTION_MACH_SERVICE_LISTENER);
    
    if (!service) {
        syslog(LOG_NOTICE, "Failed to create service.");
        exit(EXIT_FAILURE);
    }
    
    syslog(LOG_NOTICE, "Configuring connection event handler for helper");
    xpc_connection_set_event_handler(service, ^(xpc_object_t connection) {
        __XPC_Connection_Handler(connection);
    });
    
    xpc_connection_resume(service);
    
    dispatch_main();
    
    xpc_release(service);
    
    return EXIT_SUCCESS;
}

