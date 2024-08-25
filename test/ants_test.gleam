import ants
import gleam/list

//import glector

//import gleam/io
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
//pub fn hello_world_test() {
//  1
//  |> should.equal(1)
//}

pub fn get_line_positions_test() {
  list_positions
  |> ants.get_positions_per_line(3)
  |> should.equal(#(
    [64, 32, 16, 8, 4, 2, 3],
    list.filter(list_positions, fn(pair) {
      case pair {
        #(_, 3) -> False
        _ -> True
      }
    }),
  ))
}

//const list_positions_vectors = [
//  glector.Vector2(1.3, 1.1), glector.Vector2(2.4, 1.2),
//  glector.Vector2(4.5, 1.3), glector.Vector2(8.6, 1.4),
//  glector.Vector2(16.7, 1.5), glector.Vector2(32.8, 1.6),
//  glector.Vector2(64.9, 1.7), glector.Vector2(2.3, 2.1),
//  glector.Vector2(2.4, 2.2), glector.Vector2(4.5, 2.3),
//  glector.Vector2(8.6, 2.4), glector.Vector2(16.7, 2.5),
//  glector.Vector2(32.8, 2.6), glector.Vector2(64.9, 2.7),
//  glector.Vector2(3.3, 3.1), glector.Vector2(2.4, 3.2),
//  glector.Vector2(4.5, 3.3), glector.Vector2(8.6, 3.4),
//  glector.Vector2(16.7, 3.5), glector.Vector2(32.8, 3.6),
//  glector.Vector2(64.9, 3.7), glector.Vector2(4.3, 4.1),
//  glector.Vector2(2.4, 4.2), glector.Vector2(4.5, 4.3),
//  glector.Vector2(8.6, 4.4), glector.Vector2(16.7, 4.5),
//  glector.Vector2(32.8, 4.6), glector.Vector2(64.9, 4.7),
//  glector.Vector2(5.3, 5.1), glector.Vector2(2.4, 5.2),
//  glector.Vector2(4.5, 5.3), glector.Vector2(8.6, 5.4),
//  glector.Vector2(16.7, 5.5), glector.Vector2(32.8, 5.6),
//  glector.Vector2(64.9, 5.7), glector.Vector2(6.3, 6.1),
//  glector.Vector2(2.4, 6.2), glector.Vector2(4.5, 6.3),
//  glector.Vector2(8.6, 6.4), glector.Vector2(16.7, 6.5),
//  glector.Vector2(32.8, 6.6), glector.Vector2(64.9, 6.7),
//  glector.Vector2(7.3, 7.1), glector.Vector2(2.4, 7.2),
//  glector.Vector2(4.5, 7.3), glector.Vector2(8.6, 7.4),
//  glector.Vector2(16.7, 7.5), glector.Vector2(32.8, 7.6),
//  glector.Vector2(64.9, 7.7), glector.Vector2(8.3, 8.1),
//  glector.Vector2(2.4, 8.2), glector.Vector2(4.5, 8.3),
//  glector.Vector2(8.6, 8.4), glector.Vector2(16.7, 8.5),
//  glector.Vector2(32.8, 8.6), glector.Vector2(64.9, 8.7),
//]

const list_positions = [
  #(0, 0), #(2, 0), #(4, 0), #(8, 0), #(16, 0), #(32, 0), #(64, 0), #(1, 1),
  #(2, 1), #(4, 1), #(8, 1), #(16, 1), #(32, 1), #(64, 1), #(2, 2), #(2, 2),
  #(4, 2), #(8, 2), #(16, 2), #(32, 2), #(64, 2), #(3, 3), #(2, 3), #(4, 3),
  #(8, 3), #(16, 3), #(32, 3), #(64, 3), #(4, 4), #(2, 4), #(4, 4), #(8, 4),
  #(16, 4), #(32, 4), #(64, 4), #(5, 5), #(2, 5), #(4, 5), #(8, 5), #(16, 5),
  #(32, 5), #(64, 5), #(6, 6), #(2, 6), #(4, 6), #(8, 6), #(16, 6), #(32, 6),
  #(64, 6), #(7, 7), #(2, 7), #(4, 7), #(8, 7), #(16, 7), #(32, 7), #(64, 7),
  #(8, 8), #(2, 8), #(4, 8), #(8, 8), #(16, 8), #(32, 8), #(64, 8),
]
