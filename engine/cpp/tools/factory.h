#ifndef FACTORY_H
#define FACTORY_H

#include <assert.h>
#include <unordered_map>

namespace vd
{

template
<
        class AbstractType,
        class KeyType,
        class... CreatingArgs
>
class Factory
{
    struct CreatorFunc
    {
        virtual ~CreatorFunc() {}
        virtual AbstractType *operator () (CreatingArgs... args) = 0;
    };

    template <class NewType>
    struct ConcreteCreatorFunc : public CreatorFunc
    {
        AbstractType *operator () (CreatingArgs... args)
        {
            return new NewType(args...);
        }
    };

    typedef std::unordered_map<KeyType, CreatorFunc *> MapType;

    MapType _map;

public:
    Factory() = default;
    virtual ~Factory();

    template <class NewType> void registerNewType(const KeyType &id);
    bool isRegistered(const KeyType &id) const;
    AbstractType *create(const KeyType &id, CreatingArgs... args) const;

private:
    Factory(const Factory &) = delete;
    Factory(Factory &&) = delete;
    Factory &operator = (const Factory &) = delete;
    Factory &operator = (Factory &&) = delete;
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

template <class AT, class KT, class... CArgs>
Factory<AT, KT, CArgs...>::~Factory()
{
    for (auto &pr : _map)
    {
        delete pr.second;
    }
}

template <class AT, class KT, class... CArgs>
template <class NT>
void Factory<AT, KT, CArgs...>::registerNewType(const KT &id)
{
    assert(!isRegistered(id));
    _map.insert(typename MapType::value_type(id, new ConcreteCreatorFunc<NT>));
}

template <class AT, class KT, class... CArgs>
bool Factory<AT, KT, CArgs...>::isRegistered(const KT &id) const
{
    return _map.find(id) != _map.cend();
}

template <class AT, class KT, class... CArgs>
AT *Factory<AT, KT, CArgs...>::create(const KT &id, CArgs... args) const
{
    auto it = _map.find(id);
    assert(it != _map.cend());
    return (*it->second)(args...);
}

}

#endif // FACTORY_H
