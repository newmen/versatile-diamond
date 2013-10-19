#ifndef BRIDGE_H
#define BRIDGE_H

#include "../../source_base_spec.h"
using namespace vd;

class Bridge : public SourceBaseSpec<3>
{
public:
    static void find(Atom *anchor);

    using SourceBaseSpec::SourceBaseSpec;

    void findChildren();
};

#endif // BRIDGE_H
