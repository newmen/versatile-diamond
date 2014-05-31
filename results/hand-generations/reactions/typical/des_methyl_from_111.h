#ifndef DES_METHYL_FROM_111_H
#define DES_METHYL_FROM_111_H

#include "../../species/specific/methyl_on_111_cmiu.h"
#include "../typical.h"

class DesMethylFrom111 : public Typical<DES_METHYL_FROM_111>
{
    static const char __name[];

public:
    static const double RATE;

    static void find(MethylOn111CMiu *target);

    DesMethylFrom111(SpecificSpec *target) : Typical(target) {}

    void doIt() override;

    double rate() const override { return RATE; }
    const char *name() const override { return __name; }
};

#endif // DES_METHYL_FROM_111_H
