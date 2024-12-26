import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/order

pub type PriorityQueue(a) =
  List(Priority(a))

pub type Priority(a) =
  #(a, Option(Int))

pub fn new() -> PriorityQueue(a) {
  []
}

pub fn push_queue(queue: PriorityQueue(a), node: #(a, Option(Int))) {
  [node, ..queue]
  |> list.sort(fn(a, b) {
    case a.1, b.1 {
      Some(a), Some(b) -> int.compare(a, b)
      None, None -> order.Eq
      Some(_), None -> order.Lt
      None, Some(_) -> order.Gt
    }
  })
}

pub fn push_many(
  queue: PriorityQueue(a),
  nodes: List(#(a, Option(Int))),
  visited: PriorityQueue(a),
) {
  list.filter(nodes, fn(node) {
    !list.any(visited, fn(visited) { node.0 == visited.0 })
  })
  |> list.fold(queue, fn(acc, node) { push_queue(acc, node) })
}

pub fn pop(
  queue: PriorityQueue(a),
) -> #(Option(#(a, Option(Int))), PriorityQueue(a)) {
  case queue {
    [] -> #(None, [])
    [head, ..tail] -> #(Some(head), tail)
  }
}

/// Returns the smallest element in the queue
pub fn peek(
  queue: PriorityQueue(a),
) -> #(Option(#(a, Option(Int))), PriorityQueue(a)) {
  case queue {
    [] -> #(None, [])
    [head, ..tail] -> #(Some(head), tail)
  }
}
