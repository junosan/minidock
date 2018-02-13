#include "AppList.h"

#include "base64.h"

#include <algorithm>
#include <fstream>
#include <vector>

// replace with <filesystem> once c++17 rolls out
#include <dirent.h>

void AppList::init(enum mode mode, const std::string &bin_path)
{    
    if (mode == mode::text)
    {
        #define COLOR(code) "\033[38;5;" #code "m"
        map = std::vector<item_t> {
            {"Activity Monitor",         COLOR( 16) "A" COLOR( 28) "c"},
            {"App Store",                COLOR( 27) "A" COLOR( 33) "p"},
            {"Calculator",               COLOR(249) "C" COLOR(208) "l"},
            {"Calendar",                 COLOR(203) "C" COLOR(251) "d"},
            {"Code",                     COLOR( 27) "C" COLOR(251) "d"},
            {"Contacts",                 COLOR(130) "Cn"              },
            {"Dictionary",               COLOR(124) "Dc"              },
            {"Finder",                   COLOR( 75) "F" COLOR(251) "i"},
            {"Firefox",                  COLOR(202) "F" COLOR( 33) "f"},
            {"Illustrator",              COLOR( 94) "I" COLOR(214) "l"},
            {"MATLAB",                   COLOR( 24) "M" COLOR(160) "t"},
            {"Mail",                     COLOR( 27) "M" COLOR(245) "a"},
            {"Maps",                     COLOR(144) "Mp"              },
            {"Messages",                 COLOR( 75) "M" COLOR(251) "s"},
            {"Microsoft Excel",          COLOR( 28) "Ex"              },
            {"Microsoft PowerPoint",     COLOR(160) "Pw"              },
            {"Microsoft Remote Desktop", COLOR(160) "Rm"              },
            {"Microsoft Word",           COLOR( 27) "Wd"              },
            {"Notes",                    COLOR(214) "N" COLOR(251) "t"},
            {"OmniGraffle",              COLOR( 34) "O" COLOR(240) "m"},
            {"Photos",                   COLOR(202) "P" COLOR(106) "h"},
            {"Photoshop",                COLOR( 18) "P" COLOR( 33) "s"},
            {"Preview",                  COLOR( 69) "Pv"              },
            {"Reminders",                COLOR(208) "R" COLOR(251) "m"},
            {"Safari",                   COLOR( 75) "S" COLOR(203) "f"},
            {"Signal",                   COLOR( 75) "S" COLOR(251) "n"},
            {"Skype",                    COLOR( 75) "S" COLOR(251) "k"},
            {"System Preferences",       COLOR(240) "S" COLOR(251) "y"},
            {"TeXShop",                  COLOR(109) "T" COLOR(251) "x"},
            {"Telegram",                 COLOR( 75) "T" COLOR(251) "g"},
            {"Terminal",                 COLOR( 16) "Tm"              },
            {"TextEdit",                 COLOR(251) "E" COLOR(240) "d"},
            {"TextWrangler",             COLOR(214) "T" COLOR( 75) "W"},
            {"Transmission",             COLOR(160) "T" COLOR(245) "r"},
            {"VLC",                      COLOR(208) "V" COLOR(251) "L"},
            {"VirtualBox",               COLOR( 18) "V" COLOR( 33) "B"},
            {"VirtualBox VM",            COLOR( 18) "V" COLOR( 33) "M"},
            {"iTerm2",                   COLOR( 16) "i" COLOR( 28) "T"},
            {"iTunes",                   COLOR(205) "i" COLOR(135) "T"}
        };
        #undef COLOR
    }
    
    if (mode == mode::icon)
    {
        const std::string path(bin_path + "/../icons/");
        const std::string ext(".png");
        const auto ext_len = ext.size();
        
        DIR *dir = opendir(path.c_str());
        if (dir != nullptr)
        {
            struct dirent *entry;
            while ((entry = readdir(dir)) != nullptr)
            {
                std::string name(entry->d_name);
                const auto name_len = name.size();
                if (name_len > ext_len &&
                    0 == name.compare(name_len - ext_len, ext_len, ext))
                {
                    std::string filename(path + name);
                    std::ifstream ifs(filename, std::ios::binary);
                    if (ifs.is_open() == false) continue;
                    
                    ifs.seekg(0, std::ios::end);
                    auto size = static_cast<std::size_t>(ifs.tellg());
                    if (size == 0) continue;
                    ifs.seekg(0, std::ios::beg);

                    std::vector<char> vec;
                    vec.resize(size);
                    ifs.read(vec.data(), size);

                    // iTerm2 image display format
                    std::string rep = "\033]1337;File=name=";
                    rep += base64::encode(filename);
                    rep += ";inline=1;height=1;width=2;"
                           "preserveAspectRatio=true:";
                    rep += base64::encode(vec);
                    rep += "\a";
                    rep += "\033[D"; // move cursor left once
                                     // (may be version/environment dependent)
                    
                    map.emplace_back(name.substr(0, name_len - ext_len),
                                     std::move(rep));
                }
            }

            closedir(dir);
        }
    }

    std::sort(std::begin(map), std::end(map), comp);
    // assuming sorted map hereafter; do not alter map below
}

std::string AppList::get_string(const std::vector<std::string> &apps)
{
    std::string ret;
    
    for (auto i = 0ul, e = apps.size(); i < e; ++i)
    {
        const auto val = std::make_pair(apps[i], std::string{});

        const auto it =
                  std::lower_bound(std::begin(map), std::end(map), val, comp);
        if (it != std::upper_bound(std::begin(map), std::end(map), val, comp))
            ret += it->second;
        else
            ret += "\033[38;5;251m" + apps[i].substr(0, 2);

        ret += "  ";
        
        if (i < e - 1) // cannot enter loop with e == 0
            ret += '\n';
    }

    return ret;
}
