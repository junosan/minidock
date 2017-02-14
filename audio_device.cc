
// clang++ -framework CoreAudio -std=c++11 -o audio_device audio_device.cc

// Print the first letter of the device name and 
// the volume represented as one character (- mute, 0~9, | full)

// Consulted
//   https://github.com/deweller/switchaudio-osx
//   https://developer.apple.com/library/content/technotes/tn2223/_index.html
//   https://github.com/hydrogen-music/hydrogen/blob/master
//          /src/core/src/IO/coreaudio_driver.cpp
//   http://stackoverflow.com/questions/8950727

#include <CoreAudio/CoreAudio.h>
#include <cstdio>
#include <cmath>

int main(int argc, char *argv[])
{
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
        return 1;

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
        return 1;

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

    printf("%c%c", device_name[0], vol);

    return 0;
}
