
// clang -framework AppKit -o print_app print_app.m

// Print apps that would appear in the Dock
// prepended with a '*' for the currently focused one

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#include <stdio.h>

int main(int argc, const char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    unsigned int cnt = 0;
    for (NSRunningApplication *app in [[NSWorkspace sharedWorkspace] runningApplications])
    {
        if ([app activationPolicy] == NSApplicationActivationPolicyRegular)
        {
            if (cnt++ > 0)
                printf(";");

            if ([app ownsMenuBar])
                printf("*");

            printf("%s", [[app localizedName] UTF8String]);
        }
    }
    
    [pool drain];
    return 0;
}