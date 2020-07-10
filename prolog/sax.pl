:- module(sax, [
    attributes_key_value/3,     % +Name, +Attributes:list(term), -Value:atom
    sax_parse_stream/3,         % +Stream, +Context, -Result
    sax_parse_stream/4          % +Stream, +Context, -Result, +Options:list    
]).

%! <module> Simple API for XML 
%  Predicates for simple parsing of XMLns DOM compounds that was 
%  retrieved by =|load_xml(Stream, XML, [dialect(xmlns)])|= call

:- multifile 
    %! element_start(+Context, +PathStack:list(term), +Prefix:atom, +ElementName:atom, +Attributes:list(term))// is nondet
    %  Invoked by sax parser for each element in the DOM. Context is provided by the client when invking sax parser.
    %  PathStack is reverse list of ancestor elements preceding the current element, each element is represented by compound
    %  =|NamespacePrefix:ElementName:Atttributes|=. Prefix is namespace identifier either resolved by prefix_namespace/2 
    %  predicate or full IRI of the namespace. ElementName and Attributes then represents the element itself. 
    element_start//5,
    %! element_start(+Context, +Prefix:atom : +ElementName:atom, +Attributes:list(term))// is nondet
    %  Alternative simplified version of element_start//5. sax_parser tries to unify element_start//5 then element_start//3
    element_start//3,
    %! element_start(+Context, +PathStack:list(term), +Prefix:atom, +ElementName:atom// is nondet
    %  Invoked by sax parser for each element in the DOM after the elements children element were parsed. 
    %  Context is provided by the client when invking sax parser.
    %  PathStack is reverse list of ancestor elements preceding the current element, each element is represented by compound
    %  =|NamespacePrefix:ElementName:Atttributes|=. Prefix is namespace identifier either resolved by prefix_namespace/2 
    %  predicate or full IRI of the namespace. ElementName then represents the element itself. 
    element_end//4,
    %! element_start(+Context, +Prefix:atom : +ElementName:atom// is nondet
    %  Alternative simplified version of element_end//4. sax_parser tries to unify element_end//4 then element_end//2
    element_end//2,
    %! prefix_namespace(+NamespacePrefix:atom, +NamespaceIri:atom) is nondet
    %  Unifies NamespacePrefix with the full Namespace IRI definition. User's code can define additional prefix to simplify 
    %  sax parsing
    prefix_namespace/2,
    %! text(+Context, PathStack:list(term), +Text:atom) is nondet
    % Invoked by sax_parser when element taxt is evaluated. 
    % Similar to element_start//5 but works on text nodes. 
    text//3,
    %! text(+Context, +Text:atom) is nondet
    % As text//3 but does not provides PathStack to improve readibility
    text//2.

%! attributes_key_value( +Attributes:list(term), +Name, -Value:atom) is semidet
%  Suceeds if Value is unified with value of attribute in list Attrinutes identified by the name Name. 
%  Name is either atom or a compound of Namespace:AttributeName, where Namespace can be IRI 
%  or a registered prefix (see prefix_namespace/2). Attributes is list of attributes from 
%  some of XML DOM elements.  
attributes_key_value(  Attributes, Prefix : Name, Value) :-
    prefix_namespace(Prefix, Namespace),
    memberchk( Namespace:Name = Value, Attributes), 
    !. 
attributes_key_value( Attributes, Name, Value) :-    
    memberchk( Name = Value, Attributes). 

%! sax_parse_stream(+Stream, +Context, -Result) is nondet
%  same as sax_parse_stream/5 with Options set to [] and remainder to []. 
sax_parse_stream(Stream, Context, Result) :-
    sax_parse_stream(Stream, Context, Result, [], []).

%! sax_parse_stream(+Stream, +Context, +InitialState:list, -Result:list) is nondet
%  same as sax_parse_stream/4 with Options set to []
sax_parse_stream(Stream, Context, InitialState, Result) :-
    sax_parse_stream(Stream, Context, InitialState, Result, []).

%! sax_parse_stream(+Stream, +Context, -Result, +Options:list) is nondet
%  Result unifies with the result of calling =|sax//2|= parser
%  over xml document stored in the Stream. Options are handed over to load_xml/3
%  call
sax_parse_stream(Stream, Context, InitialState, Result, Options) :-
    load_xml(Stream, Xml, [dialect(xmlns) | Options]),
    call_dcg(sax(Context, Xml), InitialState, Result).

%! sax( +Context, +Xml:list )// is det
%  Succeeds if the DOM compound =|Xml|= can be parsed in the user defined Context.
%  Context is passed to user defined predicates sax:element_start//5 and 
%  sax:element_end//4. The unsolved elements are not producing output, by their children 
%  are still processed
sax( Context, Xml ) -->
    sax( Context, [], Xml).

%%%%% PRIVATES %%%

sax( Context, PathStack, [ element(Namespace : ElementName, Attributes, Children) | Elements]) -->

    {
        (
            prefix_namespace(Prefix, Namespace)
        ;
            Namespace = Prefix
        )
    },
    (
        element_start(Context, PathStack, Prefix, ElementName, Attributes)
    ;
        element_start(Context, Prefix : ElementName, Attributes)
    ; 
        []
    ),
    sax(Context, [Prefix : ElementName : Attributes | PathStack], Children), 
    (
        element_end(Context, PathStack, Prefix, ElementName)
    ;
        element_end(Context, Prefix: ElementName)
    ;
        []
    ),
    sax(Context, PathStack, Elements).
sax( Context, PathStack, [ Text | Elements]) -->
    {
        atomic(Text)
    },
    (
        text(Context, PathStack, Text)
    ;
        text(Context, Text)
    ; 
        []
    ),    
    sax(Context, PathStack, Elements).
sax( Context, PathStack, [ _ | Elements ] ) --> sax(Context, PathStack, Elements).
sax( _, _,  [] ) --> [].