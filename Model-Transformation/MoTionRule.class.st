Class {
	#name : 'MoTionRule',
	#superclass : 'Object',
	#instVars : [
		'binding',
		'model',
		'newValue',
		'source',
		'sourcePattern',
		'bindings'
	],
	#category : 'Model-Transformation',
	#package : 'Model-Transformation'
}

{ #category : 'accessing' }
MoTionRule >> binding [

	^ binding
]

{ #category : 'accessing' }
MoTionRule >> binding: anObject [

	binding := anObject
]

{ #category : 'accessing' }
MoTionRule >> bindings [

	^ bindings
]

{ #category : 'accessing' }
MoTionRule >> bindings: anObject [

	bindings := anObject
]

{ #category : 'executing' }
MoTionRule >> execute [
    | matches sortedMatches newSource newModel |
    matches := self sourcePattern
        collectBindings: { self binding asSymbol }
        for: self model.
    
    "Trie par startPos DÉCROISSANT — du dernier au premier:"
    sortedMatches := matches asSortedCollection: [ :a :b |
        (a at: self binding asSymbol) startPos > 
        (b at: self binding asSymbol) startPos
    ].
    
    newSource := source.
    
    sortedMatches do: [ :binding |
        | node |
        node := binding at: self binding asSymbol.
        newSource := newSource
            copyReplaceFrom: node startPos
            to: node endPos
            with: newValue.
    ].
    
    newModel := FASTTypeScriptParser new parse: newSource.
    ^ Association key: newSource value: newModel
]

{ #category : 'as yet unclassified' }
MoTionRule >> executeOnFirst [
    | matches node newSource newModel |
    matches := self sourcePattern
        collectBindings: { self binding asSymbol }
        for: self model.
    
    "Prend seulement le PREMIER match"
    node := matches first at: self binding asSymbol.
    
    newSource := source
        copyReplaceFrom: node startPos
        to: node endPos
        with: newValue.
    
    newModel := FASTTypeScriptParser new parse: newSource.
    ^ Association key: newSource value: newModel
]

{ #category : 'as yet unclassified' }
MoTionRule >> executeWithBindings [

	| matches sortedChanges newSource  |
	matches := self sourcePattern
		           collectBindings: bindings keys asArray
		           for: self model.

	"Collecte tous les noeuds avec leurs nouvelles valeurs:"
	sortedChanges := OrderedCollection new.
	matches do: [ :match |
		bindings keysAndValuesDo: [ :bindingKey :newVal |
			| node |
			node := match at: bindingKey ifAbsent: [ nil ].
			node isNil ifFalse: [
				sortedChanges add: (Association key: node value: newVal) ] ] ].

	"Trie par startPos décroissant:"
	sortedChanges := sortedChanges asSortedCollection: [ :a :b |
		                 a key startPos > b key startPos ].

	newSource := source.

	"Applique chaque changement:"
	sortedChanges do: [ :assoc |
		| node newVal |
		node := assoc key.
		newVal := assoc value.
		newSource := newSource
			             copyReplaceFrom: node startPos
			             to: node endPos
			             with: newVal ].

	^ newSource
]

{ #category : 'accessing' }
MoTionRule >> model [

	^ model
]

{ #category : 'accessing' }
MoTionRule >> model: anObject [

	model := anObject
]

{ #category : 'accessing' }
MoTionRule >> newValue [

	^ newValue
]

{ #category : 'accessing' }
MoTionRule >> newValue: anObject [

	newValue := anObject
]

{ #category : 'accessing' }
MoTionRule >> source [

	^ source
]

{ #category : 'accessing' }
MoTionRule >> source: anObject [

	source := anObject
]

{ #category : 'accessing' }
MoTionRule >> sourcePattern [

	^ sourcePattern
]

{ #category : 'accessing' }
MoTionRule >> sourcePattern: anObject [

	sourcePattern := anObject
]
