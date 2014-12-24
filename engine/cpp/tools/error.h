#ifndef ERROR_H
#define ERROR_H

#include <sstream>

namespace vd
{

class Error
{
    std::string _message;

public:
    template <typename... Args> Error(Args... args);
    Error(const Error &) = default;
    Error(Error &&) = default;

    const char *message() const { return _message.c_str(); }

private:
    Error &operator = (const Error &) = delete;
    Error &operator = (Error &&) = delete;

    template <typename T, typename... Args> void build(std::stringstream &ss, const T &first, Args... args);
    template <typename T> void build(std::stringstream &ss, const T &last);
};

//////////////////////////////////////////////////////////////////////////////////////

template <typename... Args>
Error::Error(Args... args)
{
    std::stringstream ss;
    build(ss, args...);
    _message = std::move(ss.str());
}

template <typename T, typename... Args>
void Error::build(std::stringstream &ss, const T &first, Args... args)
{
    ss << first;
    build(ss, args...);
}

template <typename T>
void Error::build(std::stringstream &ss, const T &last)
{
    ss << last;
}

}

#endif // ERROR_H
