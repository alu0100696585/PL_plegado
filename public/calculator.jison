 /* description: Parses end executes mathematical expressions. */

%{

var symbolTables = [{name: 'global', father: null , vars: {}}];

var scope = 0;

var symbol_table = symbolTables[scope];

function get_Scope(){
  return scope;
}

function makeScope(id){

  scope++;
  symbolTables.push({name: id, father: symbol_table.name, vars: {}});
  symbol_table = symbolTables[scope];

}

function scopeUp(){
  scope--;
  symbol_table = symbolTables[scope];

}


function findDef(id){
  var f = id;
  var s = scope;

  while(s >= 0){
    for (var i in symbolTables[s].vars){
      if(i == f){
         if(symbolTables[s].vars[i].type != 'proc'){
          return symbolTables[s].name;
          }
        }
    }
    s--;
  }

  throw new Error( f + "is not defined" );


  

}

function findDefProc(id){

  var f = id;
  var s = scope;
  
  while(s >= 0){
    for (var i in symbolTables[s].vars){
      if(i == f){
         if(symbolTables[s].vars[i].type != 'const' && symbolTables[s].vars[i].type != 'var'){
	  return;
	  }
	}
    }
    s--;
  }
   
  throw new Error( "Procedure " + f + " is not defined.");

}

function findDefvar(id){

  var f = id;
  var s = scope;

  while(s >= 0){
    for (var i in symbolTables[s].vars){
      if(i == f){
         if(symbolTables[s].vars[i].type != 'const' && symbolTables[s].vars[i].type != 'proc'){
          return symbolTables[s].name;
          }
        }
    }
    s--;
  }

  throw new Error( "Cant use constant or procedure:  " + f );

}



function numArg(id, nn) { 
  var f = id;
  var num = nn;
  var s = scope;

  while(s >= 0){
    for (var i in symbolTables[s].vars){
          if(i == f  && symbolTables[s].vars[i].longitud == num){
             console.log(i + ' ' + f + ' ' + num + ' ' + symbolTables[s].vars[i].longitud);
             return;
          }
    }
    s--;
  }

  throw new Error( "Error:  number arguments of " + f );
}


function fact (n) { 
  return n==0 ? 1 : fact(n-1) * n 
}

%}

%token  IF THEN COMPARISON NUMBER ID E PI EOF WHILE DO ELSE BEGIN END CALL COMMA VAR ODD CONST PROCEDURE
/* operator associations and precedence */

%right ELSE THEN
%right '='
%left '+' '-'
%left '*' '/'
%left '^'
%right '%'
%left UMINUS
%left '!'

%start prog

%% /* language grammar */
prog
    :block DOT EOF
        { 
          var table = symbolTables;
          
          symbolTables = [{name: 'global', father: null , vars: {}}];
          scope = 0;
	  symbol_table = symbolTables[scope];
          
          
          $$ = $1; 
          return [$$, table];
        }
    ;
    
block
    : constt vaar procc st
      { $$ = { cnst:$1 , V:$2 , proc:$3, st:$4 };}
    ;
    
procc 
    : /* empty */
    | proc procc  
	{
          $$ = [$1];
          if ($2) 
             $$ = $$.concat($2);
        }
    ;
    
proc
    : PROCEDURE name_arg ';' block ';'
       { 
	  $$ = { type: 'procedure' , nombre: $2[0], argumentos: $2[1] , right: $4, symboltable: symbolTables.pop() }; 
	  scopeUp();
	}
    ;
   
name_arg
    :name '(' pargsp ')'
      {
        
	symbol_table.vars[$1] = {type: 'proc', longitud: $3.length};
	makeScope($1);

	for(var i = 0; i < $3.length; i++ ){
	  symbol_table.vars[$3[i]] = {type: 'var'};
        }
        
        
	$$ = [$1];
	if($3) $$.concat($3);
      }
    ;
   
   
pargsp
    : arg
      {
	$$ = $1;
      }
    ;

name 
    : ID
      {
	$$ = $1;
      }
    ;
    
constt
    : /* empty */
    | CONST cvrb
	{ 
	  $$ = {type: 'CONST' , constantes: $2};
	}
    ;

cvrb
    : ID '=' NUMBER ';'
      {
        symbol_table.vars[$1] = {type: 'const', valor: $3};
	$$ = {type: '=', left: $1 , right: $3};
      }
    | ID '=' NUMBER COMMA cvrb
      { 
	symbol_table.vars[$1] = {type: 'const', valor: $3};
	$$ = [{type: '=', left: $1 , right: $3}];
	$$ = $$.concat($5);
      }
    ;

vaar
    : /* empty */
    | VAR vrb
      { $$ = {type: 'VAR' , variables: $2}; }
    ;
vrb 
    : ID ';'
      {
        symbol_table.vars[$1] = {type: 'var'};
	$$ = [$1];
      }
    | ID COMMA vrb
      { 
        symbol_table.vars[$1] = {type: 'var'};
	$$ = [{type: 'VAR', id:$1 }];
	$$ = $$.concat($3);
      }
    ;

expressions
    : st  
        { $$ = (typeof $1 === 'undefined')? [] : [ $1 ]; }
    | expressions ';' st
        { $$ = $1;
          if ($3) $$.push($3); 
        }
    ;

st
    : /* empty */
    | e
    | IF condition THEN st ELSE st
        {$$ = {type: 'ifelse', condicion: $2 , if: $4 , else: $6};}
    | IF condition THEN st 
        {$$ = {type: 'if', condicion: $2 , if: $4};}
    | WHILE condition DO st
        {$$ = {type:'while', condicion: $2 , do: $4};}
    | BEGIN expressions ';' END
        {$$ = $2;}
    | CALL ID '(' llamada ')'
        { 
	  findDefProc($2)
          numArg($2,$4.length)
	  $$ = {type: 'call' , id:$2 , lista: $4}; }
    ;
    
arg
    : /* empty */
      {$$ = [];}
    | ID 
      {
	$$ = [$1];
      } 
    | ID COMMA arg
      {
	$$ = [$1].concat($3);
      } 
    ;
    
llamada
    : /* empty */ 
       {$$ = [];}
    | e 
      {$$ = [$1];} 
    | e COMMA llamada
       {$$ = [$1].concat($3);}
    ;
    
condition
    : NUMBER COMPARISON NUMBER
        {
	 $$ = { type: $2 , left: $1 , right:$3 }; 
	}
    | ID COMPARISON NUMBER
        {
        findDef($1);
	 $$ = { type: $2 , left: $1 , right:$3 }; 
	}
    | ID COMPARISON ID
        {
        findDef($1);
        findDef($3);
	 $$ = { type: $2 , left: $1 , right:$3 }; 
	}
    | ODD e 
        {$$ = {type: 'odd', odd: $2};}
    ;

e
    : ID '=' e
        { 
          var t = findDefvar($1);
	  $$ = {type:'ID', nombre:$1 , left:$3, declared_in: t}; 
	}
    | PI '=' e 
        { throw new Error("Can't assign to constant 'π'"); }
    | E '=' e 
        { throw new Error("Can't assign to math constant 'e'"); }
    | e '+' e
        {$$ = {type: $2 , left: $1 , right: $3};}
    | e '-' e
        {$$ = {type: $2 , left: $1 , right: $3};}
    | e '*' e
        {$$ = {type: $2 , left: $1 , right: $3};}
    | e '/' e
        {
          if ($3 == 0) throw new Error("Division by zero, error!");
          $$ = {type: $2 , left: $1 , right: $3};;
        }
    | e '^' e
        {$$ = {type: $2 , left: $1 , right: $3};}
    | e '!'
        {
          if ($1 % 1 !== 0) 
             throw "Error! Attempt to compute the factorial of "+
                   "a floating point number "+$1;
          $$ = {type: $2 , left: $1};
        }
    | e '%'
        {$$ = {type: $2 , left: $1 , right: 100};}
    | '-' e %prec UMINUS
        {$$ = -$2;}
    | '(' e ')'
        {$$ = $2;}
    | NUMBER
        {$$ = Number(yytext);}
    | E
        {$$ = Math.E;}
    | PI
        {$$ = Math.PI;}
    | ID 
        { 
	  var t = findDef($1);
	  $$ = {nombre:$1, declared_in: t}; 
        }
    ;

