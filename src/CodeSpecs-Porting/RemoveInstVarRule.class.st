"
Copyright (c) 2021 Quorum Software.
	See (MIT) license in root directory.
"
Class {
	#name : #RemoveInstVarRule,
	#superclass : #RefactoringRule,
	#instVars : [
		'ivar',
		'classname'
	],
	#category : #'CodeSpecs-Porting-Rules'
}

{ #category : #private }
RemoveInstVarRule class >> named: aString in: classname [
	^self new ivar: aString; classname: classname
]

{ #category : #private }
RemoveInstVarRule >> basicApplyTo: aModuleSpec [
	| class all |
	class := aModuleSpec resolveClass: classname.
	class ifNil: [^self].
	all := aModuleSpec withAllSubclasses: class.
	all do: [:c | 
		c methods copy
			select: [:m | m usesInstanceVariableNamed: ivar]
			thenDo: [:m | aModuleSpec removeMethod: m]].
	class instVarNames remove: ivar ifAbsent: nil.
]

{ #category : #accessing }
RemoveInstVarRule >> classname [
	^classname
]

{ #category : #accessing }
RemoveInstVarRule >> classname: aString [
	classname := aString
]

{ #category : #accessing }
RemoveInstVarRule >> ivar [
	^ivar
]

{ #category : #accessing }
RemoveInstVarRule >> ivar: aString [
	ivar := aString
]
