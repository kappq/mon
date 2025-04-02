import combinators.{map_res, tag, take_while_m_n}
import gleam/int
import mon.{type IResult, parse}

pub type Color {
  Color(red: Int, green: Int, blue: Int)
}

pub fn hex_color_test() {
  let assert Ok(#("", Color(red: 47, green: 20, blue: 223))) =
    hex_color("#2F14DF")
}

fn hex_color(input: String) -> IResult(String, Color) {
  use #(input, _) <- parse(tag("#")(input))
  use #(input, red) <- parse(hex_primary(input))
  use #(input, green) <- parse(hex_primary(input))
  use #(input, blue) <- parse(hex_primary(input))

  Ok(#(input, Color(red:, green:, blue:)))
}

fn hex_primary(input: String) -> IResult(String, Int) {
  map_res(take_while_m_n(2, 2, is_hex_digit), from_hex)(input)
}

fn from_hex(input: String) -> Result(Int, Nil) {
  int.base_parse(input, 16)
}

fn is_hex_digit(grapheme: String) -> Bool {
  case grapheme {
    "0"
    | "1"
    | "2"
    | "3"
    | "4"
    | "5"
    | "6"
    | "7"
    | "8"
    | "9"
    | "a"
    | "b"
    | "c"
    | "d"
    | "e"
    | "f"
    | "A"
    | "B"
    | "C"
    | "D"
    | "E"
    | "F" -> True
    _ -> False
  }
}
