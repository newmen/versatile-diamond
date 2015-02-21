#ifndef SAVERS_BUILDER
#define SAVERS_BUILDER

namespace vd {

class SaversBuilder
{
    virtual SaversBuilder* takeConcreteBuilder () = 0;
};

}

#endif // SAVERS_BUILDER

