#ifndef ATOM_INFO_H
#define ATOM_INFO_H

#include <string>
#include "volume_atom.h"
#include "detector.h"

namespace vd
{

class AtomInfo : public VolumeAtom
{
    uint _noBond = 0;

    friend class std::hash<AtomInfo>;

public:
    explicit AtomInfo(const Atom *atom) : VolumeAtom(atom) {}

    bool operator == (const AtomInfo &other) const;

    void incNoBond();
    uint noBond() const { return _noBond; }
    const char *type() const;
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
