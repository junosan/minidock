#ifndef APPLE_API_H_
#define APPLE_API_H_

#include <string>
#include <tuple>

namespace apple_api
{
    // method for moving window adapted from http://github.com/junosan/tile
    // 
    // NOTE: Although it is possible to achive this in a much simpler way if in
    //       a single display environment (fetch the screen dimensions using 
    //       [NSScreen mainScreen] and move the window from within the terminal
    //       using "\033[3;" pos_x ";" pos_y "t"), this approach becomes
    //       troublesome if multiple displays are involved because the origin 
    //       for setting the position of the iTerm2 window becomes
    //       indeterminate (may be the left or right display depending on where
    //       iTerm2 was originally opened and whether the display was unplugged
    //       or not, etc.)
    //       Instead, here we directly find the rightmost display and place
    //       the iTerm2 window using Accessibility API

    struct Bounds { int x, y, w, h; };
    struct Window {
        Bounds bounds;
        int pid;
        std::string title;
    };

    extern bool enable_accessibility_api();
    extern std::tuple<Bounds, Window> get_screen_iterm2_dims();
    extern bool apply_bounds(const Window &window, Bounds bounds);
}

#endif /* SIMPLE_POLLS_H_ */
