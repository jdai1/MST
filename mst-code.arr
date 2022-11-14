use context essentials2021
include shared-gdrive("mst-definitions.arr", "1Nc7LeRp7S8mnqF6pQMRJvQfYqUooD0lw")

provide: mst-prim, mst-kruskal, generate-input, mst-cmp, sort-o-cle end

include my-gdrive("mst-common.arr")
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# You may write implementation-specific tests (e.g., of helper functions)
# in this file.

import string-dict as SD

#### Ksuskal's implementation ####
fun mst-kruskal(graph :: Graph) -> Graph: 
  doc: ```consumes a graph and returns a minimum spanning graph obtained
       using Kruskal's algorithm.```
  sorted-edges = sort-by(
    graph, 
    edge-cmp, 
    {(e1, e2): e1.weight == e2.weight})

  node-dict = get-node-dict(graph)

  add-edges(empty, sorted-edges, node-dict)
end

#### Prim's implementation ####

fun mst-prim(graph :: Graph) -> Graph:
  doc: ```consumes a graph and returns a minimum spanning graph obtained
       using Prim's algorithm.```

  edge-dict = get-edge-dict(graph)
  node-dict = get-node-dict(graph)

  fun h(heap :: Heap<Edge>, visited :: SD.StringDict<Boolean>) -> Graph:
    doc: ```helper for mst-prim that consumes a heap and returns a minimum
         spanning graph,```
    cases (Heap) heap:
      | mt => 
        empty
      | node(v, l, r) =>
        {heap-without-min; min-edge-option} = get-min-edge(heap, node-dict)
        cases (Option) min-edge-option block:
          | none => 
            empty
          | some(min-edge) => 
            union(node-dict.get-value(min-edge.a), node-dict.get-value(min-edge.b))

            # new node added to tree
            new-node = 
              if visited.get-value(min-edge.a):
                min-edge.b
              else:
                min-edge.a
              end

            # new edges to add to heap
            new-edges = remove(edge-dict.get-value(new-node), min-edge)

            new-heap = fold(
              lam(acc, elt): 
                insert(elt, acc, edge-cmp)
              end, heap-without-min, new-edges)

            link(min-edge, h(new-heap, visited.set(new-node, true)))
        end
    end
  end

  visited = fold(
    lam(acc, elt): 
      acc.set(elt, false)
    end, [SD.string-dict: ], get-distinct-nodes(graph))

  cases (List) graph:
    | empty => empty
    | link(f, r) => 
      h(fold(
          lam(acc, elt): 
            insert(elt, acc, edge-cmp)
          end, mt, edge-dict.get-value(f.a)),
        visited.set(f.a, true))
  end
end

fun get-min-edge(
    heap :: Heap<Edge>, 
    node-dict :: SD.StringDict<Element>) -> {Heap<Edge>; Option<Edge>}:
  doc: ```consumes a min-heap of edges in a graph and a well-formed string dictionary of
       Elements that represent nodes already connected in the graph, and returns 
       the minimum edge that does not create a cycle in the graph.```
  cases (Heap) heap:
    | mt => {mt; none}
    | node(v, l, r) =>
      if is-in-same-set(node-dict.get-value(v.a), node-dict.get-value(v.b)):
        get-min-edge(remove-min(heap, edge-cmp), node-dict)
      else:
        {remove-min(heap, edge-cmp); some(get-min(heap))}
      end
  end
where:
  get-min-edge(mt, [SD.string-dict: ]) is {mt; none}
  get-min-edge(mt, [SD.string-dict: "A", elem("A", none)]) is {mt; none}
  get-min-edge(
    node(edge("A", "B", 10), node(edge("B", "C", 10), mt, mt), mt), 
    [SD.string-dict: "A", elem("A", none), "B", elem("B", none), "C", elem("B", none)])
    is {node(edge("B", "C", 10), mt, mt); some(edge("A", "B", 10))}

  a-elem = elem("A", none)
  sd1 = [SD.string-dict: "A", a-elem, "B", elem("B", some(a-elem)), "C", elem("B", none)]
  get-min-edge(node(edge("A", "B", 10), node(edge("B", "C", 10), mt, mt), mt), sd1)
    is {mt; some(edge("B", "C", 10))}

  b-elem = elem("B", some(a-elem))
  sd2 = [SD.string-dict: "A", a-elem, "B", b-elem, "C", elem("C", some(b-elem))]
  get-min-edge(
    node(edge("A", "B", 5), node(edge("B", "C", 7), mt, mt), node(edge("A", "C", 9), mt, mt)), sd2)
    is {mt; none}
end

fun get-edge-dict(graph :: Graph) -> SD.StringDict<List<Edge>>:
  doc: ```consumes a node and a graph and returns a string dictionary where each
       node maps to a list of all edges connected to that node.```
  nodes = get-distinct-nodes(graph)

  fold(
    lam(sd, n): 
      sd.set(n, get-edges-of-node(graph, n))
    end, [SD.string-dict: ], nodes)
where:
  get-edge-dict(empty) is [SD.string-dict: ]
  get-edge-dict([list: edge("A", "B", 10)]) 
    is [SD.string-dict: 
    "A", [list: edge("A", "B", 10)],
    "B", [list: edge("A", "B", 10)]]
  get-edge-dict([list: edge("A", "B", 10), edge("C", "B", 10)]) 
    is [SD.string-dict: 
    "C", [list: edge("C", "B", 10)],
    "B", [list: edge("C", "B", 10), edge("A", "B", 10)],
    "A", [list: edge("A", "B", 10)]]
  get-edge-dict([list: edge("A", "B", 10), edge("C", "B", 10), edge("A", "C", 10)]) 
    is [SD.string-dict: 
    "C", [list: edge("A", "C", 10), edge("C", "B", 10)],
    "B", [list: edge("C", "B", 10), edge("A", "B", 10)],
    "A", [list: edge("A", "C", 10), edge("A", "B", 10)]]
  get-edge-dict([list: 
      edge("A", "B", 10), edge("C", "A", 10), edge("A", "D", 10),
      edge("E", "A", 10), edge("A", "F", 10), edge("E", "F", 10)]) 
    is [SD.string-dict: 
    "F", [list: edge("E", "F", 10), edge("A", "F", 10)],
    "E", [list: edge("E", "F", 10), edge("E", "A", 10)],
    "D", [list: edge("A", "D", 10)],
    "C", [list: edge("C", "A", 10)],
    "B", [list: edge("A", "B", 10)],
    "A", [list: 
      edge("A", "F", 10), edge("E", "A", 10), edge("A", "D", 10),
      edge("C", "A", 10), edge("A", "B", 10)]]
end

fun get-edges-of-node(graph :: Graph, n :: String) -> List<Edge>:
  doc: ```consumes a graph and a string representing a node and returns a list
       of all edges in the graph that are connected to the node.```
  fold(
    lam(acc, elt):
      if (elt.a == n) or (elt.b == n):
        link(elt, acc)
      else:
        acc
      end
    end, empty, graph)
where:
  get-edges-of-node(empty, "A") is empty
  get-edges-of-node([list: edge("A", "B", 10)], "A") is [list: edge("A", "B", 10)]
  get-edges-of-node([list: edge("A", "B", 10)], "B") is [list: edge("A", "B", 10)]
  get-edges-of-node([list: edge("A", "B", 10), edge("C", "B", 10), edge("A", "C", 10)], "C")
    is [list: edge("A", "C", 10), edge("C", "B", 10)]
  get-edges-of-node([list: edge("A", "B", 10), edge("C", "B", 10), edge("A", "C", 10)], "D")
    is empty
  get-edges-of-node([list: 
      edge("A", "B", 10), edge("C", "A", 10), edge("A", "D", 10),
      edge("E", "A", 10), edge("A", "F", 10), edge("E", "F", 10)], "A")
    is [list: 
    edge("A", "F", 10), edge("E", "A", 10), edge("A", "D", 10),
    edge("C", "A", 10), edge("A", "B", 10)]
end

fun edge-cmp(e1 :: Edge, e2 :: Edge) -> Boolean:
  doc: ```consumes two edges, e1 and e2, and returns true if the e1
       has a lower weight than e2.```
  e1.weight < e2.weight
where:
  edge-cmp(edge("A", "B", 10), edge("C", "D", 5)) is false
  edge-cmp(edge("A", "B", 10), edge("C", "D", 10)) is false
  edge-cmp(edge("A", "B", -5), edge("C", "D", -10)) is false
  edge-cmp(edge("A", "B", 10), edge("C", "D", 15)) is true
  edge-cmp(edge("A", "B", -5), edge("C", "D", 0)) is true
  edge-cmp(edge("A", "B", -5), edge("C", "D", 5)) is true
end

#### Other functions ####

fun get-rand-weight() -> Number:
  doc: ```consumes a number, max-weight, and returns a number that has an absolute
       value less or equal to max-weight.```
  if num-random(2) == 1:
    num-random(MAX-WEIGHT + 1)
  else:
    num-random(MAX-WEIGHT + 1) * -1
  end
where:
  num-abs(get-rand-weight()) <= MAX-WEIGHT is true
  num-abs(get-rand-weight()) <= MAX-WEIGHT is true
  num-abs(get-rand-weight()) <= MAX-WEIGHT is true
  num-abs(get-rand-weight()) <= MAX-WEIGHT is true
end

fun generate-input(num-vertices :: Number) -> Graph:
  doc: ```consumes a number and returns a graph with the specified number of vertices.```
  vertices = range(0, num-vertices).map(lam(n): string-from-code-point(n + 65) end)

  # a grpah with less than 2 vertices contains no edges
  if vertices.length() < 2:
    empty
  else:
    # creates spanning graph 

    # the use of .rest and .first is justified bc the list is garunteed to be of at 
    # least length 2
    first-edge = edge(vertices.first, vertices.rest.first, num-random(11))
    spanning-graph = fold(
      lam(acc, elt): 
        # fetches random node from graph
        random-edge = acc.get(num-random(acc.length()))

        linking-node =
          if num-random(2) == 1:
            random-edge.a
          else:
            random-edge.b
          end

        link(edge(linking-node, elt, get-rand-weight()), acc)
      end, [list: first-edge], vertices.rest.rest)

    # add 0 to n - 1 more edges to graph
    fold(
      lam(acc, elt): 
        node1 = vertices.get(num-random(vertices.length()))

        # select node2 randomly from list of vertices w/o node1
        node2 = remove(vertices, node1).get(num-random(vertices.length() - 1))

        rand-weight = get-rand-weight()

        # the code point of the first node of the edge must be less than that of 
        # the second to garuntee well-formed input
        new-edge =
          if node1 < node2:
            edge(node1, node2, rand-weight)
          else:
            edge(node2, node1, rand-weight)
          end

        link(new-edge, acc)
      end, spanning-graph, range(0, num-random(num-vertices)))
  end
end

fun mst-cmp(graph :: Graph, mst-a :: Graph, mst-b :: Graph) -> Boolean:
  doc: ```consumes a well-formed graph and two purported MSTs of the graph, and 
       returns true exactly when the two solutions are both trees, spanning, have 
       the same weight, and only contain edges in the original graph.```
  (is-tree(mst-a) and is-tree(mst-b))
  and 
  (spanning(mst-a, graph) and spanning(mst-b, graph)) 
  and 
  (get-weight(mst-a) == get-weight(mst-b))
  and 
  (contains-valid-edges(mst-a, graph) and contains-valid-edges(mst-b, graph))
end

fun contains-valid-edges(mst :: Graph, graph :: Graph) -> Boolean:
  doc: ```consumes two graphs, one a purported MST of the other, and returns 
       true if the MST only contains edges from the original graph.```
  foldl(lam(acc, elt): member(graph, elt) and acc end, true, mst)
where:
  contains-valid-edges(empty, empty) is true
  contains-valid-edges(empty, [list: edge("A", "B", 10)]) is true
  contains-valid-edges([list: edge("A", "B", 10)], empty) is false
  contains-valid-edges([list: edge("A", "C", 10)], [list: edge("A", "B", 10)]) is false
  contains-valid-edges(
    [list: edge("A", "C", 10)], 
    [list: edge("A", "B", 10), edge("A", "C", 5)]) is false
  contains-valid-edges(
    [list: edge("A", "C", 10)], 
    [list: edge("A", "B", 10), edge("C", "A", 10)]) is true
end

INPUT-SIZE = 50
MAX-VERTICES = 40

fun sort-o-cle(mst-alg-a :: (Graph -> Graph), mst-alg-b :: (Graph -> Graph)) -> Boolean:
  doc: ```Comparative oracle for two mst algorithms; consumes two functions that purportedly
       produce MSTs and returns true if they satisfy mst-cmp over an input of manually and
       randomly generated graphs.```
  random-input = fold(
    lam(acc, elt): 
      link(generate-input(num-random(MAX-VERTICES + 1)), acc)
    end, empty, range(0, INPUT-SIZE + 1))

  empty-case = empty
  simple-case = [list: edge("A", "B", 1)]
  linear-case = [list: edge("A", "B", 1), edge("B", "C", 2), edge("C", "D", 3)]
  negative-weight-case = 
    [list: 
      edge("A", "B", -4), edge("B", "C", 3), 
      edge("C", "D", -2), edge("A", "D", 1)]
  circular-case = 
    [list: 
      edge("A", "B", 4), edge("B", "C", 3), 
      edge("C", "D", 2), edge("A", "D", 1)]
  star-case = 
    [list: 
      edge("F", "A", 5), edge("A", "B", 4), edge("A", "C", 3), 
      edge("A", "D", 2), edge("E", "A", 1)]
  multi-edge-case = 
    [list: edge("A", "B", 3), edge("A", "B", 2), edge("A", "B", 1)]
  full-graph-case = 
    [list: 
      edge("A", "B", 1), edge("A", "C", 1), edge("A", "D", 1),
      edge("B", "C", 1), edge("B", "D", 1), edge("C", "D", 1)]
  input = [list: 
    empty-case, 
    linear-case, 
    circular-case, 
    circular-case, 
    star-case, 
    multi-edge-case].append(random-input)
  fold(
    lam(acc, elt): 
      acc and mst-cmp(elt, mst-alg-a(elt), mst-alg-b(elt))
    end, true, input)
end
