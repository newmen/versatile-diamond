#ifndef XYZ_FORMAT_H
#define XYZ_FORMAT_H

#include "../phases/saving_reactor.h"
#include "format.h"
#include "xyz_accumulator.h"

namespace vd
{

template <class B>
class XYZFormat : public Format<B, XYZAccumulator>
{
    typedef Format<B, XYZAccumulator> ParentType;

public:
    template <class... Args> XYZFormat(Args... args) : ParentType(args...) {}

protected:
    void writeHeader(std::ostream &os, const SavingReactor *reactor) override;
    void writeBody(std::ostream &os, const SavingReactor *reactor) override;
};

//////////////////////////////////////////////////////////////////////////////////////

template <class B>
void XYZFormat<B>::writeHeader(std::ostream &os, const SavingReactor *reactor)
{
    os << this->accumulator()->atoms().size() << "\n"
         << "Name: "
         << this->config()->name()
         << " Current time: "
         << reactor->currentTime() << "s" << "\n";
}

template <class B>
void XYZFormat<B>::writeBody(std::ostream &os, const SavingReactor *)
{
    for (const SavingAtom *atom : this->accumulator()->atoms())
    {
        const float3 &crd = atom->realPosition();
        os << atom->name() << " "
           << crd.x << " "
           << crd.y << " "
           << crd.z << "\n";
    }
}


}

#endif // XYZ_FORMAT_H
