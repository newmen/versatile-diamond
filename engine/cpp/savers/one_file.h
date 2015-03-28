#ifndef ONE_FILE_H
#define ONE_FILE_H

#include <fstream>
#include <sstream>
#include <string>
#include "../phases/amorph.h"
#include "../phases/crystal.h"
#include "detector.h"

namespace vd
{

template <class B>
class OneFile : public B
{
    std::ofstream *_out = nullptr;

public:
    ~OneFile() { delete _out; }

    void save(double currentTime, const Amorph *amorph, const Crystal *crystal, const Detector *detector) override;

protected:
    template <class... Args> OneFile(Args... args) : B(args...) {}

    virtual const char *separator() const = 0;
    std::string filename() const override;

private:
    std::ofstream &out();
};

///////////////////////////////////////////////////////////////

template <class B>
void OneFile<B>::save(double currentTime, const Amorph *amorph, const Crystal *crystal, const Detector *detector)
{
    static uint counter = 0;
    if (counter > 0)
    {
        out() << separator();
    }
    ++counter;

    this->saveTo(out(), currentTime, amorph, crystal, detector);
}

template <class B>
std::string OneFile<B>::filename() const
{
    std::stringstream ss;
    ss << this->name() << this->ext();
    return ss.str();
}

template <class B>
std::ofstream &OneFile<B>::out()
{
    if (_out == nullptr)
    {
        _out = new std::ofstream(filename());
    }
    return *_out;
}

}

#endif // ONE_FILE_H
