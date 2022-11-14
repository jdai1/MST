use context essentials2021
include shared-gdrive("mst-definitions.arr", "1Nc7LeRp7S8mnqF6pQMRJvQfYqUooD0lw")

include my-gdrive("mst-common.arr")
import mst-prim, mst-kruskal, generate-input, mst-cmp, sort-o-cle
  from my-gdrive("mst-code.arr")
# END HEADER
# DO NOT CHANGE ANYTHING ABOVE THIS LINE
#
# Write your examples and tests in here. These should not be tests of
# implementation-specific details (e.g., helper functions).

check "generate-input":
  fold(
    lam(acc, elt): 
      valid-generate-input(elt, generate-input(elt)) and acc 
    end, true, range(0, 50))
end

#### Tests for mst-prim and mst-kruskal #####

check "mst: base cases":
  mst-kruskal(empty) is empty
  mst-prim(empty) is empty

  get-weight(mst-kruskal([list: edge("A", "B", 10)])) is 10
  get-weight(mst-prim([list: edge("A", "B", 10)])) is 10
end

check "mst: multi-edge":
  get-weight(mst-kruskal([list: edge("A", "B", 3), edge("A", "B", 2), edge("A", "B", 1)])) 
    is 1
  get-weight(mst-prim([list: edge("A", "B", 3), edge("A", "B", 2), edge("A", "B", 1)])) 
    is 1
end

check "mst: linear graph":
  get-weight(mst-kruskal([list: edge("A", "B", 10), edge("B", "C", 20), edge("C", "D", 30)])) 
    is 60
  get-weight(mst-prim([list: edge("A", "B", 10), edge("B", "C", 20), edge("C", "D", 30)])) 
    is 60
end

check "mst: star graph":
  get-weight(mst-kruskal([list: 
        edge("F", "A", 5), edge("A", "B", 4), edge("A", "C", 3), 
        edge("A", "D", 2), edge("E", "A", 1)])) is 15
  get-weight(mst-prim([list: 
        edge("F", "A", 5), edge("A", "B", 4), edge("A", "C", 3), 
        edge("A", "D", 2), edge("E", "A", 1)])) is 15
end

check "mst: decimal edges":
  get-weight(mst-kruskal([list: edge("A", "B", 1.1), edge("B", "C", 2.2), edge("C", "D", 3.3)])) 
    is 6.6
  get-weight(mst-prim([list: edge("A", "B", 1.1), edge("B", "C", 2.2), edge("C", "D", 3.3)])) 
    is 6.6
  
  get-weight(mst-kruskal([list: edge("A", "B", 1.1), edge("B", "C", -2.2), edge("A", "C", 2.2)])) 
    is -1.1
  get-weight(mst-prim([list: edge("A", "B", 1.1), edge("B", "C", -2.2), edge("A", "C", 2.2)])) 
    is -1.1
end

check "mst: triangle graph":
  # even weights
  get-weight(mst-kruskal(
      [list: edge("A", "B", 10), edge("A", "C", 10), edge("B", "C", 10)])) is 20
  get-weight(mst-prim(
      [list: edge("A", "B", 10), edge("A", "C", 10), edge("B", "C", 10)])) is 20

  # uneven weights
  get-weight(mst-kruskal(
      [list: edge("A", "B", 10), edge("A", "C", 20), edge("B", "C", 30)])) is 30
  get-weight(mst-prim(
      [list: edge("A", "B", 10), edge("A", "C", 20), edge("B", "C", 30)])) is 30

  get-weight(mst-kruskal(
      [list: edge("A", "B", 10), edge("A", "C", 10), edge("B", "C", 20)])) is 20
  get-weight(mst-prim(
      [list: edge("A", "B", 10), edge("A", "C", 10), edge("B", "C", 20)])) is 20
end

check "mst: full-graph":
  get-weight(mst-kruskal(
      [list: 
        edge("A", "B", 1), edge("A", "C", 2), edge("A", "D", 1),
        edge("B", "C", -3), edge("B", "D", 1),
        edge("C", "D", 1)
      ])) is -1
  get-weight(mst-prim(
      [list: 
        edge("A", "B", 1), edge("A", "C", 2), edge("A", "D", 1),
        edge("B", "C", -3), edge("B", "D", 1),
        edge("C", "D", 1)
      ])) is -1
end

check "mst: negative weights":
  # all negative weights
  get-weight(mst-kruskal(
      [list: edge("A", "B", -10), edge("A", "C", -20), edge("B", "C", -30)])) is -50
  get-weight(mst-prim(
      [list: edge("A", "B", -10), edge("A", "C", -20), edge("B", "C", -30)])) is -50

  # negative & positive weights
  get-weight(mst-kruskal(
      [list: 
        edge("A", "B", -40), edge("B", "C", 30), edge("C", "D", -20), edge("A", "D", 10)])) is -50
  get-weight(mst-prim(
      [list: 
        edge("A", "B", -40), edge("B", "C", 30), edge("C", "D", -20), edge("A", "D", 10)])) is -50
end

check "mst: more complicated cases":
  # case 1
  get-weight(mst-kruskal([list: 
        edge("A", "D", -1), edge("A", "E", -3), edge("B", "H", 6), 
        edge("E", "G", -3), edge("B", "F", 5), edge("C", "E", -4), 
        edge("B", "D", 3), edge("B", "C", 4), edge("A", "B", 9)])) is 3
  get-weight(mst-prim([list: 
        edge("A", "D", -1), edge("A", "E", -3), edge("B", "H", 6), 
        edge("E", "G", -3), edge("B", "F", 5), edge("C", "E", -4), 
        edge("B", "D", 3), edge("B", "C", 4), edge("A", "B", 9)])) is 3

  # case 2
  get-weight(mst-kruskal([list: 
        edge("G", "H", -7), edge("C", "G", -9), edge("C", "G", 10), edge("C", "H", 8),
        edge("C", "I", -5), edge("C", "D", 7), edge("A", "C", -5), edge("A", "B", 6), 
        edge("A", "F", 9), edge("D", "E", -8), edge("E", "J", 0), edge("E", "I", -7)])) is -26
  get-weight(mst-prim([list: 
        edge("G", "H", -7), edge("C", "G", -9), edge("C", "G", 10), edge("C", "H", 8),
        edge("C", "I", -5), edge("C", "D", 7), edge("A", "C", -5), edge("A", "B", 6), 
        edge("A", "F", 9), edge("D", "E", -8), edge("E", "J", 0), edge("E", "I", -7)])) is -26
end

#### Tests for mst-cmp ####

check "mst-cmp: empty":
  mst-cmp(empty, empty, empty) is true
end

check "mst-cmp: different order of edges":
  mst-cmp(
    [list: 
      edge("F", "A", 5), edge("A", "B", 4), edge("A", "C", 3), 
      edge("A", "D", 2), edge("E", "A", 1)],
    [list: 
      edge("A", "C", 3),  edge("A", "B", 4), edge("A", "D", 2), 
      edge("E", "A", 1), edge("F", "A", 5)],
    [list: 
      edge("F", "A", 5), edge("A", "B", 4), edge("A", "C", 3), 
      edge("A", "D", 2), edge("E", "A", 1)]) is true
end

check "mst-cmp: msts have different weights":
  mst-cmp(
    [list: edge("A", "B", 10)],
    [list: edge("A", "B", 10)],
    [list: edge("A", "B", 10)]) is true
  mst-cmp(
    [list: edge("A", "B", 10), edge("A", "B", 20)],
    [list: edge("A", "B", 10)],
    [list: edge("A", "B", 20)]) is false
  mst-cmp(
    [list: edge("A", "B", 10), edge("B", "C", 20), edge("A", "C", 30)],
    [list: edge("A", "B", 10), edge("B", "C", 20)],
    [list: edge("B", "C", 20), edge("A", "C", 30)]) is false
end

check "mst-cmp: tests if mst contains edges not in original graph":
  mst-cmp(
    [list: edge("A", "B", 10)],
    [list: edge("B", "A", 10)],
    [list: edge("A", "B", 10)]) is true
  mst-cmp(
    [list: edge("A", "B", 10)],
    [list: edge("A", "B", 8)],
    [list: edge("A", "B", 8)]) is false
  mst-cmp(
    [list: edge("A", "B", 10)],
    [list: edge("A", "B", 10)],
    [list: edge("C", "A", 10)]) is false
  mst-cmp(
    [list: edge("A", "B", 10), edge("B", "C", 20), edge("A", "C", 30)],
    [list: edge("A", "B", 10), edge("B", "C", 20)],
    [list: edge("B", "C", 20), edge("A", "C", 10)]) is false
end

check "mst-cmp: tests if mst is spanning":
  mst-cmp(
    [list: 
      edge("F", "A", 5), edge("A", "B", 4), edge("A", "C", 3), 
      edge("A", "D", 2), edge("E", "A", 1)],
    [list: edge("A", "C", 3),  edge("A", "B", 4)],
    [list: edge("F", "A", 5), edge("A", "D", 2)]) is false

  mst-cmp(
    [list: edge("A", "B", 10), edge("B", "C", 20), edge("A", "C", 30)],
    [list: edge("A", "B", 10), edge("B", "C", 20)],
    [list: edge("A", "C", 30)]) is false
end

check "mst-cmp: tests if mst is a tree":
  # contains cycle
  mst-cmp(
    [list: 
      edge("A", "B", 1), edge("A", "C", 1), edge("A", "D", 1),
      edge("B", "C", 1), edge("B", "D", 1), edge("C", "D", 1)],
    [list: edge("A", "B", 1), edge("A", "C", 1), edge("A", "D", 1),
      edge("B", "C", 1)],
    [list:  edge("A", "C", 1), edge("A", "D", 1),
      edge("B", "C", 1), edge("B", "D", 1)]) is false

  # not connected
  mst-cmp(
    [list: 
      edge("A", "B", 1), edge("A", "C", 1), edge("A", "D", 1),
      edge("B", "C", 1), edge("B", "D", 1), edge("C", "D", 1)],
    [list: edge("A", "B", 1), edge("C", "D", 1)],
    [list:  edge("A", "C", 1), edge("B", "D", 1)]) is false
end

check "oracle: mst-prim & mst-kruskal":
  sort-o-cle(mst-prim, mst-kruskal) is true
  sort-o-cle(mst-kruskal, mst-prim) is true
end

check "oracle: simple cases":
  # returns empty
  sort-o-cle(mst-prim, {(g): empty}) is false
  sort-o-cle({(g): empty}, mst-kruskal) is false
  
  # returns graph
  sort-o-cle({(g): g}, {(g): g}) is false
end

check "oracle: random spanning tree":
  # returns random spanning tree
  sort-o-cle(mst-prim, get-spanning-tree) is false
  sort-o-cle(get-spanning-tree, get-spanning-tree) is false
end

check "oracle: random graph":
  # returns random tree
  sort-o-cle(mst-prim, get-random-edges) is false
  sort-o-cle(get-random-edges, mst-prim) is false
end

