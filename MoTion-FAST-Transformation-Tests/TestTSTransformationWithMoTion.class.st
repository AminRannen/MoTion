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
  myVar: number = 42;
  constructor() {
    this.memory = 0;
    this.history = [];
  }

  // ===== Basic operations =====
    add(a: number, b: number): number {
        return a + b;
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

  compute(x: number, y: number, z: number, w: number): number {
    return x + y + z + w;
  }

  }'.
	parser := FASTTypeScriptParser new.
	model := parser parse: sourceCode
]

{ #category : 'tests' }
TestTSTransformationWithMoTion >> testBinding03_ListAllParams [
    | pattern matches method |
    method := (model allWithType: FASTTypeScriptMethodDefinition)
        detect: [:m | m name sourceCode = 'compute'].
    pattern := FASTTypeScriptMethodDefinition % {
        (#'children*' <=> (FASTTypeScriptRequiredParameter % {} as: #param))
    }.
    matches := pattern collectBindings: #(#param) for: method.
    self assert: matches size equals: 4.
    self assert: ((matches first at: #param) respondsTo: #startPos)
]

{ #category : 'tests' }
TestTSTransformationWithMoTion >> testBinding03_ListFixedSize [

	| pattern matches method |
	method := (model allWithType: FASTTypeScriptMethodDefinition)
		          detect: [ :m | m name sourceCode = 'power' ].
	pattern := FASTTypeScriptMethodDefinition % { (#parameters
	            <=>
	            (FASTTypeScriptFormalParameters
	             % { (#_ <=> { #'@p1'. #'@p2' }) })) }.
	matches := pattern collectBindings: #( #p1 #p2 ) for: method.
	self assert: matches isEmpty not.
	self assert: (matches first at: #p1)  sourceCode equals: 'base: number'.
	self
		assert: (matches first at: #p2)  sourceCode
		equals: 'exponent: number'
]

{ #category : 'tests' }
TestTSTransformationWithMoTion >> testBinding04_ListSpecificParam [
    | pattern matches method |
    method := (model allWithType: FASTTypeScriptMethodDefinition)
        detect: [:m | m name sourceCode = 'compute'].
    pattern := FASTTypeScriptMethodDefinition % {
        (#'children*' <=> (FASTTypeScriptRequiredParameter % {
            (#'children*' <=> (FASTTypeScriptIdentifier % {
                (#sourceCode <=> #'@paramName')
            } as: #param))
        }))
    }.
    matches := pattern collectBindings: #(#param #paramName) for: method.
    self assert: matches size equals: 4.
    self assert: (matches anySatisfy: [:m | (m at: #paramName) = 'x'])
]

{ #category : 'tests' }
TestTSTransformationWithMoTion >> testBinding04_ListWithWildcard [
    | pattern matches method |
    method := (model allWithType: FASTTypeScriptMethodDefinition)
        detect: [:m | m name sourceCode = 'compute'].
    pattern := FASTTypeScriptMethodDefinition % {
        (#parameters <=> (FASTTypeScriptFormalParameters % {
            (#_ <=> { #'@p1' . #'@p2' . #'*rest' })
        }))
    }.
    matches := pattern collectBindings: #(#p1 #p2 #rest) for: method.
    self assert: matches isEmpty not.
    self assert: (matches first at: #p1) sourceCode equals: 'x: number'.
    self assert: (matches first at: #p2) sourceCode equals: 'y: number'.
    self assert: (matches first at: #rest) size equals: 2
]

{ #category : 'tests' }
TestTSTransformationWithMoTion >> testBinding05_GenericWildcard [
    | pattern matches method |
    method := (model allWithType: FASTTypeScriptMethodDefinition)
        detect: [ :m | m name sourceCode = 'add' ].
    pattern := FASTTypeScriptMethodDefinition % {
        (#_ <=> (FASTTypeScriptFormalParameters % {} as: #paramsNode))
    }.
    matches := pattern collectBindings: #(#paramsNode) for: method.
    self assert: matches isEmpty not.
    self assert: ((matches first at: #paramsNode) respondsTo: #startPos)
]

{ #category : 'tests' }
TestTSTransformationWithMoTion >> testBinding06_OrderIgnored [

	| pattern matches method |
	method := (model allWithType: FASTTypeScriptMethodDefinition)
		          detect: [ :m | m name sourceCode = 'add' ].
	pattern := FASTTypeScriptMethodDefinition
	           % { (#parameters <=> (FASTTypeScriptFormalParameters
		             % { (#_ <=> { #'@p1'. #'@p2' } orderIgnored) })) }.
	matches := pattern collectBindings: #( #p1 #p2 ) for: method.
	self assert: matches isEmpty not.
	self assert: (matches first at: #p1) sourceCode equals: 'a: number'.
	self assert: (matches first at: #p2) sourceCode equals: 'b: number'
]

{ #category : 'tests' }
TestTSTransformationWithMoTion >> testBinding07_AsPlusAtSign [

	| pattern matches method |
	method := (model allWithType: FASTTypeScriptMethodDefinition)
		          detect: [ :m | m name sourceCode = 'multiply' ].
	pattern := FASTTypeScriptMethodDefinition % { (#name
	            <=>
		            (FASTTypeScriptPropertyIdentifier
		             % { (#sourceCode <=> #'@p1') } as: #methodNode)) }.
	matches := pattern collectBindings: #( #p1 #methodNode ) for: method.
	self assert: matches isEmpty not.
	self assert: (matches first at: #p1) equals: 'multiply'.
	self assert: ((matches first at: #methodNode) respondsTo: #startPos).
	
	
]

{ #category : 'tests' }
TestTSTransformationWithMoTion >> testBinding08_AsPlusListFixed [
    | pattern matches method |
    method := (model allWithType: FASTTypeScriptMethodDefinition)
        detect: [ :m | m name sourceCode = 'power' ].
    pattern := FASTTypeScriptMethodDefinition % {
        #name <=> (FASTTypeScriptPropertyIdentifier % {} as: #methodName).
        #parameters <=> (FASTTypeScriptFormalParameters % {
            #_ <=> { #'@p1' . #'@p2' }
        })
    }.
    matches := pattern collectBindings: #(#methodName #p1 #p2) for: method.
    self assert: matches isEmpty not.
    self assert: ((matches first at: #methodName) respondsTo: #startPos).
    self assert: (matches first at: #p1)  sourceCode equals: 'base: number'.
    self assert: (matches first at: #p2)  sourceCode equals: 'exponent: number'
]

{ #category : 'tests' }
TestTSTransformationWithMoTion >> testBinding09_ListFixedPlusContainerAs [
    | pattern matches method |
    method := (model allWithType: FASTTypeScriptMethodDefinition)
        detect: [ :m | m name sourceCode = 'power' ].
    pattern := FASTTypeScriptMethodDefinition % {
        (#parameters <=> (FASTTypeScriptFormalParameters % {
            #_ <=> { #'@p1' . #'@p2' }
        } as: #paramsContainer))
    }.
    matches := pattern collectBindings: #(#p1 #p2 #paramsContainer) for: method.
    self assert: matches isEmpty not.
    self assert: ((matches first at: #paramsContainer) respondsTo: #startPos)

]

{ #category : 'tests' }
TestTSTransformationWithMoTion >> testBinding10_GenericWildcardPlusAs [
    | pattern matches method |
    method := (model allWithType: FASTTypeScriptMethodDefinition)
        detect: [ :m | m name sourceCode = 'add' ].
    pattern := FASTTypeScriptMethodDefinition % {
        (#_ <=> (FASTTypeScriptFormalParameters % {
            #_ <=> { #'@p1' . #'@p2' }
        } as: #paramsNode))
    }.
    matches := pattern collectBindings: #(#p1 #p2 #paramsNode) for: method.
    self assert: matches isEmpty not
]

{ #category : 'tests' }
TestTSTransformationWithMoTion >> testRemoveUnusedParameter [
    | pattern rule newSource newModel method |
    sourceCode := 'class Calculator {
        add(a: number, b: number, unused: string): number {
            return a + b;
        }
    }'.
    parser := FASTTypeScriptParser new.
    model := parser parse: sourceCode.
    
    method := (model allWithType: FASTTypeScriptMethodDefinition)
        detect: [ :m | m name sourceCode = 'add' ].
    
    pattern := FASTTypeScriptMethodDefinition % {
        (#parameters <=> (FASTTypeScriptFormalParameters % {
            #_ <=> { #'@p1' . #'@p2' . #'@p3' }
        }))
    }.
    
    rule := MoTionRule new.
    rule sourcePattern: pattern.
    rule model: method.
    rule source: sourceCode.
    rule bindings: { (#p3 -> nil) } asDictionary.
    
    newSource := rule executeRemoval.
    newModel := parser parse: newSource.
    
    method := (newModel allWithType: FASTTypeScriptMethodDefinition)
        detect: [ :m | m name sourceCode = 'add' ].
    
    self assert: method parameters genericChildren size equals: 2.
    self deny: (newSource includesSubstring: 'unused').

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
TestTSTransformationWithMoTion >> testRenameClassAndMethod [

	| pattern rule newSource newModel class |
	"creating a pattern with one binding "
	pattern := FASTTypeScriptClassDeclaration % {
		           (#name <=> FASTTypeScriptTypeIdentifier
		            % { (#sourceCode <=> 'Calculator') } as: #className).
		           (#'children*' <=> FASTTypeScriptMethodDefinition
		            % { (#name <=> FASTTypeScriptPropertyIdentifier
			             % { (#sourceCode <=> 'multiply') } as: #methodName) }) }.

	"matching pattern with a selected method"
	class := (model allWithType: FASTTypeScriptClassDeclaration) first.
	"create moTionRule "
	rule := MoTionRule new.
	rule sourcePattern: pattern.
	rule model: class.
	rule source: sourceCode.
	"Precise the binding and the new Name of the class "
	rule bindings: { (#methodName -> 'multiplication').
	                 (#className -> 'Calculator666') } asDictionary.
	"execute the Rule and get the new Source"
	newSource := rule executeWithBindings.
	"Parse the new Source Code and verify the new class named modified"
	newModel := parser parse: newSource.
	self assert:
		((newModel allWithType: FASTTypeScriptMethodDefinition) anySatisfy: [
			 :m | m name sourceCode = 'multiplication' ]).
			self assert:
		((newModel allWithType: FASTTypeScriptClassDeclaration) anySatisfy: [
			 :m | m name sourceCode = 'Calculator666' ]).
]

{ #category : 'tests' }
TestTSTransformationWithMoTion >> testRenameClassAndMethodWildcard [

	| pattern rule newSource newModel class |
	"creating a pattern with one binding "
	pattern := FASTTypeScriptClassDeclaration % {
		           (#name <=> FASTTypeScriptTypeIdentifier
		            % { (#sourceCode <=> #'@className') }).
		           (#'children*' <=> FASTTypeScriptMethodDefinition
		            % { (#name <=> FASTTypeScriptPropertyIdentifier
			             % { (#sourceCode <=> #'@methodName') }) }) }.

	"matching pattern with a selected method"
	class := (model allWithType: FASTTypeScriptClassDeclaration) first.
	"create moTionRule "
	rule := MoTionRule new.
	rule sourcePattern: pattern.
	rule model: class.
	rule source: sourceCode.
	"Precise the binding and the new Name of the class "
	rule bindings: {
			(#methodName -> 'multiplication').
			(#className -> 'CalculatorNew') } asDictionary.
	"execute the Rule and get the new Source"
	newSource := rule executeWithBindings.
	"Parse the new Source Code and verify the new class named modified"
	newModel := parser parse: newSource.
	self assert:
		((newModel allWithType: FASTTypeScriptMethodDefinition) anySatisfy: [
			 :m | m name sourceCode = 'multiplication' ]).
	self assert:
		((newModel allWithType: FASTTypeScriptClassDeclaration) anySatisfy: [
			 :m | m name sourceCode = 'CalculatorNew' ]).
	
]

{ #category : 'tests' }
TestTSTransformationWithMoTion >> testRenameClassWildCard [

	| pattern result rule newSource newModel |
	"creating a pattern with one binding "
	pattern := FASTTypeScriptClassDeclaration
	           % { (#name <=> FASTTypeScriptTypeIdentifier
		            % { (#sourceCode <=> #'@className') }) }.

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

{ #category : 'tests' }
TestTSTransformationWithMoTion >> testRenameParametersWithAt [
    | pattern rule newSource newModel method addMethod |
    method := (model allWithType: FASTTypeScriptMethodDefinition)
        detect: [:m | m name sourceCode = 'add'].
    pattern := FASTTypeScriptMethodDefinition % {
        (#parameters <=> (FASTTypeScriptFormalParameters % {
            (#_ <=> { #'@p1' . #'@p2' } orderIgnored)
        }))
    }.
    rule := MoTionRule new.
    rule sourcePattern: pattern.
    rule model: method.
    rule source: sourceCode.
    rule bindings: { 
        (#p1 -> 'x: number').
        (#p2 -> 'y: number')
    } asDictionary.
    newSource := rule executeWithBindings.
    newModel := parser parse: newSource.
    addMethod := (newModel allWithType: FASTTypeScriptMethodDefinition)
        detect: [:m | m name sourceCode = 'add'].
    self assert: (addMethod parameters children 
        anySatisfy: [:p | p sourceCode = 'x: number']).
    self assert: (addMethod parameters children 
        anySatisfy: [:p | p sourceCode = 'y: number'])
]

{ #category : 'tests' }
TestTSTransformationWithMoTion >> testScenario_FullClassRefactor [
	"Renomme classe + méthode + 2 paramètres en une seule transformation"

	| pattern rule newSource newModel renamedClass renamedMethod |
	pattern := FASTTypeScriptClassDeclaration % {
		           (#name
		            <=>
			            (FASTTypeScriptTypeIdentifier
			             % { (#sourceCode <=> 'Calculator') } as: #className)).
		           (#'children*' <=> (FASTTypeScriptMethodDefinition % {
			             (#name
			              <=>
				              (FASTTypeScriptPropertyIdentifier
				               % { (#sourceCode <=> 'power') } as: #methodName)).
			             (#parameters
			              <=>
			              (FASTTypeScriptFormalParameters
			               % { (#_ <=> { #'@p1'. #'@p2' }) })) })) }.
	rule := MoTionRule new.
	rule sourcePattern: pattern.
	rule model: (model allWithType: FASTTypeScriptClassDeclaration) first.
	rule source: sourceCode.
	rule bindings: {
			(#className -> 'ScientificCalculator').
			(#methodName -> 'raiseToPower').
			(#p1 -> 'base').
			(#p2 -> 'exp') } asDictionary.
	newSource := rule executeWithBindings.
	newModel := parser parse: newSource.

	renamedClass := (newModel allWithType: FASTTypeScriptClassDeclaration)
		                detect: [ :c |
		                c name sourceCode = 'ScientificCalculator' ]
		                ifNone: [ nil ].
	renamedMethod := (newModel allWithType:
		                  FASTTypeScriptMethodDefinition)
		                 detect: [ :m | m name sourceCode = 'raiseToPower' ]
		                 ifNone: [ nil ].

	self assert: renamedClass isNotNil.
	self assert: renamedMethod isNotNil.
	self
		assert: renamedMethod parameters genericChildren first sourceCode
		equals: 'base'.
	self
		assert: renamedMethod parameters genericChildren second sourceCode
		equals: 'exp'.
	"Vérifie aussi qu'aucune autre méthode n'a été touchée par erreur"
	self assert:
		((newModel allWithType: FASTTypeScriptMethodDefinition) anySatisfy: [
			 :m | m name sourceCode = 'add' ]).


]
