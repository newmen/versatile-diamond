#ifndef ATOM_INFO_H
#define ATOM_INFO_H

#include "detector.h"

namespace vd
{

class AtomInfo
{
    const SavingAtom *_atom;
    uint _noBond = 0;

public:
    explicit AtomInfo(const SavingAtom *atom) : _atom(atom) {}
    AtomInfo(const AtomInfo &) = default;

    bool operator == (const AtomInfo &other) const { return _atom == other._atom; }

    const SavingAtom *atom() const { return _atom; }
    uint noBond() const { return _noBond; }
    void incNoBond() { ++_noBond; }

private:
    AtomInfo(AtomInfo &&) = delete;
    AtomInfo &operator = (const AtomInfo &) = delete;
    AtomInfo &operator = (AtomInfo &&) = delete;
};

}

#endif // ATOM_INFO_H
