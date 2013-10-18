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

    virtual Atom *anchor() const = 0; // TODO: временный метод для тест-спеков?
    virtual ushort size() const = 0;

//    virtual void findChildren() = 0;
};

template <ushort ATOMS_NUM>
class ConcreteBaseSpec : public BaseSpec
{
    ushort _type;
    ushort _types[ATOMS_NUM];
    Atom *_atoms[ATOMS_NUM];

public:
    ConcreteBaseSpec(ushort type, ushort *types, Atom **atoms);

    ushort type() const { return _type; }

    Atom *anchor() const { return atom(0); } // TODO: временный метод для тест-спеков?
    ushort size() const { return ATOMS_NUM; }

protected:
    Atom *atom(ushort i) const { return _atoms[i]; }
};

template <ushort ATOMS_NUM>
ConcreteBaseSpec<ATOMS_NUM>::ConcreteBaseSpec(ushort type, ushort *types, vd::Atom **atoms) : _type(type)
{
//#pragma omp parallel for
    for (int i = 0; i < ATOMS_NUM; ++i)
    {
        _types[i] = types[i];
        _atoms[i] = atoms[i];
        _atoms[i]->describe(types[i], this);
    }
}

}

#endif // BASE_SPEC_H
