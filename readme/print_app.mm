#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>

#include <iostream>

int main(int argc, const char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    for (NSRunningApplication *app in
         [[NSWorkspace sharedWorkspace] runningApplications])
    {
        if ([app activationPolicy] == NSApplicationActivationPolicyRegular)
            std::cout << [[app localizedName] UTF8String] << '\n';
    }
    
    [pool drain];
    return 0;
}
