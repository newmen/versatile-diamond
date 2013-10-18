#ifndef BASE_SPEC_H
#define BASE_SPEC_H

#include <vector>
#include <unordered_set>
#include <omp.h>
#include "atom.h"

namespace vd
{

class BaseSpec
{
public:
    virtual ~BaseSpec() {}

    virtual ushort type() const = 0;
    virtual void setupAtomTypes(ushort *types) = 0;

    virtual Atom *anchor() const = 0;
    virtual ushort size() const = 0; // TODO: временный метод для тест-спеков

//    virtual void findChildren() = 0;
};

template <ushort ATOMS_NUM>
class ConcreteBaseSpec : public BaseSpec
{
    ushort _type;
    Atom *_atoms[ATOMS_NUM];

public:
    ConcreteBaseSpec(ushort type, Atom **atoms);

    ushort type() const { return _type; }
    void setupAtomTypes(ushort *types);

    Atom *anchor() const { return atom(0); }
    ushort size() const { return ATOMS_NUM; } // TODO: временный метод для тест-спеков

protected:
    Atom *atom(ushort i) const { return _atoms[i]; }
};

template <ushort ATOMS_NUM>
ConcreteBaseSpec<ATOMS_NUM>::ConcreteBaseSpec(ushort type, Atom **atoms) : _type(type)
{
    for (int i = 0; i < ATOMS_NUM; ++i)
    {
        _atoms[i] = atoms[i];
    }
}

template <ushort ATOMS_NUM>
void ConcreteBaseSpec<ATOMS_NUM>::setupAtomTypes(ushort *types)
{
    for (int i = 0; i < ATOMS_NUM; ++i)
    {
        _atoms[i]->describe(types[i], this);
    }
}

}

#endif // BASE_SPEC_H
