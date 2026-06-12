Class {
	#name : 'MoTionRules',
	#superclass : 'Object',
	#category : 'Model-Transformation',
	#package : 'Model-Transformation'
}

{ #category : 'as yet unclassified' }
MoTionRules class >> applyRename: oldName to: newName type: aType source: aSource model: aModel [

	| rule |
	rule := MoTionRule new.
	rule sourcePattern: FASTTypeScriptClassDeclaration
		%
		{ (#'children*'
		 <=> (aType % { (#sourceCode <=> oldName) } as: #found)) }.
	rule targetPattern: FASTTypeScriptClassDeclaration
		%
		{ (#'children*'
		 <=> (aType % { (#sourceCode <=> newName) } as: #found)) }.
	rule model: aModel.
	rule source: aSource.
	^ rule transform
]

{ #category : 'instance creation' }
MoTionRules class >> rename: oldName to: newName in: source [
    | parser res result |
    parser := FASTTypeScriptParser new.
    res := parser parse: source.
    result := source.
    
    "Essaie PropertyIdentifier (méthodes, variables)"
    result := self
        applyRename: oldName
        to: newName
        type: FASTTypeScriptPropertyIdentifier
        source: result
        model: res.
    
    "Essaie TypeIdentifier (classes, types)"
    result := self
        applyRename: oldName
        to: newName
        type: FASTTypeScriptTypeIdentifier
        source: result
        model: (parser parse: result).
    
    ^ result
]
