
// clang -framework AppKit -o screen_width screen_width.m

// Get the width of the main screen
// (= screen with the Menu Bar in System Preferences > Displays > Arrangement)

// Prints 
//     full_width visible_width
// where the latter is after subtracting the coordinate offset
// due to the Dock (if present on the main screen)

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#include <stdio.h>

int main(int argc, const char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    NSRect frame        = [[NSScreen mainScreen] frame];
    NSRect visibleFrame = [[NSScreen mainScreen] visibleFrame];
    
    printf("%d %d\n", (int)frame.size.width, (int)visibleFrame.size.width);

    [pool drain];
    return 0;
}
