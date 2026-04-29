Class {
	#name : 'MTRecursiveLimitedPathTests',
	#superclass : 'MTRecursiveChildrenPathTests',
	#instVars : [
		'd',
		'e',
		'f',
		'g',
		'h'
	],
	#category : 'MoTion-Tests',
	#package : 'MoTion-Tests'
}

{ #category : 'running' }
MTRecursiveLimitedPathTests >> setUp [
    super setUp.
    d := MTTestObjectD new.
    e := MTTestObjectE new.
    f := MTTestObjectF new.
    g := MTTestObjectG new.
    h := MTTestObjectH new.
    d e: e.
    d f: f.
    e g: g.
    f h: h.
]

{ #category : 'tests' }
MTRecursiveLimitedPathTests >> testDepth1 [
    | path result |
    path := MTRecursiveLimitedPath of: #e depth: 1.
    result := path resolveFrom: d.
    self assertCollection: result hasSameElements: { e }.
]

{ #category : 'tests' }
MTRecursiveLimitedPathTests >> testDepth1OnF [
    | path result |
    path := MTRecursiveLimitedPath of: #f depth: 1.
    result := path resolveFrom: d.
    self assertCollection: result hasSameElements: { f }.
]

{ #category : 'tests' }
MTRecursiveLimitedPathTests >> testDepth2 [
    | path result |
    path := MTRecursiveLimitedPath of: #e depth: 2.
    result := path resolveFrom: d.
    self assertCollection: result hasSameElements: { e. g }.
]

{ #category : 'tests' }
MTRecursiveLimitedPathTests >> testDepth2OnF [
    | path result |
    path := MTRecursiveLimitedPath of: #f depth: 2.
    result := path resolveFrom: d.
    self assertCollection: result hasSameElements: { f. h }.
]

{ #category : 'tests' }
MTRecursiveLimitedPathTests >> testRecursiveLimitedPath [
    | path result |
    
    "depth 1 → seulement c de a"
    path := MTRecursiveLimitedPath of: #c depth: 3.
result := path resolveFrom: a.
self assertCollection: result hasSameElements: { c.  a. b }.
]

{ #category : 'tests' }
MTRecursiveLimitedPathTests >> testRecursiveLimitedPathWithFASTAST [
    | res pattern results |
    res := FASTTypeScriptParser new parse: 'class MyClass {
        method1(a, b) { return a + b; }
        method2(x) { return x * 2; }
        method3() { let y = 5; return y; }
    }'.
    
    pattern := FASTTypeScriptClassDeclaration % {
        #'children*2' <=> (FASTTypeScriptMethodDefinition % {} as: #method)
    }.
    
    results := pattern collectBindings: {#method} for: (res allWithType: FASTTypeScriptClassDeclaration) first.
    
    self assert: results size equals: 3.
]

{ #category : 'tests' }
MTRecursiveLimitedPathTests >> testRecursiveLimitedPathWithFamix [
    | model class method path result |
    model := MooseModel root allModels second.
    class := (model allWithType: FamixTypeScriptClass) first.
    method := (class methods select: [:m | m name = 'calculate']) first.

    "depth 1 → seulement les paramètres de calculate"
    path := MTRecursiveLimitedPath of: #parameters depth: 1.
    result := path resolveFrom: method.
    
    self assert: result size equals: 2.
    self assert: (result anySatisfy: [:p | p name = 'logError']).
    self assert: (result anySatisfy: [:p | p name = 'toggle']).
]

{ #category : 'tests' }
MTRecursiveLimitedPathTests >> testRecursivePath2 [
| d e f g h path result |
d := MTTestObjectD new.
e := MTTestObjectE new.
f := MTTestObjectF new.
g := MTTestObjectG new.
h := MTTestObjectH new.
d e: e.
d f: f.
e g: g.
f h: h.
"depth 1 → seulement e"
path := MTRecursiveLimitedPath of: #e depth: 1.
result := path resolveFrom: d.
"attendu : { e }"

"depth 2 → e puis g"
path := MTRecursiveLimitedPath of: #e depth: 2.
result := path resolveFrom: d.
"attendu : { e. g }"
]
