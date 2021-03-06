#include "slice.h"
#include <algorithm>

namespace vd
{

Slice::Slice(Slice *parent) : Node(parent)
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

void Slice::resetRate()
{
    _totalRate = 0.0;
    for (Node *node : _nodes)
    {
        node->resetRate();
        _totalRate += node->commonRate();
    }
}

void Slice::updateRate(double r)
{
    _totalRate += r;

    if (parent())
    {
        parent()->updateRate(r);
    }
}

Reaction *Slice::selectEvent(double r)
{
    assert(r >= 0);
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
    return _totalRate;
}

void Slice::sort()
{
    std::sort(_nodes.begin(), _nodes.end(), [](Node *a, Node *b) {
        return a->commonRate() > b->commonRate();
    });

    for (Node *node : _nodes)
    {
        node->sort();
    }
}

void Slice::halfSort()
{
    uint size = _nodes.size();
    if(size > 1)
    {
        for (uint i = 0; i < size - 1; ++i)
        {
            Node *a = _nodes[i];
            Node *b = _nodes[i+1];
            if (a->commonRate() < b->commonRate())
            {
                _nodes[i] = b;
                _nodes[i+1] = a;
            }
        }

        for (Node *node : _nodes)
        {
            node->halfSort();
        }
    }
}

}
