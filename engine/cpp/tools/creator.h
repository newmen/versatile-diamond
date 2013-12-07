#ifndef CREATOR_H
#define CREATOR_H

class Creator
{
protected:
    template <class T, class... Args>
    static T *createBy(Args... args);
};

template <class T, class... Args>
T *Creator::createBy(Args... args)
{
    auto item = new T(args...);
    item->store();
    return item;
}

#endif // CREATOR_H
