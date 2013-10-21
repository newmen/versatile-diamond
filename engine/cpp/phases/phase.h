#ifndef PHASE_H
#define PHASE_H

namespace vd
{

class Atom;

class Phase
{
public:
    virtual ~Phase() {}
    virtual void erase(Atom *atom) = 0;

    void remove(Atom *atom);
};

}

#endif // PHASE_H
