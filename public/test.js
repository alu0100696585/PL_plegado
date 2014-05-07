var assert = chai.assert; //la variable assert contiene los asertos que se pueden realizar

suite( 'Analizador Sintacsis + Ambito', function(){  //Suite equivale al describle en RAKE
  
  test('Admision de procedures paralelos.', function(){  
    var result = calculator.parse("var a, b, c; procedure doble(k); k = k * 2; procedure triple(k);k = k * 3; call doble(b) .");
    assert.deepEqual(JSON.stringify(result,undefined,2), '[\n  {\n    "V": {\n      "type": "VAR",\n      "variables": [\n        {\n          "type": "VAR",\n          "id": "a"\n        },\n        {\n          "type": "VAR",\n          "id": "b"\n        },\n        "c"\n      ]\n    },\n    "proc": [\n      {\n        "type": "procedure",\n        "nombre": "doble",\n        "right": {\n          "st": {\n            "type": "ID",\n            "nombre": "k",\n            "left": {\n              "type": "*",\n              "left": {\n                "nombre": "k",\n                "declared_in": "doble"\n              },\n              "right": 2\n            },\n            "declared_in": "doble"\n          }\n        },\n        "symboltable": {\n          "name": "doble",\n          "father": "global",\n          "vars": {\n            "k": {\n              "type": "var"\n            }\n          }\n        }\n      },\n      {\n        "type": "procedure",\n        "nombre": "triple",\n        "right": {\n          "st": {\n            "type": "ID",\n            "nombre": "k",\n            "left": {\n              "type": "*",\n              "left": {\n                "nombre": "k",\n                "declared_in": "triple"\n              },\n              "right": 3\n            },\n            "declared_in": "triple"\n          }\n        },\n        "symboltable": {\n          "name": "triple",\n          "father": "global",\n          "vars": {\n            "k": {\n              "type": "var"\n            }\n          }\n        }\n      }\n    ],\n    "st": {\n      "type": "call",\n      "id": "doble",\n      "lista": [\n        {\n          "nombre": "b",\n          "declared_in": "global"\n        }\n      ]\n    }\n  },\n  [\n    {\n      "name": "global",\n      "father": null,\n      "vars": {\n        "c": {\n          "type": "var"\n        },\n        "b": {\n          "type": "var"\n        },\n        "a": {\n          "type": "var"\n        },\n        "doble": {\n          "type": "proc",\n          "longitud": 1\n        },\n        "triple": {\n          "type": "proc",\n          "longitud": 1\n        }\n      }\n    }\n  ]\n]');  });
  
  test('Asignacion a constante.', function(){  
    try {
      var result = calculator.parse("const h = 9; var a, b; procedure jruvi(); h = a + b; b = h;.");
      result = (JSON.stringify(result,undefined,2));
    } catch (e) {
      result = (String(e));
    }
    assert.deepEqual(result, 'Error: Cant use constant or procedure:  h');
  });
  
  test('Variable no definida.', function(){  
    try {
      var result = calculator.parse("var a, c; procedure escala(d); a = d*c; call escala(b).");
      result = (JSON.stringify(result,undefined,2));
    } catch (e) {
      result = (String(e));
    }
    assert.deepEqual(result, '[\n  {\n    "V": {\n      "type": "VAR",\n      "variables": [\n        {\n          "type": "VAR",\n          "id": "a"\n        },\n        "c"\n      ]\n    },\n    "proc": [\n      {\n        "type": "procedure",\n        "nombre": "escala",\n        "right": {\n          "st": {\n            "type": "ID",\n            "nombre": "a",\n            "left": {\n              "type": "*",\n              "left": {\n                "nombre": "d",\n                "declared_in": "escala"\n              },\n              "right": {\n                "nombre": "c",\n                "declared_in": "jruvi"\n              }\n            },\n            "declared_in": "jruvi"\n          }\n        },\n        "symboltable": {\n          "name": "escala",\n          "father": "jruvi",\n          "vars": {\n            "d": {\n              "type": "var"\n            }\n          }\n        }\n      }\n    ],\n    "st": {\n      "type": "call",\n      "id": "escala",\n      "lista": [\n        {\n          "nombre": "b",\n          "declared_in": "global"\n        }\n      ]\n    }\n  },\n  [\n    {\n      "name": "global",\n      "father": null,\n      "vars": {\n        "h": {\n          "type": "const",\n          "valor": "9"\n        },\n        "b": {\n          "type": "var"\n        },\n        "a": {\n          "type": "var"\n        },\n        "jruvi": {\n          "type": "proc",\n          "longitud": 0\n        }\n      }\n    },\n    {\n      "name": "jruvi",\n      "father": "global",\n      "vars": {\n        "c": {\n          "type": "var"\n        },\n        "a": {\n          "type": "var"\n        },\n        "escala": {\n          "type": "proc",\n          "longitud": 1\n        }\n      }\n    }\n  ]\n]');
  });
  
  test('Error gramatico', function(){  
    try {
      var result = calculator.parse("var i = 0, u = 9.");
      result = (JSON.stringify(result,undefined,2));
    } catch (e) {
      result = (String(e));
    }
    assert.deepEqual(result, 'Error: Parse error on line 1:\nvar i = 0, u = 9.\n------^\nExpecting \';\', \'COMMA\', got \'=\'');
  });
  
});