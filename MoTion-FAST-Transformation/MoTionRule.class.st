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
	#category : 'MoTion-FAST-Transformation',
	#package : 'MoTion-FAST-Transformation'
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
MoTionRule >> executeRemoval [
    | matches sortedNodes newSource |
    matches := self sourcePattern
                   collectBindings: bindings keys asArray
                   for: self model.
    sortedNodes := OrderedCollection new.
    matches do: [ :match |
        bindings keys do: [ :bindingKey |
            | node |
            node := match at: bindingKey ifAbsent: [ nil ].
            node isNil ifFalse: [ sortedNodes add: node ] ] ].
    "Trie par startPos décroissant pour suppression sans décalage"
    sortedNodes := sortedNodes asSortedCollection: [ :a :b |
                       a startPos > b startPos ].
    newSource := source.
    sortedNodes do: [ :node |
        | from to |
        from := node startPos.
        to := node endPos.
        "Gère la virgule trailing si elle existe juste après"
        (newSource at: to + 1 ifAbsent: [ nil ]) = $,
            ifTrue: [ to := to + 1.
                      (newSource at: to + 1 ifAbsent: [ nil ]) = $ 
                          ifTrue: [ to := to + 1 ] ].
        newSource := newSource
                         copyReplaceFrom: from
                         to: to
                         with: '' ].
    ^ newSource
]

{ #category : 'as yet unclassified' }
MoTionRule >> executeWithBindings [

	| matches sortedChanges newSource |
	matches := self sourcePattern
		           collectBindings: bindings keys asArray
		           for: self model.
	sortedChanges := OrderedCollection new.
	matches do: [ :match |
		bindings keysAndValuesDo: [ :bindingKey :newVal |
			| nodeOrValue node |
			
			nodeOrValue := match at: bindingKey ifAbsent: [ nil ].
			nodeOrValue isNil ifFalse: [
				node := (nodeOrValue respondsTo: #startPos)
					        ifTrue: [ nodeOrValue ]
					        ifFalse: [
					        self
						        findNodeWithSourceCode: nodeOrValue
						        inModel: self model ].
(node notNil and: [
    sortedChanges noneSatisfy: [:a | a key startPos = node startPos]
]) ifTrue: [
    sortedChanges add: (Association key: node value: newVal) ] ] ] ].
	sortedChanges := sortedChanges asSortedCollection: [ :a :b |
		                 a key startPos > b key startPos ].
	newSource := source.
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

{ #category : 'as yet unclassified' }
MoTionRule >> findAssociation: association in: myPattern [

	myPattern properties do: [ :assoc |
		assoc = association
			ifTrue: [ ^ myPattern ]
			ifFalse: [^ self findAssociation: association in: assoc value ] ]
]

{ #category : 'as yet unclassified' }
MoTionRule >> findNodeWithSourceCode: aString inModel: aModel [


	^ aModel allChildren
		  detect: [ :node |
			  (node respondsTo: #sourceCode) and: [ node sourceCode = aString ] ]
		  ifNone: [ nil ]
]

{ #category : 'as yet unclassified' }
MoTionRule >> findWildcard: aWildcardKey in: anObjectOfTypeA [
	"Recursively searches through associations for the value matching aWildcardKey.
     Returns the value found, or nil if not found."

	anObjectOfTypeA properties do: [ :assoc |
		(assoc value isKindOf: MatcherWildcard) ifTrue: [
			assoc value alias = aWildcardKey ifTrue: [ ^ assoc  ] ].

		"If the value is itself of type A, recurse into it"
		(assoc value isKindOf: MatcherMooseObject) ifTrue: [
			| result |
			result := self findWildcard: aWildcardKey in: assoc value.
			result ifNotNil: [ ^ result ] ] ].

	^ nil
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
