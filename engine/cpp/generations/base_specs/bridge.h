#ifndef BRIDGE_H
#define BRIDGE_H

#include "../../species/source_base_spec.h"
using namespace vd;

class Bridge : public SourceBaseSpec<3>
{
public:
    static void find(Atom *anchor);

    using SourceBaseSpec::SourceBaseSpec;

#ifdef PRINT
    std::string name() const override { return "bridge"; }
#endif // PRINT

    void findChildren() override;
};

#endif // BRIDGE_H
