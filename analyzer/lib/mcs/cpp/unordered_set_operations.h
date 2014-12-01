#ifndef UNORDERED_SET_OPERATIONS_H
#define UNORDERED_SET_OPERATIONS_H

#include <unordered_set>

template <class T>
std::unordered_set<T> operator + (const std::unordered_set<T> &other);

template <class T>
std::unordered_set<T> operator - (const std::unordered_set<T> &other);

///////////////////////////////////////////////////////////////////////////////

template <class T>
std::unordered_set<T> operator + (const std::unordered_set<T> &f, const std::unordered_set<T> &s)
{
    std::unordered_set<T> result(f);
    result.insert(s.cbegin(), s.cend());
    return result;
}

template <class T>
std::unordered_set<T> operator - (const std::unordered_set<T> &f, const std::unordered_set<T> &s)
{
    std::unordered_set<T> result(f);
    for (typename std::unordered_set<T>::const_iterator it = s.cbegin(); it != s.cend(); it++)
    {
        typename std::unordered_set<T>::const_iterator ft = result.find(*it);
        if (ft != result.cend())
        {
            result.erase(ft);
        }
    }
    return result;
}

#endif // UNORDERED_SET_OPERATIONS_H
