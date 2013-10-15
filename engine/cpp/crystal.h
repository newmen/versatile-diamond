#ifndef CRYSTAL_H
#define CRYSTAL_H

#include "common.h"
#include "vector3d.h"
#include "phase.h"

namespace vd
{

class Crystal : public Phase
{
public:
    typedef vector3d<Atom *> Atoms;

    Crystal(const dim3 &sizes);
    ~Crystal() override;

    void initialize();

    void insert(Atom *atom, const int3 &coords);
    void erase(Atom *atom) override;

    Atom *atom(const int3 &coords) const { return _atoms[coords]; }

    uint countAtoms() const;

protected:
    virtual void buildAtoms() = 0;
    virtual void bondAllAtoms() = 0;

    virtual Atom *makeAtom(uint type, const int3 &coords) = 0;

    void makeLayer(uint z, uint type);

    const Atoms &atoms() const { return _atoms; }
    Atoms &atoms() { return _atoms; }

//    Atom *atom(const int3 &coords) { return _atoms[coords]; }

private:
    void specifyAllAtoms();
    void findAll();

private:
    Atoms _atoms;
};

}

#endif // CRYSTAL_H
