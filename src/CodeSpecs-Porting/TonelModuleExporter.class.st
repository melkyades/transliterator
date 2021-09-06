"
Copyright (c) 2021 Quorum Software.
	See (MIT) license in root directory.
"
Class {
	#name : #TonelModuleExporter,
	#superclass : #Object,
	#instVars : [
		'module',
		'path',
		'compatible'
	],
	#category : #'CodeSpecs-Porting'
}

{ #category : #'instance creation' }
TonelModuleExporter class >> new [
	^super new initialize
]

{ #category : #accessing }
TonelModuleExporter >> compatible: aBoolean [
	compatible := aBoolean
]

{ #category : #accessing }
TonelModuleExporter >> copyright [
	^'Copyright (c) ' , Date today year asString , ' Quorum Software.'
]

{ #category : #private }
TonelModuleExporter >> createFolder [
	self moduleFolder createPath
]

{ #category : #private }
TonelModuleExporter >> definition [
	| names |
	names := (module classes collect: #name) sort.
	^OrderedDictionary new
		at: #name put: self moduleName asSymbol;
		at: #requires
		put: module dependencies keys asArray sort;
		at: #classes put: names asArray;
		yourself
]

{ #category : #export }
TonelModuleExporter >> export [
	self
		createFolder;
		exportMetadata;
		exportClasses;
		exportExtendedClasses
]

{ #category : #export }
TonelModuleExporter >> exportClass: aClassSpec [
	| filename |
	filename := self filenameForClass: aClassSpec.
	self withFileNamed: filename do: [:stream | | writer |
		stream truncate.
		writer := TonelWriter on: stream.
		writer
			category: self moduleName;
			class: aClassSpec;
			methods: (aClassSpec metaMethods sortBy: #selector)
				& (aClassSpec methods sortBy: #selector);
			write]
]

{ #category : #export }
TonelModuleExporter >> exportClasses [
	module classes do: [:class | self exportClass: class]
]

{ #category : #export }
TonelModuleExporter >> exportEmptyClass: aClassSpec [
	| filename |
	filename := self filenameForClass: aClassSpec.
	self withFileNamed: filename do: [:stream | | writer |
		writer := TonelWriter on: stream.
		writer
			category: self moduleName;
			class: aClassSpec;
			methods: #();
			write]
]

{ #category : #export }
TonelModuleExporter >> exportEmptyClasses [
	module classes do: [:class | self exportEmptyClass: class]
]

{ #category : #export }
TonelModuleExporter >> exportExtendedClass: aClassSpec [
	| filename |
	filename := self filenameForExtension: aClassSpec.
	self withFileNamed: filename do: [:stream | 
		stream truncate.
		(TonelWriter on: stream)
			writeMethods: (aClassSpec metaMethods sortBy: #selector)
				& (aClassSpec methods sortBy: #selector)]
]

{ #category : #export }
TonelModuleExporter >> exportExtendedClasses [
	module extendedClasses do: [:class | self exportExtendedClass: class]
]

{ #category : #export }
TonelModuleExporter >> exportMetadata [
	| package |
	package := self moduleFolder \ 'package.st'.
	self withFileNamed: package do: [:stream | 
		stream nextPutAll: 'Package '.
		(STONWriter on: stream) writeMap: self definition]
]

{ #category : #services }
TonelModuleExporter >> exportPseudoTonel [
	compatible := false.
	self export
]

{ #category : #private }
TonelModuleExporter >> exportedName [
	^module name copy replace: Character space with: $\
]

{ #category : #private }
TonelModuleExporter >> filenameForClass: aClassSpec [
	| name |
	name := aClassSpec name asFilename.
	compatible ifTrue: [name := name appendExtension: 'class'].
	^self moduleFolder \ name appendExtension: 'st'
]

{ #category : #private }
TonelModuleExporter >> filenameForExtension: aClassSpec [
	| name |
	name := aClassSpec name asFilename.
	compatible ifTrue: [name := name appendExtension: 'extension'].
	^self moduleFolder \ name appendExtension: 'st'
]

{ #category : #accessing }
TonelModuleExporter >> license [
	^'See (MIT) license in root directory.'
]

{ #category : #accessing }
TonelModuleExporter >> module: aModuleSpec [
	module := aModuleSpec
]

{ #category : #private }
TonelModuleExporter >> moduleFolder [
	^path \ self exportedName
]

{ #category : #private }
TonelModuleExporter >> moduleName [
	^self exportedName asFilename entityName
]

{ #category : #accessing }
TonelModuleExporter >> path: aFilename [
	path := aFilename asFilename
]

{ #category : #private }
TonelModuleExporter >> withFileNamed: aFilename do: aBlock [
	| stream |
	stream := aFilename asFile writeStream.
	stream
		truncate;
		eol: String lf;
		nextPut: $";
		crtab;
		nextPutAll: self copyright;
		crtab;
		nextPutAll: self license;
		cr;
		nextPut: $";
		cr;
		cr.
	[aBlock evaluateWith: stream] ensure: [stream close]
]
