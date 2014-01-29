#include <unistd.h>
#include <mach/kern_return.h>

// This code is by comex, lifted from https://github.com/comex/inject_and_interpose with a mod on one line
// I just don't feel like adding a submodule

kern_return_t inject(pid_t pid, const char *path);

// The behavior is synchronous: when it returns, constructors have
// already been called.

// Bugs: Will fail, crash the target process, or even crash this process if the target task is weird.
