#include "Config.h"

#include <fstream>
#include <vector>
#include <string>

bool Config::set_file(CSR filename)
{
    std::ofstream ofs(filename, std::ios::app);
    bool valid = ofs.is_open();
    if (valid == true)
        this->filename = filename;
    return valid;
}

Config::STR Config::get_str(CSR key, CSR def)
{
    STR ret;

    {
        std::ifstream ifs(filename);
        if (ifs.is_open() == true)
        {
            for (STR line; std::getline(ifs, line);)
            {
                auto space = line.find_first_of(" \t");
                if (space != std::string::npos &&
                    line.substr(0, space) == key)
                {
                    auto val = line.find_first_not_of(" \t", space);
                    if (val != std::string::npos)
                    {
                        ret = line.substr(val);
                        break;
                    }
                }
            }
        }
    }

    if (ret.empty() == true)
    {
        ret = def;
        set_value(key, ret);
    }

    return ret;
}

int Config::get_int(Config::CSR key, int def)
{
    int ret;
    
    try {
        ret = std::stoi(get_str(key, std::to_string(def)));
    } catch(...) {
        ret = def;
        set_value(key, std::to_string(def));
    }

    return ret;
}

bool Config::get_bool(Config::CSR key, bool def)
{
    return 0 != get_int(key, (int) def);
}

bool Config::set_value(CSR key, CSR value)
{
    std::vector<std::pair<STR, STR>> map;

    // read all
    {
        std::ifstream ifs(filename);
        if (ifs.is_open() == false)
            return false;
        for (STR line; std::getline(ifs, line);)
        {
            auto space = line.find_first_of(" \t");
            if (space == std::string::npos)
                continue;
            auto val = line.find_first_not_of(" \t", space);
            if (val != std::string::npos)
                map.emplace_back(line.substr(0, space),
                                    line.substr(val));
        }
    } // file closed

    // replace or add
    {
        auto it  = std::begin(map);
        auto end = std::end(map);
        for (; it != end; ++it)
        {
            if (it->first == key)
            {
                it->second = value;
                break;
            }
        }
        if (it == end)
            map.emplace_back(key, value);
    }

    // rewrite
    {
        std::ofstream ofs(filename, std::ios::trunc);
        if (ofs.is_open() == false)
            return false;
        for (const auto &pair : map)
            ofs << pair.first << ' ' << pair.second << '\n';
    } // file closed

    return true;
}
