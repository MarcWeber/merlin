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

type extension = Parsetree.signature * Parsetree.signature

let ident = Ident.create "_"

let parse_sig str =
  let buf = Lexing.from_string str in
  Chunk_parser.interface Lexer.token buf

let type_sig env sg =
  let sg = Typemod.transl_signature env sg in
  sg.Typedtree.sig_type

let ext_lwt =
  parse_sig
  "module Lwt : sig
    val un_lwt : 'a Lwt.t -> 'a
    val in_lwt : 'a Lwt.t -> 'a Lwt.t
    val to_lwt : 'a -> 'a Lwt.t
    val finally' : 'a Lwt.t -> unit Lwt.t -> 'a Lwt.t
    val un_stream : 'a Lwt_stream.t -> 'a
    val unit_lwt : unit Lwt.t -> unit Lwt.t
  end",
  parse_sig
    "val (>>) : unit Lwt.t -> 'a Lwt.t -> 'a Lwt.t
     val raise_lwt : exn -> 'a Lwt.t"

let ext_any =
  parse_sig
  "module Any : sig
    val val' : 'a
  end",
  []

let ext_js =
  parse_sig
  "module Js : sig
    val un_js : 'a Js.t -> 'a
    val un_meth : 'a Js.meth -> 'a
  end",
  []
  
let registry = [ext_lwt;ext_any]

let register env =
  (* Log errors ? *)
  let try_type sg' = try type_sig env sg' with exn -> [] in
  let fakes, tops =
    List.split (List.map (fun (fake,top) -> try_type fake, try_type top) registry)
  in
  let env = Env.add_signature (List.concat tops) env in
  let env = Env.add_module ident (Types.Mty_signature (List.concat fakes)) env in
  env
