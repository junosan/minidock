#ifndef SIMPLE_POLLS_H_
#define SIMPLE_POLLS_H_

#include <string>
#include <tuple>

namespace simple_polls
{
    extern std::string get_time_string();
    extern std::string get_input_string();
    extern std::string get_audio_string();

    // (effective width, full height, height offset)
    extern std::tuple<int, int, int> get_screen_dims();
}

#endif /* SIMPLE_POLLS_H_ */
