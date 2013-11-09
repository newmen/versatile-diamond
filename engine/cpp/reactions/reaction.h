#ifndef REACTION_H
#define REACTION_H

#include "../atoms/atom.h"

#ifdef PRINT
#include <string>
#endif // PRINT

namespace vd
{

class Reaction
{
public:
    virtual ~Reaction() {}

    virtual Atom *anchor() const = 0;
    virtual double rate() const = 0;
    virtual void doIt() = 0;

#ifdef PRINT
    virtual void info() = 0;
    virtual std::string name() const = 0;
#endif // PRINT

protected:
};

}

#endif // REACTION_H
