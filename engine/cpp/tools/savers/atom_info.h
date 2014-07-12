#ifndef ATOM_INFO_H
#define ATOM_INFO_H

#include <string>
#include "detector.h"

namespace vd
{

class AtomInfo
{
    const Atom *_atom;
    uint _noBond = 0;

    friend class std::hash<AtomInfo>;

public:
    explicit AtomInfo(const Atom *atom) : _atom(atom) {}

    bool operator == (const AtomInfo &other) const { return _atom == other._atom; }

    const Atom *atom() const { return _atom; }
    uint noBond() const { return _noBond; }
    void incNoBond() { ++_noBond; }
};

}

//////////////////////////////////////////////////////////////////////////////////////

namespace std
{

template <>
struct hash<vd::AtomInfo>
{
    size_t operator () (const vd::AtomInfo &ai) const
    {
        return reinterpret_cast<size_t>(ai.atom());
    }
};

}

#endif // ATOM_INFO_H
