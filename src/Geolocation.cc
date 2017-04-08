#include "Geolocation.h"

#include <thread>

Geolocation::Geolocation()
{
    loc.str = "nc  "; // no need to lock here
}

void Geolocation::init(int poll_interval)
{
    curl = curl_easy_init();

    if (curl != NULL)
    {
        curl_easy_setopt(curl, CURLOPT_URL, "freegeoip.net/csv/");
        curl_easy_setopt(curl, CURLOPT_TIMEOUT_MS, 3000L);
        // curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1L);
        curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0L); //only for https
        curl_easy_setopt(curl, CURLOPT_SSL_VERIFYHOST, 0L); //only for https
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, curl_callback);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, &csv);

        std::thread poller(&Geolocation::poll, this, poll_interval);
        poller.detach();
    }
}

Geolocation::~Geolocation()
{
    if (curl != NULL)
        curl_easy_cleanup(curl);
}

std::string Geolocation::get_string()
{
    std::string ret;
    {
        std::lock_guard<std::mutex> lock(loc.mtx);
        ret = loc.str;
    }
    return ret;
}

void Geolocation::poll(int poll_interval)
{
    if (curl == NULL)
        return;
    
    while (true)
    {
        csv.clear();
        bool success(false);

        if (CURLE_OK == curl_easy_perform(curl))
        {
            auto first = csv.find_first_of(',');
            if (first != std::string::npos)
            {
                std::lock_guard<std::mutex> lock(loc.mtx);

                loc.str = csv.substr(first + 1, 2) + "  ";
                std::transform(std::begin(loc.str), std::end(loc.str),
                               std::begin(loc.str), ::tolower);
                
                success = true;
            }
        }
        
        if (success == false)
        {
            std::lock_guard<std::mutex> lock(loc.mtx);
            loc.str = "nc  ";
        }

        // NOTE: freegeoip.net allows up to 15000 queries per hour
        std::this_thread::sleep_for(std::chrono::milliseconds(poll_interval));
    }
}

// static
size_t Geolocation::curl_callback(
    void *contents, size_t size, size_t nmemb, std::string *str)
{
    size_t old_len = str->size();
    size_t new_len = size * nmemb;
    
    str->resize(old_len + new_len); // may throw 

    std::copy((char*)contents,
              (char*)contents + new_len,
              str->begin() + old_len);
    
    return new_len;
}
