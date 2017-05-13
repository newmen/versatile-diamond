#ifndef MANY_FILES_H
#define MANY_FILES_H

#include <fstream>
#include <sstream>
#include <string>
#include "../phases/saving_reactor.h"

namespace vd
{

template <class B>
class ManyFiles : public B
{
    uint n = 0;

public:
    void save(const SavingReactor *reactor) override;

protected:
    template <class... Args> ManyFiles(Args... args) : B(args...) {}

    std::string filename() override;

    virtual void writeHeader(std::ostream &os, const SavingReactor *reactor) {}
    virtual void writeBody(std::ostream &os, const SavingReactor *reactor) = 0;
};

///////////////////////////////////////////////////////////////////////////////

template <class B>
void ManyFiles<B>::save(const SavingReactor *reactor)
{
    std::ofstream out(this->fullFilename());
    writeHeader(out, reactor);
    writeBody(out, reactor);
}

template<class B>
std::string ManyFiles<B>::filename()
{
    std::stringstream ss;
    ss << this->config()->filename() << "_" << (n++);
    return ss.str();
}

}

#endif // MANY_FILES_H
