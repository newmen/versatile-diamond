#ifndef CREATOR_H
#define CREATOR_H

class Creator
{
public:
    virtual ~Creator() {}

protected:
    template <class T, class... Args>
    static void create(Args... args);
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

template <class T, class... Args>
void Creator::create(Args... args)
{
    auto item = new T(args...);
    item->store();
}

#endif // CREATOR_H
