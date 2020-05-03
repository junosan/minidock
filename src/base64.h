#ifndef BASE64_H_
#define BASE64_H_

#include <string>

namespace base64
{

template <class Container>
std::string encode(Container &in)
{
    // Assumes STL random access dynamic container (string, vector, etc.)
    // For efficiency, temporarily alters "in" but restores it afterwards
    
    // See https://en.wikipedia.org/wiki/Base64
    constexpr static char b64[] = 
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/" 
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    static_assert(sizeof(typename Container::value_type) == 1, "");

    auto pad = (3 - (in.size() % 3)) % 3;
    for (auto i = 0; i < pad; ++i)
        in.push_back(static_cast<typename Container::value_type>(0));
    
    std::string ret;
    ret.resize(in.size() * 4 / 3);
    auto out(&ret.front()); // undefined behavior if empty, but has no effect

    auto it(reinterpret_cast<unsigned char*>(&in.front()));
    auto end(it + in.size());
    while (it < end)
    {   // need re-casts due to integer promotion
        *out++ = b64[static_cast<unsigned char>(it[0] >> 2             )];
        *out++ = b64[static_cast<unsigned char>(it[0] << 4 | it[1] >> 4)];
        *out++ = b64[static_cast<unsigned char>(it[1] << 2 | it[2] >> 6)];
        *out++ = b64[static_cast<unsigned char>(             it[2]     )];
        it += 3;
    }

    for (auto i = 1; i <= pad; ++i)
    {
        ret[ret.size() - i] = '=';
        in.pop_back();
    }

    return ret;
}

}

#endif /* BASE64_H_ */
