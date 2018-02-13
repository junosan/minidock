#ifndef APPLIST_H_
#define APPLIST_H_

#include <vector>
#include <string>
#include <functional>

class AppList
{
public:
    enum class mode { text, icon };
    void init(mode mode, const std::string &bin_path);
    std::string get_string(const std::vector<std::string> &apps);

private:
    // (app name, representation)
    using item_t = std::pair<std::string, std::string>;
    std::vector<item_t> map;
    std::function<bool(const item_t&, const item_t&)> comp =
        [](const item_t &a, const item_t &b) { return a.first < b.first; };
};

#endif /* APPLIST_H_ */
