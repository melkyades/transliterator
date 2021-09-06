"
Copyright (c) 2021 Quorum Software.
	See (MIT) license in root directory.
"
Class {
	#name : #ModuleTransliteratorTest,
	#superclass : #TestCase,
	#instVars : [
		'module',
		'transliterator',
		'builder'
	],
	#category : #'CodeSpecs-Porting-Tests'
}

{ #category : #private }
ModuleTransliteratorTest >> builderClass [
	^PharoModuleBuilder
]

{ #category : #private }
ModuleTransliteratorTest >> setUp [
	module := ModuleSpec new name: 'TestModule'.
	transliterator := ModuleTransliterator new module: module.
	builder := self builderClass new module: module
]

{ #category : #private }
ModuleTransliteratorTest >> test001doNothing [
	builder addMethod: ModuleTransliteratorTest >> #test001doNothing.
	transliterator transliterate.
	self
		assert: module name equals: 'TestModule';
		assert: module classes size equals: 0;
		assert: module extendedClasses size equals: 1;
		assert: module extendedClasses first name equals: 'ModuleTransliteratorTest'
]

{ #category : #private }
ModuleTransliteratorTest >> test002filterMethod [
	| extensions class |
	builder
		addMethod: self class >> #test001doNothing;
		addMethod: self class >> #test002filterMethod.
	extensions := module extendedClasses.
	class := extensions first.
	transliterator
		removeMethodsSuchThat: [:m | m selector beginsWith: 'test002'];
		transliterate.
	self
		assert: module name equals: 'TestModule';
		assert: extensions size equals: 1;
		assert: class name equals: 'ModuleTransliteratorTest';
		assert: class methods size equals: 1;
		assert: class methods first selector equals: #test001doNothing
]

{ #category : #private }
ModuleTransliteratorTest >> test010removeClass [
	| extensions test |
	builder
		addMethod: self class >> #test001doNothing;
		addMethod: self class >> #test010removeClass;
		addMethodCompiling: '& anInteger 	^self bitAnd: anInteger' in: LargeInteger;
		addMethodCompiling: 'abs   ^self' in: LargePositiveInteger;
		addClassDefinition: LargeNegativeInteger;
		calculateDependencies.
	transliterator removeClass: 'LargeInteger'; transliterate.
	extensions := module extendedClasses.
	test := extensions first.
	self
		assert: module classes size equals: 0;
		assert: extensions size equals: 1;
		assert: test name equals: 'ModuleTransliteratorTest';
		assert: test methods size equals: 1;
		assert: test methods first selector equals: #test001doNothing
]

{ #category : #private }
ModuleTransliteratorTest >> test020removeInstVar [
	| extensions point |
	builder
		addMethod: Point >> #x;
		addMethod: Point >> #y.
	transliterator removeInstVar: 'x' in: 'Point'; transliterate.
	extensions := module extendedClasses.
	point := extensions first.
	self
		assert: extensions size equals: 1;
		assert: point name equals: 'Point';
		assert: point methods size equals: 1;
		assert: point methods first selector equals: #y
]

{ #category : #private }
ModuleTransliteratorTest >> test030renameInstVar [
	| extensions point x source |
	builder
		addMethod: Point >> #x;
		addMethod: Point >> #y.
	transliterator
		renameIdentifier: 'x' to: 'z' class: 'Point';
		transliterate.
	extensions := module extendedClasses.
	point := extensions first.
	x := point methods first.
	source := x ast statements first source.
	self
		assert: extensions size equals: 1;
		assert: point name equals: 'Point';
		assert: point instVarNames asArray equals: #('z' 'y');
		assert: point methods size equals: 2;
		assert: x selector equals: #x;
		deny: (source includesString: 'x');
		assert: (source includesString: 'z')
]

{ #category : #private }
ModuleTransliteratorTest >> test031renameClassVar [
	| spec extensions source large method |
	spec := builder addClassExtension: LargeInteger.
	spec cvarNames: #('Base' 'DigitLength').
	builder
		addMethodCompiling: 'digitAt: index put: integer
	| valid |
	valid := integer bitAnd: Base - 1.
	self uShortAtOffset: index - 1 * DigitLength put: valid' in: LargeInteger.
	transliterator
		renameIdentifier: 'Base' to: 'Foo' class: 'LargeInteger';
		transliterate.
	extensions := module extendedClasses.
	large := extensions first.
	method := large methods first.
	source := method ast source.
	self
		assert: large classVarNames asArray sort equals: #('DigitLength' 'Foo');
		deny: (source includesString: 'Base');
		assert: (source includesString: 'Foo')
]

{ #category : #private }
ModuleTransliteratorTest >> test032renamePoolVar [
	| spec pool extensions character method source |
	spec := builder addClassExtension: Character.
	pool := PoolDictionary new at: 'Cr' put: 1; yourself.
	spec classVariables at: 'Characters' put: pool.
	builder addMethodCompiling: 'cr	^Cr' in: Character class.
	transliterator renameIdentifier: 'Cr' to: 'Foo'; transliterate.
	extensions := module extendedClasses.
	character := extensions first.
	method := character metaclass methods first.
	source := method ast source.
	self
		deny: (source includesString: 'Cr');
		assert: (source includesString: 'Foo')
]

{ #category : #private }
ModuleTransliteratorTest >> test033renameSharedPool [
	| spec |
	spec := builder addClassDefinition: Character.
	spec sharedPools add: #CharacterConstants.
	transliterator
		renameIdentifier: 'CharacterConstants' to: 'Characters';
		transliterate.
	self
		assert: module classes first sharedPools asArray sort equals: #(#'Characters')
]
