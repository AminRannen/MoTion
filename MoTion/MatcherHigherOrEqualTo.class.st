Class {
	#name : 'MatcherHigherOrEqualTo',
	#superclass : 'MatcherLiteralNumber',
	#category : 'MoTion',
	#package : 'MoTion'
}

{ #category : 'as yet unclassified' }
MatcherHigherOrEqualTo >> higherOrEqualTo: aValue [
    ^ MatcherHigherOrEqualTo value: aValue
]

{ #category : 'matching' }
MatcherHigherOrEqualTo >> matchOnlyNumber: aNumber withContext: aContext [
    aContext isMatch: aNumber >= value
]
