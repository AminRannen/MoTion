Class {
	#name : 'MoTionRuleNew',
	#superclass : 'Object',
	#instVars : [
		'binding',
		'model',
		'newValue',
		'source',
		'sourcePattern'
	],
	#category : 'Model-Transformation',
	#package : 'Model-Transformation'
}

{ #category : 'accessing' }
MoTionRuleNew >> binding [

	^ binding
]

{ #category : 'accessing' }
MoTionRuleNew >> binding: anObject [

	binding := anObject
]

{ #category : 'executing' }
MoTionRuleNew >> execute [
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

{ #category : 'accessing' }
MoTionRuleNew >> model [

	^ model
]

{ #category : 'accessing' }
MoTionRuleNew >> model: anObject [

	model := anObject
]

{ #category : 'accessing' }
MoTionRuleNew >> newValue [

	^ newValue
]

{ #category : 'accessing' }
MoTionRuleNew >> newValue: anObject [

	newValue := anObject
]

{ #category : 'accessing' }
MoTionRuleNew >> source [

	^ source
]

{ #category : 'accessing' }
MoTionRuleNew >> source: anObject [

	source := anObject
]

{ #category : 'accessing' }
MoTionRuleNew >> sourcePattern [

	^ sourcePattern
]

{ #category : 'accessing' }
MoTionRuleNew >> sourcePattern: anObject [

	sourcePattern := anObject
]
