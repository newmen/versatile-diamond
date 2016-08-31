#ifndef ONE_FILE_H
#define ONE_FILE_H

#include <fstream>
#include <sstream>
#include <string>
#include "../phases/saving_reactor.h"

namespace vd
{

template <class B>
class OneFile : public B
{
    std::ofstream *_out = nullptr;

public:
    ~OneFile() { delete _out; }

    void save(const SavingReactor *reactor) override;

protected:
    template <class... Args> OneFile(Args... args) : B(args...) {}

    std::string filename() const override;

    virtual void writeHeader(std::ostream &os, const SavingReactor *reactor) {}
    virtual void writeBody(std::ostream &os, const SavingReactor *reactor) = 0;
    virtual const char *separator() const;

private:
    std::ofstream &out() { return *_out; }
};

//////////////////////////////////////////////////////////////////////////////////////

template <class B>
void OneFile<B>::save(const SavingReactor *reactor)
{
    static bool isFileOpen = false;
    if (!isFileOpen)
    {
        _out = new std::ofstream(this->fullFilename());
        writeHeader(out(), reactor);
        isFileOpen = true;
    }

    this->writeBody(out(), reactor);
    out() << separator();
}

template <class B>
std::string OneFile<B>::filename() const
{
    return this->config()->filename();
}

template <class B>
const char *OneFile<B>::separator() const
{
    static const char empty[1] = "";
    return empty;
}

}

#endif // ONE_FILE_H
