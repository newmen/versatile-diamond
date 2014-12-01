#ifndef UNION_DIFF_OPERATIONS_H
#define UNION_DIFF_OPERATIONS_H

#include <algorithm>
#include <list>

/*
 * The union operation
 */
template <class T>
std::list<T> unionOp(const std::list<T> &self, const std::list<T> &other);

/*
 * The difference operation
 */
template <class T>
std::list<T> diffOp(const std::list<T> &self, const std::list<T> &other);

///////////////////////////////////////////////////////////////////////////////

template <class T>
std::list<T> unionOp(const std::list<T> &self, const std::list<T> &other)
{
    std::list<T> result(self);
    for (const T &item : other)
    {
        if (std::find(result.begin(), result.end(), item) == result.cend())
        {
            result.push_back(item);
        }
    }
    return result;
}

template <class T>
std::list<T> diffOp(const std::list<T> &self, const std::list<T> &other)
{
    std::list<T> result(self);
    for (const T &item : other)
    {
        typename std::list<T>::iterator it = std::find(result.begin(), result.end(), item);
        if (it != result.end())
        {
            result.erase(it);
        }
    }
    return result;
}

#endif // UNION_DIFF_OPERATIONS_H
