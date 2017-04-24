#include "slice.h"

namespace vd
{

Slice::Slice(Slice *parent) : _parent(parent)
{
}

Slice::~Slice()
{
    for (Node *node : _nodes)
    {
        delete node;
    }
}

void Slice::addNode(Node *node)
{
    _nodes.push_back(node);
}

Reaction *Slice::selectEvent(double r)
{
    for (Node *node : _nodes)
    {
        double cr = node->commonRate();
        if (r < cr)
        {
            return node->selectEvent(r);
        }
        else
        {
            r -= cr;
        }
    }
    return nullptr;
}

double Slice::commonRate() const
{
    double result = 0;
    for (Node *node : _nodes)
    {
        result += node->commonRate();
    }
    return result;
}

void Slice::sort()
{

}

}
