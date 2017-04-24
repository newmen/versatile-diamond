#ifndef NODE_H
#define NODE_H

#include "../reactions/reaction.h"

namespace vd
{

class Node
{
public:
    virtual ~Node() {}

    virtual Reaction *selectEvent(double r) = 0;
    virtual double commonRate() const = 0;
    virtual void sort() = 0;

protected:
    Node() = default;

private:
    Node(const Node &) = delete;
    Node(Node &&) = delete;
    Node &operator = (const Node &) = delete;
    Node &operator = (Node &&) = delete;
};

}

#endif // NODE_H
