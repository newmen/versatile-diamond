#ifndef PHASE_H
#define PHASE_H

namespace vd
{

class Atom;

// TODO: for what?
class Phase
{
public:
    virtual ~Phase() {}
    virtual void erase(Atom *atom) = 0;
};

}

#endif // PHASE_H
