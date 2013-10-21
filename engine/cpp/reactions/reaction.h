#ifndef REACTION_H
#define REACTION_H

#include "../atoms/atom.h"

class Reaction
{
public:
    virtual ~Reaction() {}

    virtual double rate() const = 0;
    virtual void doIt() = 0;

    virtual void remove() = 0;
protected:
};

#endif // REACTION_H
