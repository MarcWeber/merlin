(* {{{ COPYING *(

  This file is part of Merlin, an helper for ocaml editors

  Copyright (C) 2013  Frédéric Bour  <frederic.bour(_)lakaban.net>
                      Thomas Refis  <refis.thomas(_)gmail.com>
                      Simon Castellan  <simon.castellan(_)iuwt.fr>

  Permission is hereby granted, free of charge, to any person obtaining a
  copy of this software and associated documentation files (the "Software"),
  to deal in the Software without restriction, including without limitation the
  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
  sell copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  The Software is provided "as is", without warranty of any kind, express or
  implied, including but not limited to the warranties of merchantability,
  fitness for a particular purpose and noninfringement. In no event shall
  the authors or copyright holders be liable for any claim, damages or other
  liability, whether in an action of contract, tort or otherwise, arising
  from, out of or in connection with the software or the use or other dealings
  in the Software.

)* }}} *)

type io = Json.json Stream.t * (Json.json -> unit)

val make : input:in_channel -> output:out_channel -> io
val log  : dest:out_channel -> io -> io

val return : Json.json -> Json.json
val fail   : exn -> Json.json

(* HACK. Break circular reference:
 * Error_report uses Protocol to format error positions.
 * Protocol uses Error_report to format standard errors.
 *)
val error_catcher : (exn -> (Location.t * Json.json) option) ref

val make_pos : int * int -> Lexing.position
val pos_to_json : Lexing.position -> Json.json
val pos_of_json : Json.json -> Lexing.position
val with_location : Location.t -> (string * Json.json) list -> Json.json
