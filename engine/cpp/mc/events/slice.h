#ifndef SLICE_H
#define SLICE_H

#include <vector>
#include "node.h"

namespace vd
{

class Slice : public Node
{
    typedef std::vector<Node *> Nodes;
    Nodes _nodes;
    Slice *_parent;

public:
    Slice(Slice *parent = nullptr);
    ~Slice();

    void addNode(Node *node);

    Reaction *selectEvent(double r) override;
    double commonRate() const override;
    void sort() override;
};

}

#endif // SLICE_H
