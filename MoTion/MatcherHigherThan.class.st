Class {
	#name : 'MatcherHigherThan',
	#superclass : 'MatcherLiteralNumber',
	#category : 'MoTion',
	#package : 'MoTion'
}

{ #category : 'as yet unclassified' }
MatcherHigherThan >> higherThan: aValue [
    ^ MatcherHigherThan value: aValue
]

{ #category : 'matching' }
MatcherHigherThan >> matchOnlyNumber: aNumber withContext: aContext [
    aContext isMatch: aNumber > value
]
