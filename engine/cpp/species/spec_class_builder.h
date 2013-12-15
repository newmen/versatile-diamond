#ifndef SPEC_TYPE_BUILDER_H
#define SPEC_TYPE_BUILDER_H

namespace vd
{

// U type should not have any defined constructor except that default
template <class B, class U>
class SpecClassBuilder : public B, public U
{
public:
    void store() override
    {
        B::store();
        U::store();
    }

    void remove() override
    {
        B::remove();
        U::remove();
    }

protected:
    template <class... Args>
    SpecClassBuilder(Args... args) : B(args...) {}
};

}

#endif // SPEC_TYPE_BUILDER_H
