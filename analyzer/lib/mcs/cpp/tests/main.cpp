#include <assert.h>
#include <iostream>
#include "../assoc_graph.h"
#include "../hanser_recursive.h"
#include "../object_id.h"

typedef AssocGraph<ObjectID> AG;

void checkAssocGraph()
{
    AG g;
    ObjectID v1 = 1;
    ObjectID v2 = 2;
    ObjectID v3 = 3;
    ObjectID v4 = 4;

    g.addEdge(v1, v2);
    g.addEdge(v1, v3);
    g.addEdge(v1, v4, false);

    assert(g.allVertices() == AG::Vertices({ v1, v2, v3, v4 }));

    assert(g.extNeighbours(v1) == AG::Vertices({ v2, v3 }));
    assert(g.extNeighbours(v2) == AG::Vertices({ v1 }));

    assert(g.fbnNeighbours(v1) == AG::Vertices({ v4 }));
    assert(g.fbnNeighbours(v2).empty());
}

void checkHanserRecursive()
{
    ObjectID v01 = 1;
    ObjectID v02 = 2;
    ObjectID v03 = 3;
    ObjectID v11 = 11;
    ObjectID v12 = 12;
    ObjectID v13 = 13;
    ObjectID v21 = 21;
    ObjectID v22 = 22;
    ObjectID v23 = 23;

    HR h;
    h.addEdge(v01, v12);
    h.addEdge(v01, v13);
    h.addEdge(v01, v22);
    h.addEdge(v01, v23);
    h.addEdge(v12, v23);
    h.addEdge(v13, v22);

    h.addEdge(v01, v02, false);
    h.addEdge(v01, v03, false);
    h.addEdge(v01, v11, false);
    h.addEdge(v01, v21, false);
    h.addEdge(v02, v03, false);
    h.addEdge(v02, v11, false);
    h.addEdge(v02, v12, false);
    h.addEdge(v02, v13, false);
    h.addEdge(v02, v21, false);
    h.addEdge(v02, v22, false);
    h.addEdge(v02, v23, false);
    h.addEdge(v03, v11, false);
    h.addEdge(v03, v12, false);
    h.addEdge(v03, v13, false);
    h.addEdge(v03, v21, false);
    h.addEdge(v03, v22, false);
    h.addEdge(v03, v23, false);
    h.addEdge(v11, v12, false);
    h.addEdge(v11, v13, false);
    h.addEdge(v11, v21, false);
    h.addEdge(v11, v22, false);
    h.addEdge(v11, v23, false);
    h.addEdge(v12, v13, false);
    h.addEdge(v12, v21, false);
    h.addEdge(v12, v22, false);
    h.addEdge(v13, v21, false);
    h.addEdge(v13, v23, false);
    h.addEdge(v21, v22, false);
    h.addEdge(v21, v23, false);
    h.addEdge(v22, v23, false);

    HR::Intersections intersections;
    intersections.push_back({ v01, v13, v22 });
    intersections.push_back({ v01, v12, v23 });
    assert(h.intersections() == intersections);
}

int main()
{
    checkAssocGraph();
    checkHanserRecursive();

    return 0;
}
