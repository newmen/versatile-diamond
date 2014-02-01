#ifndef CREATOR_H
#define CREATOR_H

class Creator
{
public:
    virtual ~Creator() {}

protected:
    Creator() = default;

    template <class T, class... Args>
    static T *create(Args... args);
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

template <class T, class... Args>
T *Creator::create(Args... args)
{
    auto item = new T(args...);
    item->store();
    return item;
}

#endif // CREATOR_H
