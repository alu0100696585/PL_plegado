/* lexical grammar */
%{
var reserved_words = { PI: 'PI', E : 'E', IF: 'if', THEN: 'then', ELSE: 'else', WHILE: 'while', DO: 'do', BEGIN: 'begin' , END: 'end' ,
			CALL: 'call', VAR: 'var' , ODD: 'odd', CONST: 'const', PROCEDURE: 'procedure' }

function idORrw(x) {
  return (x.toUpperCase() in reserved_words)? x.toUpperCase() : 'ID'
}

%}
%%

\s+|\#.*                         /* skip whitespace and comments */
\b\d+("."\d*)?([eE][-+]?\d+)?\b  return 'NUMBER'
[!<>=]'='|[<>]                   return 'COMPARISON'
\b[A-Za-z_]\w*\b                 return idORrw(yytext)
[-*/+^!%=();]                    return yytext;
[,]                              return 'COMMA'
[.]                              return 'DOT'
<<EOF>>                          return 'EOF'
.                                return 'INVALID'


