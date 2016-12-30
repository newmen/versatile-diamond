#include "define_print.h"

#if defined(PRINT) || defined(ANY_PRINT)

#include "indent_stream.h"
#include "common.h"

namespace vd
{

IndentStream::IndentStream(std::ostringstream &stream, ushort indent) : _stream(stream), _indent(indent)
{
}

IndentStream::IndentStream(IndentStream &stream, ushort indent) : _stream(stream._stream), _indent(indent + stream._indent)
{
    newLineIfNeed();
    printIndent();
}

IndentStream::~IndentStream()
{
    newLineIfNeed();
}

IndentStream &IndentStream::out(void *pointer)
{
    _stream << pointer;
    return *this;
}

IndentStream &IndentStream::out(const char *c_str)
{
    return out(std::string(c_str));
}

IndentStream &IndentStream::out(const std::string &str)
{
    if (isLastOutedNL())
    {
        printIndent();
    }
    _stream << str;
    if (str.back() == '\n')
    {
        printIndent();
    }
    return *this;
}

bool IndentStream::isLastOutedNL() const
{
    return _stream.str().back() == '\n';
}

void IndentStream::newLineIfNeed()
{
    if (_indent > 0 && !isLastOutedNL())
    {
        _stream << "\n";
    }
}

void IndentStream::printIndent()
{
    for (ushort i = 0; i < _indent; ++i)
    {
        _stream << " ";
    }
}

//////////////////////////////////////////////////////////////////////////////////////

IndentStream &operator << (IndentStream &stream, short value)
{
    return stream.out(value);
}

IndentStream &operator << (IndentStream &stream, ushort value)
{
    return stream.out(value);
}

IndentStream &operator << (IndentStream &stream, int value)
{
    return stream.out(value);
}

IndentStream &operator << (IndentStream &stream, uint value)
{
    return stream.out(value);
}

IndentStream &operator << (IndentStream &stream, long value)
{
    return stream.out(value);
}

IndentStream &operator << (IndentStream &stream, ulong value)
{
    return stream.out(value);
}

IndentStream &operator << (IndentStream &stream, long long value)
{
    return stream.out(value);
}

IndentStream &operator << (IndentStream &stream, ullong value)
{
    return stream.out(value);
}

IndentStream &operator << (IndentStream &stream, float value)
{
    return stream.out(value);
}

IndentStream &operator << (IndentStream &stream, double value)
{
    return stream.out(value);
}

IndentStream &operator << (IndentStream &stream, void *pointer)
{
    return stream.out(pointer);
}

IndentStream &operator << (IndentStream &stream, const char *c_str)
{
    return stream.out(c_str);
}

IndentStream &operator << (IndentStream &stream, const std::string &str)
{
    return stream.out(str);
}

IndentStream &operator << (IndentStream &stream, std::streambuf *sb)
{
    return stream.out(sb);
}

IndentStream &operator << (IndentStream &stream, std::ostream &(*pf)(std::ostream &))
{
    return stream.out(pf);
}

IndentStream &operator << (IndentStream &stream, std::ios &(*pf)(std::ios &))
{
    return stream.out(pf);
}

IndentStream &operator << (IndentStream &stream, std::ios_base &(*pf)(std::ios_base &))
{
    return stream.out(pf);
}

IndentStream &operator << (IndentStream &stream, const int3 &value)
{
    return stream.out(value);
}

}

#endif // PRINT || ANY_PRINT
