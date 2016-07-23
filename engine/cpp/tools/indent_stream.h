#ifndef INDENT_STREAM_H
#define INDENT_STREAM_H

#ifdef PRINT

#include <string>
#include <sstream>
#include "short_types.h"

namespace vd
{

class IndentStream
{
    std::ostringstream &_stream;
    ushort _indent;

public:
    IndentStream(std::ostringstream &stream, ushort indent);
    IndentStream(IndentStream &stream, ushort indent);
    IndentStream(IndentStream &&) = default;
    ~IndentStream();

    template <class T> IndentStream &out(T &ref);
    IndentStream &out(void *pointer);
    IndentStream &out(const char *c_str);
    IndentStream &out(const std::string &str);

private:
    IndentStream(const IndentStream &) = delete;
    IndentStream &operator = (const IndentStream &) = delete;
    IndentStream &operator = (IndentStream &&) = delete;

    bool isLastOutedNL() const;
    void newLineIfNeed();
    void printIndent();
};

//////////////////////////////////////////////////////////////////////////////////////

template <class T>
IndentStream &IndentStream::out(T &ref)
{
    _stream << ref;
    return *this;
}

//////////////////////////////////////////////////////////////////////////////////////

class int3;

IndentStream &operator << (IndentStream &stream, short value);
IndentStream &operator << (IndentStream &stream, ushort value);
IndentStream &operator << (IndentStream &stream, int value);
IndentStream &operator << (IndentStream &stream, uint value);
IndentStream &operator << (IndentStream &stream, long value);
IndentStream &operator << (IndentStream &stream, ulong value);
IndentStream &operator << (IndentStream &stream, long long value);
IndentStream &operator << (IndentStream &stream, ullong value);
IndentStream &operator << (IndentStream &stream, float value);
IndentStream &operator << (IndentStream &stream, double value);
IndentStream &operator << (IndentStream &stream, void *pointer);
IndentStream &operator << (IndentStream &stream, const char *c_str);
IndentStream &operator << (IndentStream &stream, const std::string &str);
IndentStream &operator << (IndentStream &stream, std::streambuf *sb);
IndentStream &operator << (IndentStream &stream, std::ostream &(*pf)(std::ostream &));
IndentStream &operator << (IndentStream &stream, std::ios &(*pf)(std::ios &));
IndentStream &operator << (IndentStream &stream, std::ios_base &(*pf)(std::ios_base &));
IndentStream &operator << (IndentStream &stream, const int3 &value);

}

#endif // PRINT
#endif // INDENT_STREAM_H
