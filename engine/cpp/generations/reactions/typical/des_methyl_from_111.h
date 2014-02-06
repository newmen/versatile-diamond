#ifndef DES_METHYL_FROM_111_H
#define DES_METHYL_FROM_111_H

#include "../../species/specific/methyl_on_111_cmu.h"
#include "../typical.h"

class DesMethylFrom111 : public Typical<DES_METHYL_FROM_111>
{
public:
    static constexpr double RATE = 5.4e6 * exp(-0 / (1.98 * Env::T));

    static void find(MethylOn111CMu *target);

    DesMethylFrom111(SpecificSpec *target) : Typical(target) {}

    double rate() const override { return RATE; }
    void doIt() override;

    const char *name() const override;
};

#endif // DES_METHYL_FROM_111_H
