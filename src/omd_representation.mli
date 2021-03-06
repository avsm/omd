module R :
  sig
    type key = String.t
    type 'a t = 'a Map.Make(String).t
    val empty : 'a t
    val is_empty : 'a t -> bool
    val mem : key -> 'a t -> bool
    val add : key -> 'a -> 'a t -> 'a t
    val singleton : key -> 'a -> 'a t
    val remove : key -> 'a t -> 'a t
    val merge :
      (key -> 'a option -> 'b option -> 'c option) -> 'a t -> 'b t -> 'c t
    val compare : ('a -> 'a -> int) -> 'a t -> 'a t -> int
    val equal : ('a -> 'a -> bool) -> 'a t -> 'a t -> bool
    val iter : (key -> 'a -> unit) -> 'a t -> unit
    val fold : (key -> 'a -> 'b -> 'b) -> 'a t -> 'b -> 'b
    val for_all : (key -> 'a -> bool) -> 'a t -> bool
    val exists : (key -> 'a -> bool) -> 'a t -> bool
    val filter : (key -> 'a -> bool) -> 'a t -> 'a t
    val partition : (key -> 'a -> bool) -> 'a t -> 'a t * 'a t
    val cardinal : 'a t -> int
    val bindings : 'a t -> (key * 'a) list
    val min_binding : 'a t -> key * 'a
    val max_binding : 'a t -> key * 'a
    val choose : 'a t -> key * 'a
    val split : key -> 'a t -> 'a t * 'a option * 'a t
    val find : key -> 'a t -> 'a
    val map : ('a -> 'b) -> 'a t -> 'b t
    val mapi : (key -> 'a -> 'b) -> 'a t -> 'b t
  end
class ref_container :
  object
    val mutable c : (string * string) R.t
    method add_ref : R.key -> string -> string -> unit
    method get_ref : R.key -> (string * string) option
    method get_all : (string * (string * string)) list
  end
type element =
  | H1 of t
  | H2 of t
  | H3 of t
  | H4 of t
  | H5 of t
  | H6 of t
  | Paragraph of t
  | Text of string
  | Emph of t
  | Bold of t
  | Ul of t list
  | Ol of t list
  | Ulp of t list
  | Olp of t list
  | Code of name * string
  | Code_block of name * string
  | Br
  | Hr
  | NL
  | Url of href * t * title
  | Ref of ref_container * name * string * fallback
  | Img_ref of ref_container * name * alt * fallback
  | Html of string
  | Html_block of string
  | Html_comment of string
  | Blockquote of t
  | Img of alt * src * title
  | X of
      < name : string;
        to_html : ?indent:int -> (t -> string) -> t -> string option;
        to_sexpr : (t -> string) -> t -> string option;
        to_t : t -> t option >
and fallback = string
and name = string
and alt = string
and src = string
and href = string
and title = string
and t = element list

type tok =
    Ampersand (* one & *)
  | Ampersands of int (* [Ampersands(n)] is (n+2) consecutive occurrences of & *)
  | At (* @ *)
  | Ats of int (* @@.. *)
  | Backquote (* ` *)
  | Backquotes of int (* ``.. *)
  | Backslash (* \\ *)
  | Backslashs of int (* \\\\.. *)
  | Bar (* | *)
  | Bars of int (* ||.. *)
  | Caret (* ^ *)
  | Carets of int (* ^^.. *)
  | Cbrace (* } *)
  | Cbraces of int (* }}.. *)
  | Colon (* : *)
  | Colons of int (* ::.. *)
  | Comma (* , *)
  | Commas of int (* ,,.. *)
  | Cparenthesis (* ) *)
  | Cparenthesiss of int (* )).. *)
  | Cbracket (* ] *)
  | Cbrackets of int (* ]].. *)
  | Dollar (* $ *)
  | Dollars of int (* $$.. *)
  | Dot (* . *)
  | Dots of int (* .... *)
  | Doublequote (* \034 *)
  | Doublequotes of int (* \034\034.. *)
  | Exclamation (* ! *)
  | Exclamations of int (* !!.. *)
  | Equal (* = *)
  | Equals of int (* ==.. *)
  | Greaterthan (* > *)
  | Greaterthans of int (* >>.. *)
  | Hash (* # *)
  | Hashs of int (* ##.. *)
  | Lessthan (* < *)
  | Lessthans of int (* <<.. *)
  | Minus (* - *)
  | Minuss of int (* --.. *)
  | Newline (* \n *)
  | Newlines of int (* \n\n.. *)
  | Number of string
  | Obrace (* { *)
  | Obraces of int (* {{.. *)
  | Oparenthesis (* ( *)
  | Oparenthesiss of int (* ((.. *)
  | Obracket (* [ *)
  | Obrackets of int (* [[.. *)
  | Percent (* % *)
  | Percents of int (* %%.. *)
  | Plus (* + *)
  | Pluss of int (* ++.. *)
  | Question (* ? *)
  | Questions of int (* ??.. *)
  | Quote (* ' *)
  | Quotes of int (* ''.. *)
  | Semicolon (* ; *)
  | Semicolons of int (* ;;.. *)
  | Slash (* / *)
  | Slashs of int (* //.. *)
  | Space (*  *)
  | Spaces of int (* .. *)
  | Star (* * *)
  | Stars of int (* **.. *)
  | Tab (* \t *)
  | Tabs of int (* \t\t.. *)
  | Tilde (* ~ *)
  | Tildes of int (* ~~.. *)
  | Underscore (* _ *)
  | Underscores of int (* __.. *)
  | Word of string
  | Tag of extension
(** Lexer's tokens. If you want to use the parser with an extended
    lexer, you may use the constructor [Tag] to implement
    the parser's extension. In the parser, [Tag] is used (at least)
    3 times in order to represent metadata or to store data.

    The integers carried by constructors means that the represented
    character appears (n+2) times. So, [Ampersand(0)] is "&&".
    Notably, this allows to use the property that in the match
    case [Ampersand _ ->], we know there are at least 2 ampersands.
    This is particularly useful for some characters, such as newlines
    and spaces. It's not useful for all of them indeed but it has
    been designed this way for the sake of uniformity (one doesn't
    want to know by heart which constructor have that "at least 2"
    property and which haven't).
*)

and extension = t -> tok list -> tok list -> (t * tok list * tok list) option
(** A function that takes the current state of the parser's data and
    returns None if nothing has been changed, otherwise it returns
    the new state.  The current state of the parser's data is [(r,
    p, l)] where [r] is the result so far, [p] is the list of the
    previous tokens (it's typically empty or contains information on
    how many newlines we've just seen), and [l] is the remaining
    tokens to parse. *)

type extensions = extension list
(** One must use this type to extend the parser. It's a list of
    functions of type [extension]. They are processed in order (the
    head is applied first), so be careful about it. If you use it
    wrong, it will behave wrong. *)

val loose_compare : t -> t -> int
(** [loose_compare t1 t2] returns [0] if [t1] and [t2]
    are equivalent, otherwise it returns another number. *)

val normalise_md : t -> t
(** [normalise_md md] returns a copy of [md] where some elements
    have been factorized. *)
