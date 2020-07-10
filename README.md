# SIMPLE SAX-like parsing of the XML DOM term

Predicates for simple parsing of XMLns DOM compounds that was
loaded by [`load_xml(Stream, XML, [dialect(xmlns)])`](https://www.swi-prolog.org/pldoc/doc_for?object=load_xml/3)
call.

## Installing

Execute `pack_install` in your environment.

## Usage

The main predicate is `sax_parse_stream(+Stream, +Context, -Result, +Options:list)`, which
unifies Results with the result of calling `sax//2` parser
over xml document stored in the Stream. Options are handed over to [`load_xml/3`](https://www.swi-prolog.org/pldoc/doc_for?object=load_xml/3)
call. Durring parsing the predicate invokes the user specified processing predicates handing them over the `Context` term to distinguish
between different contexts. The predicates are multifile predicates and must be loaded into program by the user.
The elements that are not handled by user predicates does not cause failure of parsing.

Following predicates are executed:

* `element_start(+Context, +PathStack:list(term), +Prefix:atom, +ElementName:atom, +Attributes:list(term))//` is nondet

  Invoked by `sax` parser for each element in the DOM. `Context` is provided by the client when invking sax parser.
  `PathStack` is reverse list of ancestor elements preceding the current element, each element is represented by compound
  `NamespacePrefix:ElementName:Atttributes`. `Prefix` is namespace identifier either resolved by `prefix_namespace/2`
  predicate or full IRI of the namespace. `ElementName` and `Attributes` then represents the element itself.
  
* `element_start(+Context, +Prefix:atom : +ElementName:atom, +Attributes:list(term))//` is nondet

   Alternative simplified version of `element_start//5`. Sax parser tries to unify `element_start//5` then `element_start//3`

* `element_end(+Context, +PathStack:list(term), +Prefix:atom, +ElementName:atom)//` is nondet

  Invoked by sax parser for each element in the DOM after the elements children element were parsed.
  `Context` is provided by the client when invking sax parser.
  `PathStack` is reverse list of ancestor elements preceding the current element, each element is represented by compound
  `NamespacePrefix:ElementName:Atttributes`. `Prefix` is namespace identifier either resolved by `prefix_namespace/2`
  predicate or full IRI of the namespace. `ElementName` then represents the element itself.

* element_end(+Context, +Prefix:atom : +ElementName:atom// is nondet
  
  Alternative simplified version of `element_end//4`. sax_parser tries to unify `element_end//4` then `element_end//2`.
  
* `prefix_namespace(+NamespacePrefix:atom, +NamespaceIri:atom)` is nondet
  Unifies `NamespacePrefix` with the full `NamespaceIri` definition. User's code can define additional prefix to simplify
  sax parsing.

* `text(+Context, PathStack:list(term), +Text:atom)` is nondet
   Invoked by sax_parser when element taxt is evaluated.
   Similar to `element_start//5` but works on text nodes.

* `text(+Context, +Text:atom)` is nondet
   As `text//3` but does not provides `PathStack` to improve readibility.
