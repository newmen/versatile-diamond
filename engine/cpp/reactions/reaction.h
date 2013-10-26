#ifndef REACTION_H
#define REACTION_H

#include "../atoms/atom.h"

namespace vd
{

class Reaction
{
public:
    virtual ~Reaction() {}

    virtual double rate() const = 0;
    virtual void doIt() = 0;

#ifdef PRINT
    virtual void info() = 0;
#endif // PRINT

protected:
};

}

#endif // REACTION_H
