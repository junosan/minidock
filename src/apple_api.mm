#include "apple_api.h"

#import <Carbon/Carbon.h>
#import <Cocoa/Cocoa.h>

#include <limits>

namespace apple_api
{

bool enable_accessibility_api()
{
    NSDictionary *options = @{(id)kAXTrustedCheckOptionPrompt: @YES};
    return AXIsProcessTrustedWithOptions((CFDictionaryRef)options);
}

std::tuple<Bounds, Window, std::vector<std::string>> 
    get_screen_iterm2_apps(bool get_apps)
{
    Bounds screen{std::numeric_limits<int>::lowest(), 0, 0, 0};
    Window iterm2{{0, 0, 0, 0}, 0, {}};
    std::vector<std::string> apps;

    NSArray *window_arr = (NSArray *)CGWindowListCopyWindowInfo(
        kCGWindowListOptionOnScreenOnly, kCGNullWindowID);

    for (NSDictionary *window in window_arr)
    {
        const char *str = [window[(id)kCGWindowOwnerName] UTF8String];
        std::string owner(str != nullptr ? str : "");
        
        str = [window[(id)kCGWindowName] UTF8String];
        std::string title(str != nullptr ? str : "");

        if (owner == "Dock" || owner == "Spotlight") continue;
        if (owner == "Finder" && title.empty() == true) continue;
        
        // Note: macOS 10.15 disabled kCGWindowName (returns blank)
        bool is_display = (owner == "Window Server"); //&& title == "Desktop");
        int pid = [window[(id)kCGWindowOwnerPID] intValue];

        if (is_display == false)
        {
            // skip Menu Bar and icons on it (they don't support AXUIElement)
            AXUIElementRef app = AXUIElementCreateApplication(pid);
            AXUIElementRef frontMostWindow;
            AXError err = AXUIElementCopyAttributeValue(
                app, kAXFocusedWindowAttribute, (CFTypeRef *)&frontMostWindow);
            CFRelease(app);
            
            if (err != kAXErrorSuccess) {
                continue;
            } else {
                CFRelease(frontMostWindow);
            }
            
            if (get_apps == true &&
                std::end(apps) == 
                    std::find(std::begin(apps), std::end(apps), owner) &&
                owner != "iTerm2") {
                apps.push_back(owner);
            }
        }

        CGRect rect;
        CGRectMakeWithDictionaryRepresentation(
            (CFDictionaryRef)window[(id)kCGWindowBounds], &rect);

        // Note: as a side effect of not being able to check the title,
        //       identifying the docked window as the rightmost one
        //       (this breaks with multiple screens)
        // && title == "minidock")
        if (owner == "iTerm2" && (int)rect.origin.x > iterm2.bounds.x)
        {
            iterm2 = Window{{(int)rect.origin.x, (int)rect.origin.y,
                             (int)rect.size.width, (int)rect.size.height},
                             pid, title};
        }

        // Note: as a side effect of not being able to check the title,
        //       need to filter non-screen elements using height
        if (is_display == true && rect.size.height > 100 && 
            rect.origin.x + rect.size.width > screen.x + screen.w)
        {            
            screen = Bounds({(int)rect.origin.x, (int)rect.origin.y,
                             (int)rect.size.width, (int)rect.size.height});
        }
    }

    if (window_arr.count > 0)
        CFRelease(window_arr);

    return std::make_tuple(screen, iterm2, apps);
}

bool apply_bounds(const Window &window, Bounds bounds)
{
    bool success(false);

    AXUIElementRef app = AXUIElementCreateApplication(window.pid);

    NSArray *window_arr;
    AXUIElementCopyAttributeValues( // 1024 is maximum # of elements
        app, kAXWindowsAttribute, 0, 1024, (CFArrayRef *) &window_arr);
    CFRelease(app);

    // find AXUIElement with matching origin, size, title 
    // (this is the only known way of getting Accessibility API's
    //  window objects from pid/kCGWindowNumber within the documented API)
    for (id element in window_arr)
    {
        AXUIElementRef w = (__bridge AXUIElementRef)element;
        AXValueRef v;

        CGPoint origin;
        AXUIElementCopyAttributeValue(w, kAXPositionAttribute, (CFTypeRef*)&v);
        AXValueGetValue(v, (AXValueType)kAXValueCGPointType, &origin);
        CFRelease(v);

        if ((int)origin.x != window.bounds.x ||
            (int)origin.y != window.bounds.y)
            continue;

        CGSize size;
        AXUIElementCopyAttributeValue(w, kAXSizeAttribute, (CFTypeRef*)&v);
        AXValueGetValue(v, (AXValueType)kAXValueCGSizeType, &size);
        CFRelease(v);

        if ((int)size.width  != window.bounds.w ||
            (int)size.height != window.bounds.h)
            continue;
        
        AXUIElementCopyAttributeValue(w, kAXTitleAttribute, (CFTypeRef*)&v);
        const char * title_c_str = [(__bridge NSString *)v UTF8String];
        std::string title(title_c_str != NULL ? title_c_str : "");
        CFRelease(v);

        // Note: macOS 10.15 no longer allows querying window titles
        // if (title != window.title)
        //     continue;

        if (window.bounds.x != bounds.x || window.bounds.y != bounds.y)
        {
            origin.x = (CGFloat)bounds.x;
            origin.y = (CGFloat)bounds.y;
            v = AXValueCreate((AXValueType)kAXValueCGPointType, &origin);
            AXUIElementSetAttributeValue(w, kAXPositionAttribute, v);
            CFRelease(v);
        }

        success = true;
        break;
    }

    if (window_arr.count > 0)
        CFRelease(window_arr);
    
    return success;
}

}
