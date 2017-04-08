#ifndef GEOLOCATION_H_
#define GEOLOCATION_H_

#include <curl/curl.h>

#include <mutex>
#include <string>

// NOTE: assumes only one instance is present
class Geolocation
{
public:
    Geolocation();
    
    void init(int poll_interval);
    std::string get_string();

    Geolocation           (const Geolocation&) = delete;
    Geolocation& operator=(const Geolocation&) = delete;
    Geolocation           (Geolocation&&) = delete;
    Geolocation& operator=(Geolocation&&) = delete;

    ~Geolocation();

private:
    CURL *curl;
    std::string csv;

    struct {
        std::mutex  mtx;
        std::string str;
    } loc;

    void poll(int poll_interval);
    static size_t curl_callback(void*, size_t, size_t, std::string*);
};

#endif /* GEOLOCATION_H_ */
