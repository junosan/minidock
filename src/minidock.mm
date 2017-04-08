
#include "Config.h"
#include "simple_polls.h"
#include "Geolocation.h"
#include "AppList.h"

#include <Foundation/Foundation.h>
#include <Carbon/Carbon.h>

#include <cstdlib>
#include <string>
#include <iostream>
#include <thread>

struct info_t {
    Geolocation geoloc;
    AppList applist;

    bool input_enable;
    bool audio_enable;
    bool geoloc_enable;
    std::string geoloc_ignore;
    bool applist_enable;
    bool pos_y_middle;

    int width_unit;
    int width_edge;
    int height_unit;
    int height_edge;

    // for determining visual refresh
    bool repeat_refresh = false;
    int n_row_prev = 0;
    // int pos_x_prev = 0;
    // int pos_y_prev = 0;
    std::string upper_prev;
    AppList::apps_t apps_prev = AppList::apps_t{{}, -1};
};

void timer_callback(CFRunLoopTimerRef timer, void *info)
{
    auto &inf = *(info_t*)info;

    std::string out;

    /* geolocation */
    std::string geoloc_str;
    bool show_geoloc(false);
    if (inf.geoloc_enable == true)
    {
        geoloc_str = inf.geoloc.get_string();
        if (inf.geoloc_ignore != geoloc_str.substr(0, 2))
            show_geoloc = true;
    } 

    /* app list */
    auto apps = (inf.applist_enable == true ? inf.applist.get_apps()
                                            : inf.apps_prev);
    bool refresh = (apps != inf.apps_prev);
    inf.apps_prev = apps;

    /* window manipulation */
    int n_row = 2 // hour, minute
                + static_cast<int>(inf.input_enable)
                + static_cast<int>(inf.audio_enable)
                + static_cast<int>(show_geoloc)
                + static_cast<int>(inf.applist_enable) // "──  "
                + apps.first.size();
    
    // prevent content shifting by pre-/post-scrolling
    if (n_row > inf.n_row_prev)
        out += "\033[" + std::to_string(n_row - inf.n_row_prev) + "S";
    if (n_row != inf.n_row_prev)
        out += "\033[8;" + std::to_string(n_row) + ";20t"; // resize
    if (n_row < inf.n_row_prev)
        out += "\033[" + std::to_string(inf.n_row_prev - n_row) + "T";
    inf.n_row_prev = n_row;

    // (effective width, full height, height offset)
    auto dims = simple_polls::get_screen_dims();

    // two columns + edges
    int pos_x = std::get<0>(dims) - 2 * (inf.width_unit + inf.width_edge);
    // n_row rows + edges (middle) or 0 (top)
    int pos_y = (inf.pos_y_middle == false ? 0 :
        (std::get<1>(dims) -
            (n_row * inf.height_unit + 2 * inf.height_edge)) / 2
        - std::get<2>(dims));

    // if (pos_y != inf.pos_y_prev || pos_x != inf.pos_x_prev)
    out += "\033[3;" + std::to_string(pos_x) + ";"
                     + std::to_string(pos_y) + "t";
    // inf.pos_x_prev = pos_x;
    // inf.pos_y_prev = pos_y;

    /* visible content */
    out += "\033[H";         // cursor at top left corner
    out += "\033[38;5;251m"; // Grey78 c6c6c6

    out += simple_polls::get_time_string();
    
    if (inf.input_enable == true)
        out += "\n" + simple_polls::get_input_string();
    
    if (inf.audio_enable == true)
        out += "\n" + simple_polls::get_audio_string();
    
    if (show_geoloc == true)
        out += "\n" + inf.geoloc.get_string();

    if (inf.applist_enable == true)
        out += "\n──  ";

    refresh = refresh || (out != inf.upper_prev);
    inf.upper_prev = out;

    if (refresh == true || inf.repeat_refresh == true)
    {
        // when refreshing, refresh twice 
        // reason: due to an unknown iTerm2 (?) bug, the last line doesn't 
        //         update properly when refreshing only once
        inf.repeat_refresh = refresh;

        if (apps.first.size() > 0)
            out += '\n' + inf.applist.get_string(apps);

        // force cursor to left even when command prompt is present
        auto last_nl = out.find_last_of('\n');
        if (std::string::npos != last_nl)
            out.insert(last_nl + 1, "\033[" + std::to_string(n_row) + "H");

        std::cout << out;
    }
}

int main(int argc, const char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    auto clean_exit = [&pool](int exit_code) {
        [pool drain];
        return exit_code;
    };

    info_t info;

    /* fill info from config file */
    Config config;
    std::string rc(std::string(std::getenv("HOME")) + "/.minidockrc");

    if (false == config.set_file(rc))
    {
        std::cerr << "Cannot access " << rc << '\n';
        return clean_exit(1);
    }

    info.input_enable      = config.get_bool("input_enable", true);
    info.audio_enable      = config.get_bool("audio_enable", true);
    info.geoloc_enable     = config.get_bool("geoloc_enable", true);
    info.geoloc_ignore     = config.get_str ("geoloc_ignore", "kr");
    info.applist_enable    = config.get_bool("applist_enable", true);
    bool applist_use_icons = config.get_bool("applist_use_icons", false);
    info.pos_y_middle      = config.get_bool("pos_y_middle", true);
    info.width_unit        = config.get_int ("width_unit", 8);
    info.width_edge        = config.get_int ("width_edge", 5);
    info.height_unit       = config.get_int ("height_unit", 17);
    info.height_edge       = config.get_int ("height_edge", 3);
    int poll_interval      = config.get_int ("poll_interval", 300);

    if (info.width_unit  < 0 || info.width_edge  < 0 ||
        info.height_unit < 0 || info.height_edge < 0 )
    {
        std::cerr << "Invalid settings in " << rc << '\n';
        return clean_exit(1);
    }

    if (info.geoloc_enable == true)
        info.geoloc.init(poll_interval);

    if (info.applist_enable == true)
    {
        std::string arg0(argv[0]);
        info.applist.init(applist_use_icons == true ? AppList::mode::icon
                                                    : AppList::mode::text,
                          arg0.substr(0, arg0.find_last_of('/')));
    }

    /* setup timer and run */
    CFRunLoopTimerContext context;
    context.info = &info; // this pointer is passed to callback

    // following 4 are ignored
    context.version = 0;
    context.retain = NULL;
    context.release = NULL;
    context.copyDescription = NULL;

    CFRunLoopTimerRef timer = CFRunLoopTimerCreate(
        NULL,
        CFAbsoluteTimeGetCurrent() + poll_interval / 1000.0, // start [ms]
        poll_interval / 1000.0, // interval [ms]
        0, // ignored
        0, // ignored
        timer_callback,
        &context);

    CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, kCFRunLoopCommonModes);

    CFRunLoopRun();

    CFRelease(timer);

    return clean_exit(0);
}
