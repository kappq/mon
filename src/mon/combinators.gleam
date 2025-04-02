import gleam/bool
import gleam/list.{Continue, Stop}
import gleam/string
import mon.{type Parser, ParseError}

/// Match an exact pattern.
pub fn tag(tag: String) -> Parser(String, String) {
  fn(input) {
    case string.starts_with(input, tag) {
      True -> Ok(#(string.drop_start(input, string.length(tag)), tag))
      False -> Error(ParseError(input:, kind: mon.Tag))
    }
  }
}

/// Match graphemes while the given predicate returns `True`.
pub fn take_while(predicate: fn(String) -> Bool) -> Parser(String, String) {
  fn(input) {
    Ok(
      input
      |> string.to_graphemes
      |> list.fold_until(#(input, ""), fn(acc, grapheme) {
        let #(input, output) = acc
        case predicate(grapheme) {
          True -> Continue(#(string.drop_start(input, 1), output <> grapheme))
          False -> Stop(acc)
        }
      }),
    )
  }
}

/// Like `take_while`, but the length of the output must be in the range
/// specified by `m` and `n` (inclusive).
pub fn take_while_m_n(
  m: Int,
  n: Int,
  predicate: fn(String) -> Bool,
) -> Parser(String, String) {
  fn(input) {
    input
    |> string.to_graphemes
    |> list.fold_until(#(input, "", m, n), fn(acc, grapheme) {
      let #(input, output, m, n) = acc
      case bool.and(predicate(grapheme), n > 0) {
        True ->
          Continue(#(
            string.drop_start(input, 1),
            output <> grapheme,
            m - 1,
            n - 1,
          ))
        _ -> Stop(acc)
      }
    })
    |> fn(acc) {
      let #(input, output, m, _) = acc
      case m <= 0 {
        True -> Ok(#(input, output))
        False -> Error(ParseError(input:, kind: mon.TakeWhileMN))
      }
    }
  }
}

/// Apply a `Result` returning function over the result of a `Parser`.
pub fn map_res(
  parser: Parser(i, a),
  apply fun: fn(a) -> Result(b, _),
) -> Parser(i, b) {
  fn(input) {
    case parser(input) {
      Ok(#(input, output)) ->
        case fun(output) {
          Ok(output) -> Ok(#(input, output))
          Error(_) -> Error(ParseError(input:, kind: mon.MapRes))
        }
      Error(e) -> Error(e)
    }
  }
}
