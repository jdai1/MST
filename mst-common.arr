use context essentials2021
include shared-gdrive("mst-definitions.arr", "1Nc7LeRp7S8mnqF6pQMRJvQfYqUooD0lw")

provide: *, type * end
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# Write data bindings here that you'll need for tests in 
# both mst-code.arr and mst-tests.arr

import string-dict as SD
import lists as L

MAX-WEIGHT = 10

#### FileSystem: count, lst-same-els ####

fun count<A>(target :: A, a :: List<A>) -> Number:
  el-checker = lam(el, cnt):
    if el == target:
      cnt + 1
    else:
      cnt
    end
  end
  a.foldl(el-checker, 0)
end

fun lst-same-els<A>(a :: List<A>, b :: List<A>) -> Boolean:
  fun same-count(el, acc):
    acc and (count(el, a) == count(el, b))
  end
  (a.length() == b.length()) and a.foldl(same-count, true)
end

#### Heap implementation from Lab ####

data Heap<A>:
  | mt
  | node(value :: A, l :: Heap<A>, r :: Heap<A>)
end

fun insert<A>(elt :: A, h :: Heap<A>, cmp :: (A, A -> Boolean)) -> Heap:
  doc: ```Takes in an elt and a proper Heap h and produces
       a proper Heap that contains the added elt.```
  cases (Heap) h:
    | mt => node(elt, mt, mt)
    | node(v, l, r) =>
      inserted = insert(elt, r, cmp)
      if cmp(v, inserted.value):
        node(v, inserted, l)
      else:
        node(inserted.value, change-value-of-heap(inserted, v), l)
      end
  end
where:
  insert(13, mt, {(x, y): x < y}) is node(13, mt, mt)
  insert("13", mt, {(x, y): string-length(x) < string-length(y)}) is node("13", mt, mt)

  insert(13, node(1, 
      node(2, 
        node(3, mt, mt), 
        node(5, mt, mt)), 
      node(8, 
        node(10, mt, mt), 
        node(12, mt, mt))), {(x, y): x < y}) is 
  node(1, 
    node(8, node(12, node(13, mt, mt), mt), node(10, mt, mt)), 
    node(2, node(3, mt, mt), node(5, mt, mt)))

  insert(7, node(1, 
      node(2, 
        node(3, mt, mt), 
        node(5, mt, mt)), 
      node(8, 
        node(10, mt, mt), 
        node(12, mt, mt))), {(x, y): x < y}) is
  node(1, 
    node(7, node(8, node(12, mt, mt), mt), node(10, mt, mt)), 
    node(2, node(3, mt, mt), node(5, mt, mt)))

  insert(edge("A", "B", 0), node(edge("A", "B", 1), 
      node(edge("C", "D", 2), 
        node(edge("D", "E", 3), mt, mt), 
        node(edge("D", "B", 5), mt, mt)), 
      node(edge("E", "F", 8), 
        node(edge("A", "F", 10), mt, mt), 
        node(edge("E", "B", 12), mt, mt))), {(x, y): x.weight < y.weight}) is
  node(edge("A", "B", 0), 
    node(edge("A", "B", 1), 
      node(edge("E", "F", 8), node(edge("E", "B", 12), mt, mt), mt), 
      node(edge("A", "F", 10), mt, mt)), 
    node(edge("C", "D", 2), 
      node(edge("D", "E", 3), mt, mt), 
      node(edge("D", "B", 5), mt, mt)))

  insert(edge("C", "G", 10), node(edge("C", "I", -5), 
      node(edge("C", "H", 8), node(edge("C", "G", 10), mt, mt), mt), 
      node(edge("A", "C", -5), node(edge("C", "D", 7), mt, mt), mt)), 
    {(x, y): x.weight < y.weight}) is
  node(edge("A", "C", -5), 
    node(edge("C", "I", -5), node(edge("C", "G", 10), mt, mt), node(edge("C", "D", 7), mt, mt)), 
    node(edge("C", "H", 8), node(edge("C", "G", 10), mt, mt), mt))


end

fun change-value-of-heap<A>(h :: Heap<A>, elt :: A) -> Heap:
  doc: ```Consumes a heap and an element and returns a new heap with the 
       root value changed to elt.```
  cases (Heap) h:
    | mt => mt
    | node(v, l, r) =>
      node(elt, l, r)
  end
where:
  change-value-of-heap(mt, 0) is mt
  change-value-of-heap(node(edge("A", "B", 10), mt, mt), edge("C", "D", 5)) 
    is node(edge("C", "D", 5), mt, mt)
  change-value-of-heap(node("5", node("7", mt, mt), mt), "6") 
    is node("6", node("7", mt, mt), mt)
  change-value-of-heap(node(14, node(8, mt, node(21, mt, mt)), node(13, node(20, mt, mt), mt)), 10) 
    is node(10, node(8, mt, node(21, mt, mt)), node(13, node(20, mt, mt), mt))
end

fun remove-min<A>(h :: Heap, cmp :: (A, A -> Boolean)) -> Heap:
  doc: ```Given a proper, non-empty Heap h, removes its minimum element.```
  amp-heap = amputate-bottom-left(h)
  e-and-h = change-value-of-heap(amp-heap.heap, amp-heap.elt)
  rebalanced-heap = rebalance(e-and-h)
  reorder(rebalanced-heap, cmp)
where:
  remove-min(node(5, mt, mt), {(x, y): x < y})
    is mt
  remove-min(
    node(7, 
      node(8, node(14, mt, mt), node(21, mt, mt)), 
      node(13, node(20, mt, mt), mt)), {(x, y): x < y})
    is node(8, node(13, node(20, mt, mt), mt), node(14, node(21, mt, mt), mt))
  remove-min(node(0, 
      node(1, node(8, node(12, mt, mt), mt), node(10, mt, mt)), 
      node(2, node(3, mt, mt), node(5, mt, mt))), {(x, y): x < y})
    is 
  node(1, 
    node(2, node(3, mt, mt), node(5, mt, mt)), 
    node(8, node(10, mt, mt), node(12, mt, mt)))
  remove-min(node("5", node("75", mt, mt), mt), {(x, y): string-length(x) < string-length(y)})
    is node("75", mt, mt)
  remove-min(node(edge("A", "B", 5), 
      node(edge("B", "C", 7), mt, mt), 
      node(edge("C", "D", 7), mt, mt)), {(x, y): x.weight < y.weight})
    is node(edge("C", "D", 7), node(edge("B", "C", 7), mt, mt), mt)
end

fun rebalance<A>(h :: Heap<A>) -> Heap<A>:
  doc: ```Given a Heap h, switches all children along the leftmost path```
  cases (Heap) h:
    | mt => mt
    | node(v, l, r) =>
      node(v, r, rebalance(l))
  end
where:
  rebalance(mt) is mt
  rebalance(node(1, mt, mt)) is node(1, mt, mt)
  rebalance(node("1", node("2", mt, mt), node("3", mt, mt))) 
    is node("1", node("3", mt, mt), node("2", mt, mt))
  rebalance(node(14, node(8, mt, node(21, mt, mt)), node(13, node(20, mt, mt), mt))) 
    is node(14, node(13, node(20, mt, mt), mt), node(8, node(21, mt, mt), mt))
  rebalance(node(edge("A", "B", 1), 
      node(edge("A", "C", 5), node(edge("B", "C", 7), mt, mt), mt), 
      node(edge("C", "D", 10), mt, mt)))
    is 
  node(edge("A", "B", 1), 
    node(edge("C", "D", 10), mt, mt),
    node(edge("A", "C", 5), mt,  node(edge("B", "C", 7), mt, mt)))
end

##### already implemented functions #####

fun get-min<A>(h :: Heap<A>) -> A:
  doc: ```Takes in a proper, non-empty Heap h and produces the
       minimum Number in h.```
  cases (Heap) h:
    | mt => raise("Invalid input: empty heap")
    | node(val, l, r) => val
  end
where:
  get-min(mt) raises "Invalid"
  get-min(node(1, mt, mt)) is 1
  get-min(node("1", node("2", mt, mt), node("3", mt, mt))) 
    is "1"
  get-min(node(8, node(14, mt, node(21, mt, mt)), node(13, node(20, mt, mt), mt))) 
    is 8
end

data Amputated<A>:
  | elt-and-heap(elt :: A, heap :: Heap<A>)
end

fun amputate-bottom-left(h :: Heap) -> Amputated:
  doc: ```Given a Heap h, produes an Amputated that contains the 
       bottom-left element of h, and h with the bottom-left element removed.```
  cases (Heap) h:
    | mt => raise("Invalid input: empty heap")
    | node(value, left, right) =>
      cases (Heap) left:
        | mt => elt-and-heap(value, mt)
        | node(_, _, _) => 
          rec-amputated = amputate-bottom-left(left)
          elt-and-heap(rec-amputated.elt,
            node(value, rec-amputated.heap, right))
      end
  end
end

fun reorder<A>(h :: Heap<A>, cmp :: (A, A -> Boolean)) -> Heap<A>:
  doc: ```Given a Heap h, where only the top node is misplaced,
       produces a Heap with the same elements but in proper order.```
  cases(Heap) h:
    | mt => mt # Do nothing (empty heap)
    | node(val, lh, rh) =>
      cases(Heap) lh:
        | mt => h # Do nothing (no children)
        | node(lval, llh, lrh) =>
          cases(Heap) rh:
            | mt => # Just left child
              ask:
                | cmp(val, lval) then: h # Do nothing
                | otherwise: node(lval, reorder(node(val, llh, lrh), cmp), rh) # Swap left
              end
            | node(rval, rlh, rrh) => # Both children
              ask:
                | cmp(val, lval) and cmp(val, rval) then: h # Do nothing
                | cmp(lval, rval) then: node(lval, reorder(node(val, llh, lrh), cmp), rh) # Swap left
                | not(cmp(lval, rval)) then: node(rval, lh, reorder(node(val, rlh, rrh), cmp)) # Swap right
              end
          end
      end
  end
where:
  reorder(mt, {(x, y): x < y}) is mt
  reorder(node(1, mt, mt), {(x, y): x < y}) is node(1, mt, mt)
  reorder(node(1, node(2, mt, mt), node(3, mt, mt)), {(x, y): x < y}) 
    is node(1, node(2, mt, mt), node(3, mt, mt))
  reorder(node(3, node(1, mt, mt), node(2, mt, mt)), {(x, y): x < y}) 
    is node(1, node(3, mt, mt), node(2, mt, mt))
  reorder(node(2, node(1, mt, mt), node(3, mt, mt)), {(x, y): x < y}) 
    is node(1, node(2, mt, mt), node(3, mt, mt))
  reorder(node(14, node(8, mt, node(21, mt, mt)), node(13, node(20, mt, mt), mt)), {(x, y): x < y})
    is node(8, node(14, mt, node(21, mt, mt)), node(13, node(20, mt, mt), mt))
  reorder(node("14", 
      node("8", mt, node("21", mt, mt)), 
      node("13", node("20", mt, mt), mt)), 
    {(x, y): string-to-number(x).value < string-to-number(y).value})
    is node("8", node("14", mt, node("21", mt, mt)), node("13", node("20", mt, mt), mt))
end

#### Union-Find implementation from class ####

data Element: elem(v, ref parent :: Option<Element>) end

fun name-of(e :: Element) -> Element:
  cases (Option) e!parent:
    | none => e
    | some(ele) => 
      name-of(ele)
  end
end

fun is-in-same-set(e1 :: Element, e2 :: Element):
  n1 = name-of(e1)
  n2 = name-of(e2)
  n1 <=> n2
end

fun union(e1 :: Element, e2 :: Element):
  n1 = name-of(e1)
  n2 = name-of(e2)
  if n1 <=> n2:
    n1 
  else:
    n1!{parent: some(n2)}
  end
end

#### Helper functions for MST ####

fun add-edges(
    result :: Graph, 
    edges :: List<Edge>, 
    node-dict :: SD.StringDict<Element>) -> Graph:
  doc: ```consumes a graph, a list of edges sorted by weight, and a string 
       dictionary mapping each node in the graph to a corresponding Element 
       and returns an MST of the graph using Kruskal's algorithm.```
  fold(
    lam(acc, elt): 
      {a; b} = {node-dict.get-value(elt.a); node-dict.get-value(elt.b)}
      if is-in-same-set(a, b) block:
        acc
      else:
        union(a, b)
        link(elt, acc)
      end
    end, empty, edges)
where:
  add-edges(empty, empty, get-node-dict(empty)) is empty

  edges1 = [list: edge("A", "B", 1)]
  add-edges(empty, edges1, get-node-dict(edges1)) is edges1

  edges2 = [list: 
    edge("A", "B", -4), edge("C", "D", -2), 
    edge("A", "D", 1),  edge("B", "C", 3)]
  add-edges(empty, edges2, get-node-dict(edges2)) 
    is [list: edge("A", "D", 1), edge("C", "D", -2), edge("A", "B", -4)]

  edges3 = [list: 
    edge("E", "A", 1), edge("A", "D", 2), edge("A", "C", 3), 
    edge("A", "B", 4) ,edge("F", "A", 5)]
  add-edges(empty, edges3, get-node-dict(edges3))
    is [list: 
    edge("F", "A", 5), edge("A", "B", 4), edge("A", "C", 3), 
    edge("A", "D", 2), edge("E", "A", 1)]

  edges4 = [list: edge("A", "B", 10), edge("B", "C", 10), edge("A", "C", 10)]
  get-weight(add-edges(empty, edges4, get-node-dict(edges4))) is 20

  edges5 = [list: 
    edge("A", "B", 1), edge("B", "D", 1), edge("A", "C", 1),
    edge("C", "D", 2), edge("A", "D", 2), edge("B", "C", 2)]
  get-weight(add-edges(empty, edges5, get-node-dict(edges5))) is 3
end

fun get-distinct-nodes(graph :: Graph) -> List<String>:
  doc: ```consumes a graph and returns a list of strings representing the
       unqiue nodes in the graph.```
  distinct(
    fold(
      lam(acc, elt): 
        link(elt.b, link(elt.a, acc)) 
      end, empty, graph))
where:
  get-distinct-nodes(empty) is empty
  get-distinct-nodes([list: edge("A", "B", 10)]) is [list: "B", "A"]
  get-distinct-nodes([list: edge("A", "B", 10), edge("A", "B", 12)]) is [list: "B", "A"]
  get-distinct-nodes([list: edge("A", "B", 10), edge("B", "C", 10), edge("A", "C", 10)]) 
    is [list: "C", "B", "A"]
  get-distinct-nodes([list: edge("A", "B", 10), edge("B", "C", 10)]) 
    is [list: "C", "B", "A"]
  get-distinct-nodes([list:
      edge("A", "B", 10), edge("C", "A", 10), edge("A", "D", 10),
      edge("E", "A", 10), edge("A", "F", 10), edge("E", "F", 10)]) 
    is [list: "F", "E", "D", "C", "B", "A"]
end

fun get-node-dict(graph :: Graph) -> SD.StringDict<Element>:
  doc: ```consumes a graph and returns a string dictionary mapping each
       node's string value to its corresponding Element.```
  nodes = get-distinct-nodes(graph)

  fold(
    lam(acc, elt): 
      acc.set(elt, elem(elt, none)) 
    end, 
    [SD.string-dict: ], 
    nodes)
where:
  get-node-dict(empty) is%(equal-now)  [SD.string-dict: ]
  get-node-dict([list: edge("A", "B", 10), edge("B", "C", 10)]) 
    is%(equal-now) 
  [SD.string-dict: 
    "C", elem("C", none), 
    "B", elem("B", none), 
    "A", elem("A", none)]
  get-node-dict([list: edge("C", "D", 10)]) 
    is%(equal-now) 
  [SD.string-dict: 
    "D", elem("D", none), 
    "C", elem("C", none)]
  get-node-dict([list: 
      edge("F", "A", 5), edge("A", "B", 4), edge("A", "C", 3), 
      edge("A", "D", 2), edge("E", "A", 1)])
    is%(equal-now) 
  [SD.string-dict: 
    "F", elem("F", none), "A", elem("A", none), "B", elem("B", none),
    "C", elem("C", none), "D", elem("D", none), "E", elem("E", none)]
end

fun is-connected(mst :: Graph) -> Boolean:
  doc: ```consumes a graph and returns true if all edges of the graph is connected.```
  cases (List) mst block:
    | empty => 
      true
    | link(f, r) =>
      node-dict = get-node-dict(mst)
      fold(
        lam(acc, elt): 
          {a; b} = {node-dict.get-value(elt.a); node-dict.get-value(elt.b)}
          union(a, b)
        end, false, mst)

      parent-node = name-of(node-dict.get-value(f.a))
      fold(
        lam(acc, elt): 
          is-in-same-set(node-dict.get-value(elt), parent-node) and acc
        end, true, node-dict.keys().to-list())
  end
where:
  is-connected(empty) is true
  is-connected([list: edge("A", "B", 10)]) is true
  is-connected([list: edge("A", "B", 10), edge("B", "C", 10)]) is true
  is-connected([list: edge("A", "B", 10), edge("A", "C", 10)]) is true
  is-connected([list: edge("A", "B", 10), edge("D", "C", 10), edge("B", "C", 10)]) is true
  is-connected([list: edge("A", "B", 10), edge("C", "D", 10)]) is false
  is-connected([list: 
      edge("A", "B", 10), edge("C", "A", 10), edge("A", "D", 10),
      edge("E", "A", 10), edge("E", "F", 10)]) is true
  is-connected([list: 
      edge("A", "B", 10), edge("C", "A", 10),
      edge("A", "D", 10), edge("E", "F", 10)]) is false
end

fun get-weight(mst :: Graph) -> Number:
  doc: ```consumes a graph and returns the total weight of all edges
       in the graph.```
  fold(lam(acc, elt): elt.weight + acc end, 0, mst)
where:
  get-weight(empty) is 0
  get-weight([list: edge("A", "B", 10)]) is 10
  get-weight([list: edge("A", "B", 10), edge("A", "C", 5)]) is 15
  get-weight([list: edge("A", "B", 10), edge("A", "C", -5)]) is 5
  get-weight([list: edge("A", "B", -10), edge("A", "C", -5)]) is -15
end

fun is-tree(mst :: Graph) -> Boolean:
  doc: ```consumes a graph and returns true if it is a tree.```
  is-connected(mst) and not(has-cycle(mst))
where:
  is-tree(empty) is true
  is-tree([list: edge("A", "B", 10)]) is true
  is-tree([list: edge("A", "B", 10), edge("D", "C", 10) ,edge("B", "C", 10)]) is true
  is-tree([list: edge("A", "B", 10), edge("A", "C", 10) ,edge("B", "C", 10)]) is false
  is-tree([list: edge("A", "B", 10), edge("C", "D", 10)]) is false
  is-tree([list: 
      edge("A", "B", 10), edge("C", "A", 10), edge("A", "D", 10),
      edge("E", "A", 10), edge("A", "F", 10), edge("E", "F", 10)]) is false
end

fun spanning(mst :: Graph, graph :: Graph) -> Boolean:
  doc: ```consumes two graphs, one a purported MST of the other, and returns 
       true if the MST spans the original graph and no other nodes.```
  lst-same-els(get-distinct-nodes(mst), get-distinct-nodes(graph))
where:
  spanning(empty, empty) is true
  spanning([list: edge("A", "B", 10)], empty) is false
  spanning([list: edge("A", "B", 10)], [list: edge("A", "B", 10)]) is true
  spanning([list: edge("A", "B", 10)], [list: edge("B", "A", 10)]) is true
  spanning([list: edge("A", "B", 10)], [list: edge("B", "A", 10), edge("C", "A", 10)]) is false
  spanning(
    [list: edge("B", "A", 10), edge("C", "B", 20)], 
    [list: 
      edge("B", "A", 10), edge("A", "B", 15), 
      edge("C", "A", 10), edge("C", "B", 20)]) is true
  spanning([list: 
      edge("A", "B", 10), edge("C", "A", 10), edge("A", "D", 10),
      edge("E", "A", 10), edge("E", "F", 10)],
    [list: 
      edge("A", "B", 10), edge("C", "A", 10), edge("A", "D", 10),
      edge("E", "A", 10), edge("A", "F", 10), edge("E", "F", 10)]) is true
end

fun has-cycle(mst :: Graph) -> Boolean:
  doc: ```consumes a graph and returns true if the grpah contains no cycles.```
  node-dict = get-node-dict(mst)
  fold(
    lam(acc, elt): 
      {a; b} = {node-dict.get-value(elt.a); node-dict.get-value(elt.b)}
      if is-in-same-set(a, b) block:
        true
      else:
        union(a, b)
        acc
      end
    end, false, mst)
where:
  has-cycle(empty) is false
  has-cycle([list: edge("A", "B", 10)]) is false
  has-cycle([list: edge("A", "B", 10), edge("C", "B", 10)]) is false
  has-cycle([list: edge("A", "B", 10), edge("B", "A", 10)]) is true
  has-cycle([list: 
      edge("A", "B", 10), edge("C", "A", 10), edge("A", "D", 10),
      edge("E", "A", 10), edge("A", "F", 10), edge("E", "F", 10)]) is true
  has-cycle([list: 
      edge("A", "B", 10), edge("C", "A", 10), edge("A", "D", 10),
      edge("A", "F", 10), edge("E", "F", 10)]) is false
end

#### Property based testing for generate-input ####

# implementation specific testing
fun valid-generate-input(num-vertices :: Number, output :: Graph) -> Boolean:
  doc: ```consumes a number, representing the number of vertices the graph 
       should have and the output graph and returns if the randomly
       generated graph is valid.```
  if num-vertices < 2:
    output == empty
  else:
    vertices = range(0, num-vertices).map(lam(n): string-from-code-point(n + 65) end)
    valid-edges = fold(
      lam(acc, elt): 
        member(vertices, elt.a) and 
        member(vertices, elt.b) and 
        (elt.a < elt.b) and 
        (num-abs(elt.weight) <= MAX-WEIGHT) and acc
      end, true, output)
    connected = is-connected(output)
    is-spanning = lst-same-els(get-distinct-nodes(output), vertices)
    valid-edges and connected and is-spanning
  end
where:
  valid-generate-input(0, empty) is true
  valid-generate-input(1, empty) is true
  valid-generate-input(3, [list: 
      edge("A", "B", 10), edge("A", "C", 10), edge("A", "C", 10)]) is true
  valid-generate-input(3, [list: 
      edge("A", "B", 10), edge("A", "C", 10), edge("A", "C", -11)]) is false
  valid-generate-input(3, [list: edge("A", "B", 10)]) is false
  valid-generate-input(3, [list: edge("A", "B", 10), edge("C", "D", 10)]) is false
  valid-generate-input(5, [list: 
      edge("A", "B", 10), edge("B", "C", 10), edge("C", "D", 10), edge("D", "E", 10)]) is true
  valid-generate-input(5, [list: 
      edge("A", "B", 10), edge("B", "C", 10), edge("C", "D", 10), edge("D", "F", 10)]) is false
  valid-generate-input(5, [list: 
      edge("A", "B", 10), edge("B", "C", 10), edge("D", "E", 10)]) is false
  valid-generate-input(5, [list: 
      edge("A", "B", 10), edge("B", "C", 10), edge("D", "C", 10)]) is false
end

#### Example functions to test sort-o-cle ####

fun get-spanning-tree(graph :: Graph) -> Graph:
  doc: ```consumes a graph and returns a random spanning graph.```
  random-edges = L.shuffle(graph)
  
  node-dict = get-node-dict(graph)

  add-edges(empty, random-edges, node-dict)
where:
  get-spanning-tree(empty) is empty
  
  get-spanning-tree([list: edge("A", "B", 10)]) is [list: edge("A", "B", 10)]
  
  input1 = [list: 
      edge("A", "B", 10), edge("C", "A", 10), edge("A", "D", 10),
      edge("E", "A", 10), edge("A", "F", 10), edge("E", "F", 10)]
  spanning(get-spanning-tree(input1), input1) and is-tree(get-spanning-tree(input1)) is true
  
  input2 = [list: 
    edge("E", "I", 0), edge("E", "J", -6), edge("A", "B", -6), edge("A", "H", 2), 
    edge("A", "I", 0), edge("I", "J", 5), edge("D", "J", 5), edge("E", "J", -2), 
    edge("E", "I", 5), edge("E", "H", 8), edge("F", "G", -7), edge("C", "F", 0), 
    edge("B", "E", 6), edge("A", "D", 0), edge("A", "C", 7), edge("A", "B", 7)]
  spanning(get-spanning-tree(input2), input2) and is-tree(get-spanning-tree(input2)) is true
  
  input3 = [list: 
      edge("F", "A", 5), edge("A", "B", 4), edge("A", "C", 3), 
      edge("A", "D", 2), edge("E", "A", 1)]
  lst-same-els(get-spanning-tree(input3), input3) is true
end

fun get-random-edges(graph :: Graph) -> Graph:
  doc: ```consumes a graph and returns a graph consisting of random edges
       from the original graph.```
  L.shuffle(graph).take(num-random(graph.length() + 1))
end


