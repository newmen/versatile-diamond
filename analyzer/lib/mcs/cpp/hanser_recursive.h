#ifndef HANSER_RECURSIVE_H
#define HANSER_RECURSIVE_H

#include <assert.h>
#include <list>
#include <unordered_map>
#include <unordered_set>
#include "unordered_set_operations.h"
#include "assoc_graph.h"

/*
 * The modified Hanser's recursive algorithm for find of subgraph in graph
 * V is type of vertex of assoc graph
 */
template <typename V>
class HanserRecursive
{
    typedef AssocGraph<V> AG;
    AG *_g;

    typedef std::unordered_map<V, unsigned> OrderOfAdding;
    OrderOfAdding _orderOfAdding;
    unsigned _addingIndex = 0;

public:
    typedef typename AG::Vertices Vertices;
    typedef std::list<V> Intersec;
    typedef std::list<Intersec> Intersections;

    HanserRecursive();
    ~HanserRecursive();

    // Stores the edge to assoc graph
    void addEdge(V v, V w, bool isExt = true);

    // Finds all possible intersections by assoc graph
    Intersections intersections() const;

private:
    HanserRecursive(const HanserRecursive &) = delete;
    HanserRecursive(HanserRecursive &&) = delete;
    HanserRecursive &operator = (const HanserRecursive &) = delete;
    HanserRecursive &operator = (HanserRecursive &&) = delete;

    typedef std::list<Vertices> ListOfIntersecSets;

    class Collector
    {
        ListOfIntersecSets _intersections;
        unsigned _maxSize = 0;

    public:
        void adsorbIntersec(const Vertices &intersec)
        {
            unsigned size = intersec.size();
            if (size < _maxSize) return;
            if (size > _maxSize)
            {
                _maxSize = size;
                _intersections.clear();
            }
            _intersections.push_back(intersec);
        }

        const ListOfIntersecSets &intersections() const
        {
            return _intersections;
        }
    };

    void storeVertexIndex(V v);
    void find(Collector *pCollector, const Vertices &intersec, const Vertices &qPlus, const Vertices &qMinus) const;
    unsigned sumOfIH(const Intersec &vertices) const;
};

///////////////////////////////////////////////////////////////////////////////

template <typename V>
HanserRecursive<V>::HanserRecursive()
{
    _g = new AG;
}

template <typename V>
HanserRecursive<V>::~HanserRecursive()
{
    delete _g;
}

template <typename V>
void HanserRecursive<V>::addEdge(V v, V w, bool isExt)
{
    storeVertexIndex(v);
    storeVertexIndex(w);
    _g->addEdge(v, w, isExt);
}

template <typename V>
typename HanserRecursive<V>::Intersections HanserRecursive<V>::intersections() const
{
    Collector collector;
    find(&collector, Vertices(), _g->allVertices(), Vertices());

    Intersections result;
    ListOfIntersecSets intersections = collector.intersections();
    for (const Vertices &intersec : intersections)
    {
        result.push_back(Intersec(intersec.cbegin(), intersec.cend()));
    }

    // The order is very important for tests
    for (Intersec &ilist : result)
    {
        ilist.sort([this](V v, V w) {
            return _orderOfAdding.find(v)->second < _orderOfAdding.find(w)->second;
        });
    }
    result.sort([this](const Intersec &f, const Intersec &s) {
        return sumOfIH(f) < sumOfIH(s);
    });

    return result;
}

template <typename V>
void HanserRecursive<V>::storeVertexIndex(V v)
{
    _orderOfAdding.insert(typename OrderOfAdding::value_type(v, _addingIndex++));
}

template <typename V>
void HanserRecursive<V>::find(Collector *pCollector,
                              const HanserRecursive<V>::Vertices &intersec,
                              const HanserRecursive<V>::Vertices &qPlus,
                              const HanserRecursive<V>::Vertices &qMinus) const
{
    pCollector->adsorbIntersec(intersec);
    if (qPlus.empty()) return;

    // simplified clique searching algorithm
    Vertices cutPlus = qPlus - intersec;
    Vertices extMinus = qMinus;
    for (typename Vertices::const_iterator it = cutPlus.cbegin(); it != cutPlus.cend(); it++)
    {
        Vertices nextMinus = extMinus + _g->fbnNeighbours(*it);
        Vertices nextPlus;
        if (intersec.empty())
        {
            nextPlus = _g->extNeighbours(*it) - nextMinus;
        }
        else
        {
            nextPlus = (qPlus + _g->extNeighbours(*it)) - nextMinus;
        }
        extMinus.insert(*it);

        Vertices nextIntersec = intersec;
        nextIntersec.insert(*it);
        find(pCollector, nextIntersec, nextPlus, nextMinus);
    }
}

template <typename V>
unsigned HanserRecursive<V>::sumOfIH(const HanserRecursive<V>::Intersec &vertices) const
{
    unsigned result = 0;
    unsigned x = 1;
    for (V v : vertices)
    {
        result += _orderOfAdding.find(v)->second * x;
        x += 17;
    }
    return result;
}

#endif // HANSER_RECURSIVE_H
