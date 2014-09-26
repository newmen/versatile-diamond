#ifndef SAMPLE_H
#define SAMPLE_H

#include <localizators/localizator.h>

class Sample : public Localizator
{
public:
    void adsorb(const StudyUnit *unit) override;
};

#endif // SAMPLE_H
