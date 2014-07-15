#ifndef FACTORY_H
#define FACTORY_H

#include <assert.h>
#include <unordered_map>

namespace vd
{

// Factory create objects of AbstractType by key type KeyType.
// Constructors of all types should have a signature corresponding to CreatingArgs.
template
<
        class AbstractType,
        class KeyType,
        class... CreatingArgs
>
class Factory
{
    // Provides the base interface function that creates objects.
    struct CreatorFunc
    {
        virtual ~CreatorFunc() {}
        virtual AbstractType *operator () (CreatingArgs... args) = 0;
    };

    // The structure is designed to create an object of a concrete type.
    template <class NewType>
    struct ConcreteCreatorFunc : public CreatorFunc
    {
        AbstractType *operator () (CreatingArgs... args)
        {
            return new NewType(args...);
        }
    };

    // Store a pointer to a function that will create objects.
    typedef std::unordered_map<KeyType, CreatorFunc *> MapType;
    MapType _map;

public:
    Factory() = default;
    virtual ~Factory();

    // Associates the key with some type.
    template <class NewType> void registerNewType(const KeyType &id);
    // Check whether this object is registered.
    bool isRegistered(const KeyType &id) const;
    // Create object.
    AbstractType *create(const KeyType &id, CreatingArgs... args) const;

private:
    Factory(const Factory &) = delete;
    Factory(Factory &&) = delete;
    Factory &operator = (const Factory &) = delete;
    Factory &operator = (Factory &&) = delete;
};

//////////////////////////////////////////////////////////////////////////////////////

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
