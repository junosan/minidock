
// clang -framework AppKit -o screen_size screen_size.m

// Get the width & height of the main screen
// (= screen with the Menu Bar in System Preferences > Displays > Arrangement)

// Prints 
//     full_width visible_width full_height visible_height
// where the visible_$ is after subtracting the coordinate offset
// due to the Dock or the Menu Bar (if present on the main screen)

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#include <stdio.h>

int main(int argc, const char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    NSRect frame        = [[NSScreen mainScreen] frame];
    NSRect visibleFrame = [[NSScreen mainScreen] visibleFrame];
    
    printf("%d %d %d %d\n",
            (int)frame.size.width , (int)visibleFrame.size.width,
            (int)frame.size.height, (int)visibleFrame.size.height);

    [pool drain];
    return 0;
}
