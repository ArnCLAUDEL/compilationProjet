{
open Parser
exception Eof

let keyword_table = Hashtbl.create 53
let _ = 
    List.iter (fun (kwr, tok) -> Hashtbl.add keyword_table kwd tok)
              [ "ALL", ALL;
                "AND", ALL;
                "AS", AS;
                "BETWEEN", BETWEEN;
                "BY", BY;
                "CROSS", CROSS;
                "DISTINCT", DISTINCT;
                "FALSE", FALSE;
                "FOR", FOR;
                "FROM", FROM;
                "FULL", FULL;
                "GROUP", GROUP;
                "HAVING", HAVING;
                "INNER", INNER;
                "IS", IS;
                "JOIN", JOIN;
                "LEFT", LEFT;
                "LOWER", LOWER;
                "NOT", NOT;
                "NULL", NULL;
                "ON", ON;
                "OR", OR;
                "OUTER", OUTER;
                "RIGHT", RIGHT;
                "SELECT", SELECT;
                "SUBSTRING", SUBSTRING;
                "TRUE", TRUE;
                "UNKNOW", UNKNOW;
                "UPPER", UPPER;
                "WHERE", WHERE;
             ]
let string_of_list l = 
  let sol l s  = match l with
      | [] -> s
      | h :: q -> sol q s ^ h
  in 
  sol l "" ;;

}


(* Déclaration du dictionnaire (regexp -> terminal/token) *)

rule anlex = parse
  | [' ' '\t' '\n' '\r']                  { SPACE }
  | "--"                                  { comlex lexbuf }
  | '*'                                   { ASTERISK }
  | "\""                                  { QQUOTE }
  | '.'                                   { DOT }
  | '('                                   { LPAR }
  | ')'                                   { RPAR }
  | '+'                                   { PLUS }
  | '-'                                   { MINUS }
  | '/'                                   { SLASH }
  | "||"                                  { PPIPE }
  | ','                                   { COMMA }
  | '='                                   { EQ }
  | "<>"                                  { NEQ }
  | '<'                                   { LT }
  | '>'                                   { GT }
  | "<="                                  { LE }
  | ">="                                  { GE }
  | ['0'-'9']+ as lxm                     { INT(int_of_string lxm) }
  | ['0'-'9']+ '.' ['0'-'9']+ |
    '.'  ['0'-'9']+ 
  | '''                                   { STRING(string_of_list (stringlex [] lexbuf)) }
  | ['a'-'z' 'A'-'Z'] ['a'-'z' 'A'-'Z' '0'-'9'] as lxm
                                          { try 
                                              Hashtbl.find keyword_table lxm
                                            with Not_found -> ID(lxm) 
                                          }
  | eof                                   { raise Eof }
  | _ as lxm                              { 
                                             Printf.eprintf "Unknown character '%c': ignored\n" lxm; flush stderr;
                                              anlex lexbuf
                                          }

and comlex = parse
  | "\n"                     { anlex lexbuf }
  | _                        { comlex lexbuf }

and stringlex l = parse
  | "''" as lxm                   { stringlex (lxm :: l) lexbuf }
  | '''                             { l }
  | _ as lxm                        { stringlex (lxm :: l) lexbuf }

'"'[^'"']*'"'