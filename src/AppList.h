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

    // (vec<app name>, focused app's index)
    using apps_t = std::pair<std::vector<std::string>, std::ptrdiff_t>;

    apps_t get_apps();
    std::string get_string(const apps_t &apps);

private:
    // (app name, representation)
    using item_t = std::pair<std::string, std::string>;
    std::vector<item_t> map;
    std::function<bool(const item_t&, const item_t&)> comp =
        [](const item_t &a, const item_t &b) { return a.first < b.first; };
};

#endif /* APPLIST_H_ */
