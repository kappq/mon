pub type Parser(i, o) =
  fn(i) -> IResult(i, o)

pub type IResult(i, o) =
  Result(#(i, o), ParseError(i))

pub type ParseError(i) {
  ParseError(input: i, kind: ErrorKind)
}

pub type ErrorKind {
  Tag
  TakeWhileMN
  MapRes
}

/// Like `result.try`, but works exclusively on `IResult`s.
pub fn parse(
  result: IResult(i, a),
  apply fun: fn(#(i, a)) -> IResult(i, b),
) -> IResult(i, b) {
  case result {
    Ok(x) -> fun(x)
    Error(e) -> Error(e)
  }
}
