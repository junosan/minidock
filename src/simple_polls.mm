#include "simple_polls.h"

#include <Carbon/Carbon.h>
#include <Foundation/Foundation.h>
#include <CoreAudio/CoreAudio.h>
#include <AppKit/AppKit.h>

#include <chrono>
#include <sstream>
#include <iomanip>
#include <array>
#include <cmath>

// NOTE: all lines should terminate with two spaces
namespace simple_polls
{

std::string get_time_string()
{
    auto now = std::chrono::system_clock::to_time_t(
        std::chrono::system_clock::now());
    std::stringstream ss;
    ss << std::put_time(std::localtime(&now), "%I  \n%M  ");
    return ss.str();
}

std::string get_input_string()
{
    constexpr static std::array<std::pair<const char*, const char*>, 14> map {{
        std::make_pair("US"        , "🇺🇸  "),
        std::make_pair("Korean"    , "🇰🇷  "),
        std::make_pair("Japanese"  , "🇯🇵  "),
        std::make_pair("British"   , "🇬🇧  "),
        std::make_pair("Canadian"  , "🇨🇦  "),
        std::make_pair("Australian", "🇦🇺  "),
        std::make_pair("SCIM"      , "🇨🇳  "),
        std::make_pair("TCIM"      , "🇹🇼  "),
        std::make_pair("Spanish"   , "🇪🇸  "),
        std::make_pair("Russian"   , "🇷🇺  "),
        std::make_pair("German"    , "🇩🇪  "),
        std::make_pair("Austrian"  , "🇦🇹  "),
        std::make_pair("French"    , "🇫🇷  "),
        std::make_pair("Italian"   , "🇮🇹  ")
    }};

    TISInputSourceRef source = TISCopyCurrentKeyboardInputSource();

    CFStringRef source_id = (CFStringRef)TISGetInputSourceProperty(
        source, 
        kTISPropertyInputSourceID);
    
    std::string input([(id)source_id UTF8String]);
    // CFRelease(source_id); // source_id is non-owning; causes segfault
    CFRelease(source);
    
    std::string ret("??  ");
    for (auto &name_flag : map)
    {
        if (std::string::npos != input.find(name_flag.first))
        {
            ret = name_flag.second;
            break;
        }
    }

    return ret;
}

std::string get_audio_string()
{
    std::string ret("??  ");
    OSStatus err; // default noErr;

    AudioDeviceID device_ID; // default kAudioDeviceUnknown;
    UInt32 ID_size(sizeof(device_ID));

    AudioObjectPropertyAddress address_ID = {
        kAudioHardwarePropertyDefaultOutputDevice,
        kAudioObjectPropertyScopeGlobal,
        kAudioObjectPropertyElementMaster
    };

    err = AudioObjectGetPropertyData(
        kAudioObjectSystemObject, &address_ID, 0, NULL, &ID_size, &device_ID);

    if (err != noErr)
        return ret;

    char device_name[256];
    UInt32 buf_size(sizeof(device_name));

    AudioObjectPropertyAddress address_name = {
        kAudioDevicePropertyDeviceName,
        kAudioObjectPropertyScopeGlobal,
        kAudioObjectPropertyElementMaster
    };

    err = AudioObjectGetPropertyData(
        device_ID, &address_name, 0, NULL, &buf_size, device_name);

    if (err != noErr)
        return ret;

    UInt32 n_channel(0);
    Float32 volume_sum(0.f);

    // 0 is the master channel which may or may not be present
    // if there is a master channel, only use the master volume
    // if not, use the average volume of channel 1 & 2
    for (UInt32 channel = UInt32(0); channel <= UInt32(2); ++channel)
    {
        AudioObjectPropertyAddress address_volume = {
            kAudioDevicePropertyVolumeScalar,
            kAudioDevicePropertyScopeOutput,
            channel
        };

        if (AudioObjectHasProperty(device_ID, &address_volume))
        {
            Float32 volume;
            UInt32 volume_size(sizeof(volume));

            err = AudioObjectGetPropertyData(
                device_ID, &address_volume, 0, NULL, &volume_size, &volume);
            
            if (err != noErr)
                break;
            
            volume_sum += volume;
            n_channel  += 1;

            if (channel == UInt32(0))
                break;
        }
        else
        {
            if (channel > UInt32(0))
                break;
        }
    }
    
    // 0 channel means no volume adjustment capability (always full volume)
    char vol = (n_channel > UInt32(0) ? '-' : '|');
    if (volume_sum > Float32(0.f))
    {
        int f = static_cast<int>(std::round(10. * volume_sum / n_channel));
        vol = (f < 10 ? '0' + static_cast<char>(f) : '|');
    }

    ret[0] = device_name[0];
    ret[1] = vol;

    return ret;
}

// (effective width, full height, height offset)
std::tuple<int, int, int> get_screen_dims()
{
    auto cf_string = static_cast<CFStringRef>(CFPreferencesCopyAppValue(
        CFSTR("orientation"), CFSTR("com.apple.dock")));

    std::string dock_orientation([(__bridge NSString*)cf_string UTF8String]);
    CFRelease(cf_string);

    auto cf_bool = static_cast<CFBooleanRef>(CFPreferencesCopyAppValue(
        CFSTR("_HIHideMenuBar"), CFSTR("NSGlobalDomain")));

    bool menubar_hidden = (cf_bool == kCFBooleanTrue);
    CFRelease(cf_bool);

    NSRect full = [[NSScreen mainScreen] frame];        // full dims
    NSRect comp = [[NSScreen mainScreen] visibleFrame]; // compensated dims

    return std::make_tuple(
        dock_orientation != "left" ? full.size.width
                                   : comp.size.width,
        full.size.height,
        menubar_hidden == false ? full.size.height - comp.size.height
                                : 0);
}

}
