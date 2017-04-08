#ifndef CONFIG_H_
#define CONFIG_H_

#include <string>

class Config
{
    using STR = std::string;
    using CSR = const std::string&;
    
public:
    bool set_file(CSR filename); // false if not writable to filename
                                 // should not use any of below if failed
    
    // if not existing, writes and returns default value
    STR  get_str (CSR key, CSR  def);
    int  get_int (CSR key, int  def);
    bool get_bool(CSR key, bool def);

    bool set_value(CSR key, CSR value); // false if failed

private:
    STR filename;
};

#endif /* CONFIG_H_ */
