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

    virtual Atom *anchor() const = 0; // TODO: временный метод для тест-спеков
    virtual uint size() const = 0;

//    virtual void findChildren() = 0;
};

template <uint ATOMS_NUM>
class ConcreteBaseSpec : public BaseSpec
{
    uint _types[ATOMS_NUM];
    Atom *_atoms[ATOMS_NUM];

public:
    ConcreteBaseSpec(uint *types, Atom **atoms)
    {
//#pragma omp parallel for
        for (int i = 0; i < ATOMS_NUM; ++i)
        {
            _types[i] = types[i];
            _atoms[i] = atoms[i];
//            _atoms[i]->describe(this);
        }
    }

    Atom *anchor() const { return atom(0); } // TODO: временный метод для тест-спеков
    uint size() const { return ATOMS_NUM; }

protected:
    Atom *atom(uint i) const { return _atoms[i]; }
};

}

#endif // BASE_SPEC_H
