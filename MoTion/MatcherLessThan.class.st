Class {
	#name : 'MatcherLessThan',
	#superclass : 'MatcherLiteralNumber',
	#category : 'MoTion',
	#package : 'MoTion'
}

{ #category : 'as yet unclassified' }
MatcherLessThan >> lessThan: aValue [
    ^ MatcherLessThan value: aValue
]

{ #category : 'matching' }
MatcherLessThan >> matchOnlyNumber: aNumber withContext: aContext [
    aContext isMatch: aNumber < value
]
