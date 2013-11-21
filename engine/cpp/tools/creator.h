#ifndef CREATOR_H
#define CREATOR_H

class Creator
{
protected:
    template <class T, class... Args>
    static void createBy(Args... args);
};

template <class T, class... Args>
void Creator::createBy(Args... args)
{
    auto item = new T(args...);
    item->store();
}

#endif // CREATOR_H
