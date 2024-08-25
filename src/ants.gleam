import gleam/erlang
import gleam/erlang/process.{type Subject}
import gleam/float
import gleam/iterator
import gleam/result
import gleam/string

//import gleam_community/ansi
//import tulip

import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/pair.{first, second}
import glector.{type Vector2}

//import gleam/iterator
import gleam/string_builder.{type StringBuilder}

const cant_ants = 140

//const window_size = 50
const horizontal_size = 170

const float_horizontal_size = 170.0

const vertical_size = 52

const float_vertical_size = 52.0

const frame_in_nanosecond = 16_666_667

pub const start_background_color = "\u{001B}[107m"

//5 chars

pub const stop_background_color = "\u{001B}[49m"

//5 chars

pub const start_bold_black = "\u{001B}[1;30m"

//7 chars

pub const default_color_style = "\u{001B}[22;39m"

//8 chars

pub const start_bold_red = "\u{001B}[1;31m"

//7 chars

//pub const top_bottom_border = start_background_color
//  <> start_bold_black
//  <> "===================================================="
//  <> default_color_style
//  <> stop_background_color
//  <> "\n"

fn get_top_bottom_border() -> String {
  start_background_color
  <> start_bold_black
  |> string.pad_right(horizontal_size + 9, "=")
  <> default_color_style
  <> stop_background_color
  <> "\n"
}

pub const left_right_border = start_bold_black <> "|" <> default_color_style

//16 chars

pub const left_border = start_background_color <> left_right_border

//21 chars
pub const right_border = left_right_border <> stop_background_color <> "\n"

//22 chars
pub const left_border_size = 21

//pub const no_ants_line = left_border
//  <> "                                                  "
//  <> right_border

fn get_no_ants_line() -> String {
  left_border
  |> string.pad_right(horizontal_size + 22, " ")
  <> right_border
}

//92 chars

pub const ant_char = start_bold_red <> "X" <> default_color_style

//16
pub const ant_size = 16

pub type Ant {
  Ant(pos: glector.Vector2, vel: glector.Vector2, last_update: Int)
}

pub type Message {
  RequestPosition(reply_with: process.Subject(Vector2))
  RequestVelocity(reply_with: process.Subject(Vector2))
  CheckCollide(with: Ant, reply_with: process.Subject(Result(Vector2, Nil)))
  NoMessage
}

pub fn main() {
  //io.println(start_background_color)
  //io.println(top_bottom_border)
  //io.println(left_right_border)
  //io.println(no_ants_line)
  //io.println(ant_char)
  //io.println(stop_background_color)
  //io.println("Prueba sin background")
  //io.debug(string.length("\u{001B}[22;39m"))
  //
  //  let ant_subjects = list.repeat(spawn_ant(), cant_ants)
  //

  let render_subject = process.new_subject()

  iterator.repeatedly(spawn_ant)
  |> iterator.take(cant_ants)
  |> iterator.to_list
  |> render_main(
    render_time: erlang.system_time(erlang.Nanosecond),
    own_subject: render_subject,
  )
}

pub fn spawn_ant() -> Subject(Message) {
  let response_subject: Subject(Subject(Message)) = process.new_subject()

  process.start(
    fn() {
      let ant_subject = process.new_subject()
      process.send(response_subject, ant_subject)
      ant_main(
        Ant(
          pos: glector.Vector2(
            float.random() *. int.to_float(horizontal_size),
            float.random() *. int.to_float(vertical_size),
          ),
          vel: glector.Vector2(
            { float.random() -. 0.5 } *. 25.0,
            { float.random() -. 0.5 } *. 25.0,
          ),
          last_update: erlang.system_time(erlang.Nanosecond),
        ),
        ant_subject,
      )
    },
    False,
  )

  case process.receive(response_subject, 9999) {
    Ok(subject) -> subject
    Error(_) -> {
      panic as "Couldn't get the subject from an ant process"
    }
  }
}

pub fn ant_main(ant: Ant, subject: Subject(Message)) {
  let mail = result.unwrap(process.receive(subject, 1), NoMessage)

  case mail {
    RequestPosition(sub) -> {
      process.send(sub, ant.pos)
      ant_main(ant, subject)
    }
    RequestVelocity(sub) -> {
      process.send(sub, ant.vel)
      ant_main(ant, subject)
    }
    CheckCollide(_ant2, sub) -> {
      process.send(sub, Error(Nil))
      ant_main(ant, subject)
    }
    NoMessage -> {
      let time_now = erlang.system_time(erlang.Nanosecond)
      let float_time_factor =
        int.to_float(time_now - ant.last_update) /. 1_000_000_000.0

      let precise_vel = glector.scale(ant.vel, float_time_factor)

      let new_pos = glector.add(ant.pos, precise_vel)

      let new_all_x = case new_pos.x >. float_horizontal_size {
        True -> #(2.0 *. float_horizontal_size -. new_pos.x, -1.0 *. ant.vel.x)
        False -> {
          case new_pos.x <. 0.0 {
            True -> #(-1.0 *. new_pos.x, -1.0 *. ant.vel.x)
            False -> #(new_pos.x, ant.vel.x)
          }
        }
      }

      let new_all_y = case new_pos.y >. float_vertical_size {
        True -> #(2.0 *. float_vertical_size -. new_pos.y, -1.0 *. ant.vel.y)
        False -> {
          case new_pos.y <. 0.0 {
            True -> #(-1.0 *. new_pos.y, -1.0 *. ant.vel.y)
            False -> #(new_pos.y, ant.vel.y)
          }
        }
      }

      ant_main(
        Ant(
          pos: glector.Vector2(first(new_all_x), first(new_all_y)),
          vel: glector.Vector2(second(new_all_x), second(new_all_y)),
          last_update: time_now,
        ),
        subject,
      )
    }
  }
}

pub fn render_main(
  ants ant_subjects: List(Subject(Message)),
  render_time last_render: Int,
  own_subject own_subject: Subject(Vector2),
) {
  list.each(ant_subjects, fn(ant_subject) {
    process.send(ant_subject, RequestPosition(own_subject))
  })

  let sorted_positions: List(#(Int, Int)) =
    list.sort(get_all_positions(own_subject), fn(a, b) {
      case int.compare(second(a), second(b)) {
        order.Eq -> int.compare(first(b), first(a))
        result -> result
      }
    })

  get_all_lines(sorted_positions)
  |> io.println()

  let finish_render = erlang.system_time(erlang.Nanosecond)
  let render_time_diff = finish_render - last_render

  case render_time_diff >= frame_in_nanosecond {
    True -> Nil
    False -> process.sleep(frame_in_nanosecond - render_time_diff / 1000)
  }

  render_main(ant_subjects, erlang.system_time(erlang.Nanosecond), own_subject)
}

//fn print_full_string(positions: List(#(Int, Int))) {
//  iterator.range(from: -1, to: window_size)
//  |> iterator.each(fn(_a) { tulip.print(245, "=") })
//
//  io.println("")
//
//  iterator.range(from: 0, to: window_size - 1)
//  |> iterator.each(fn(i) {
//    tulip.print(245, "=")
//    print_line(get_positions_per_line(positions, i), 0)
//    tulip.println(245, "=")
//  })
//
//  iterator.range(from: -1, to: window_size)
//  |> iterator.each(fn(_a) { tulip.print(245, "=") })
//
//  io.println("")
//}
//
//fn print_line(posx: List(Int), from: Int) {
//  case posx {
//    [x, ..rest] -> {
//      case x == from {
//        True -> {
//          tulip.print(160, "X")
//          print_line(rest, from + 1)
//        }
//        False -> {
//          iterator.range(from, x - 1)
//          |> iterator.each(fn(_a) { tulip.print(255, "·") })
//          tulip.print(160, "X")
//          print_line(rest, x + 1)
//        }
//      }
//    }
//    [] -> {
//      iterator.range(from, window_size)
//      |> iterator.each(fn(_a) { tulip.print(255, "·") })
//    }
//  }
//}

//----------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------

pub fn get_all_lines(positions: List(#(Int, Int))) -> String {
  string_builder.from_string(get_top_bottom_border())
  |> get_all_lines_acc(positions, 0, _)
  |> string_builder.append(get_top_bottom_border())
  |> string_builder.to_string()
}

fn get_all_lines_acc(
  positions: List(#(Int, Int)),
  line: Int,
  acc: StringBuilder,
) -> StringBuilder {
  case line == vertical_size {
    True -> acc
    False -> {
      let #(result, rest) = get_positions_per_line(positions, line)
      get_line(result)
      |> string_builder.append(acc, _)
      |> get_all_lines_acc(rest, line + 1, _)
    }
  }
}

pub fn get_line(line_positions: List(Int)) -> String {
  case line_positions {
    [] -> get_no_ants_line()
    _ -> left_border <> get_line_acc(line_positions, 0, "") <> right_border
  }
}

fn get_line_acc(
  line_positions: List(Int),
  printed_ants: Int,
  acc: String,
) -> String {
  case line_positions {
    [] ->
      string.pad_right(
        acc,
        horizontal_size - printed_ants + printed_ants * ant_size,
        " ",
      )
    [pos, ..rest] -> {
      string.pad_right(
        acc,
        pos - printed_ants + printed_ants * ant_size - 1,
        " ",
      )
      |> string.append(ant_char)
      |> get_line_acc(rest, printed_ants + 1, _)
    }
  }
}

//----------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------

pub fn get_positions_per_line(
  positions: List(#(Int, Int)),
  line: Int,
) -> #(List(Int), List(#(Int, Int))) {
  //Lista de x de posiciones en la linea line, y el resto de la lista (asumiendo esta ordenada)
  get_positions_per_line_acc(positions, line, [])
}

fn get_positions_per_line_acc(
  positions: List(#(Int, Int)),
  line: Int,
  acc: List(Int),
) -> #(List(Int), List(#(Int, Int))) {
  case positions {
    [#(_, y), ..rest] if y < line -> get_positions_per_line_acc(rest, line, acc)
    [#(x, y), ..rest] if y == line -> {
      case acc {
        //Se filtra esta mierdaaaa
        [x_in_list, ..] if x_in_list == x ->
          get_positions_per_line_acc(rest, line, acc)
        _ -> get_positions_per_line_acc(rest, line, [x, ..acc])
      }
    }
    _ -> #(acc, positions)
  }
}

pub fn get_all_positions(from_subject: Subject(Vector2)) -> List(#(Int, Int)) {
  get_all_positions_acc(from_subject, [])
}

fn get_all_positions_acc(subject: Subject(Vector2), list: List(#(Int, Int))) {
  case process.receive(subject, 100) {
    Ok(position) ->
      get_all_positions_acc(subject, [
        #(float.truncate(position.x), float.truncate(position.y)),
        ..list
      ])
    Error(_) -> list
  }
}
