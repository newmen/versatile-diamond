#ifndef REACTION_H
#define REACTION_H

#include "atom.h"

class Reaction
{
public:
    virtual ~Reaction() {}

    virtual double rate() const = 0;
    virtual void doIt() = 0;
};

#endif // REACTION_H
