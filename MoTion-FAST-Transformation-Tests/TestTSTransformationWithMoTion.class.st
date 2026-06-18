Class {
	#name : 'TestTSTransformationWithMoTion',
	#superclass : 'TestCase',
	#instVars : [
		'parser',
		'model',
		'sourceCode'
	],
	#category : 'MoTion-FAST-Transformation-Tests',
	#package : 'MoTion-FAST-Transformation-Tests'
}

{ #category : 'running' }
TestTSTransformationWithMoTion >> setUp [

	super setUp.
	sourceCode := 'class Calculator {
  // ===== Variables =====
  private memory: number;
  private history: number[];

  constructor() {
    this.memory = 0;
    this.history = [];
  }

  // ===== Basic operations =====
  add(a: number, b: number): number {
    const result = a + b;
    this.record(result);
    return result;
  }

  subtract(a: number, b: number): number {
    const result = a - b;
    this.record(result);
    return result;
  }

  multiply(a: number, b: number): number {
    const result = a * b;
    this.record(result);
    return result;
  }

  divide(a: number, b: number): number {
    if (b === 0) {
      throw new Error("Division by zero");
    }
    const result = a / b;
    this.record(result);
    return result;
  }

  // ===== Advanced operations =====
  power(base: number, exponent: number): number {
    const result = Math.pow(base, exponent);
    this.record(result);
    return result;
  }
  }'.
	parser := FASTTypeScriptParser new.
	model := 	parser parse: sourceCode
]

{ #category : 'tests' }
TestTSTransformationWithMoTion >> testRenameClass [

	| pattern result rule newSource newModel |
	
	"creating a pattern with one binding "
	pattern := FASTTypeScriptClassDeclaration
	           % { (#name <=> FASTTypeScriptTypeIdentifier
		            % { (#sourceCode <=> 'Calculator') } as: #className) }.
		
	"matching pattern with a selected class"
	result := pattern match:
		          (model allWithType: FASTTypeScriptClassDeclaration) first.
	self assert: result isMatch.

"create moTionRule "
	rule := MoTionRule new.
	rule sourcePattern: pattern.
	rule model: (model allWithType: FASTTypeScriptClassDeclaration) first.
	rule source: sourceCode.
	"Precise the binding and the new Name of the class "
	rule bindings: { (#className -> 'Calculator222') } asDictionary.
	"execute the Rule and get the new Source"
	newSource := rule executeWithBindings.
	"Parse the new Source Code and verify the new class named modified"
	newModel := parser parse: newSource.
	self
		assert:
			(newModel allWithType: FASTTypeScriptClassDeclaration) first name
				sourceCode
		equals: 'Calculator222'
]

{ #category : 'tests' }
TestTSTransformationWithMoTion >> testRenameMethod [

	| pattern  rule newSource newModel method |
	"creating a pattern with one binding "
	pattern := FASTTypeScriptMethodDefinition
	           % { (#name <=> FASTTypeScriptPropertyIdentifier
		            % { (#sourceCode <=> 'multiply') } as: #methodName) }.

	"matching pattern with a selected method"
	method := (model allWithType: FASTTypeScriptMethodDefinition)
		          detect: [ :each | each name sourceCode = 'multiply' ]
		          ifNone: [ nil ].
	"create moTionRule "
	rule := MoTionRule new.
	rule sourcePattern: pattern.
	rule model: method .
	rule source: sourceCode.
	"Precise the binding and the new Name of the class "
	rule bindings: { (#methodName -> 'multiplication') } asDictionary.
	"execute the Rule and get the new Source"
	newSource := rule executeWithBindings.
	"Parse the new Source Code and verify the new class named modified"
	newModel := parser parse: newSource.
    self assert:
        ((newModel allWithType: FASTTypeScriptMethodDefinition)
            anySatisfy: [ :m | m name sourceCode = 'multiplication' ]).

]
