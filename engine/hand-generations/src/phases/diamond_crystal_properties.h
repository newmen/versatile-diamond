#ifndef DIAMOND_CRYSTAL_PROPERTIES_H
#define DIAMOND_CRYSTAL_PROPERTIES_H

#include <atoms/atom.h>
#include <tools/common.h>
using namespace vd;

#include "diamond_relations.h"

template <class B>
class DiamondCrystalProperties : public DiamondRelations<B>
{
public:
    // The virtual keyname required by compiler (why?)
    virtual float3 correct(const Atom *atom) const final;
    virtual const float3 &periods() const final;

protected:
    template <class... Args> DiamondCrystalProperties(Args... args) : DiamondRelations<B>(args...) {}

    // The virtual keyname required by compiler (why?)
    virtual float3 seeks(const int3 &coords) const final;
    void bondAround(Atom *atom);

private:
    float dimerBondLength() const { return 1.62; }
    float oneAtomDimerDelta() const { return 0.5 * (periods().x - dimerBondLength()); }
    float dimerHeightDelta() const
    {
        float oadd = oneAtomDimerDelta();
        float h = std::sqrt(periods().z * periods().z - oadd * oadd);
        return periods().z - h;
    }
};

//////////////////////////////////////////////////////////////////////////////////////

template <class B>
float3 DiamondCrystalProperties<B>::correct(const Atom *atom) const
{
    assert(atom->lattice());
    const int3 &crds = atom->lattice()->coords();
    const Atom *otherDimerPart = nullptr;

    atom->eachNeighbour([&crds, &otherDimerPart](const Atom *nbr) {
        if (nbr->lattice() && nbr->lattice()->coords().z == crds.z)
        {
            assert(!otherDimerPart);
            otherDimerPart = nbr;
        }
    });

    if (otherDimerPart)
    {
        int3 diff = otherDimerPart->lattice()->coords() - crds;
        if (diff.isUnit())
        {
            float3 result = diff * oneAtomDimerDelta();
            result.z -= dimerHeightDelta();
            return result;
        }
    }

    return float3();
}

template <class B>
const float3 &DiamondCrystalProperties<B>::periods() const
{
    // Characteristic sizes for (100) face directed to top
    static const float3 periods(2.45, 2.45, 3.57 / 4);
    return periods;
}

template <class B>
float3 DiamondCrystalProperties<B>::seeks(const int3 &coords) const
{
    if (coords.z == 0)
    {
        return float3();
    }
    else
    {
        float px = periods().x / 2, py = periods().y / 2;
        int cx = (coords.z + 1) / 2, cy = coords.z / 2;

        return float3(cx * px, cy * py);
    }
}

template <class B>
void DiamondCrystalProperties<B>::bondAround(Atom *atom)
{
    auto neighbours = this->cross_110(atom);
    assert(neighbours.all());
    atom->bondWith(neighbours[0]);
    atom->bondWith(neighbours[1]);
}

#endif // DIAMOND_CRYSTAL_PROPERTIES_H
