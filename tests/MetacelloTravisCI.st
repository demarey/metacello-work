'From Pharo1.4 of 18 April 2012 [Latest update: #14457] on 1 September 2012 at 11:11:30 am'!
Object subclass: #MetacelloTravisCI
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'XXX'!

!MetacelloTravisCI methodsFor: 'public' stamp: 'dkh 9/1/2012 10:41'!
fetch
    [ 
    | cacheRepository |
    cacheRepository := MCDirectoryRepository new directory: (FileDirectory default directoryNamed: 'monticello').
    self
        loadMetacello: [ :version :loads | 
            version cacheRepository: cacheRepository.
            version fetch: loads ] ]
        ensure: [ 
            | stream |
            stream := Transcript.
            (Smalltalk associationAt: #'Transcript') value: (Smalltalk at: #'OLDTranscript').
            stream close ]! !

!MetacelloTravisCI methodsFor: 'public' stamp: 'dkh 9/1/2012 11:09'!
test
    | cacheRepository version |
    [ 
    cacheRepository := MCDirectoryRepository new directory: (FileDirectory default directoryNamed: 'monticello').
    version := self
        loadMetacello: [ :aVersion :loads | 
            aVersion repositoryOverrides: {cacheRepository}.
            aVersion load: loads ].
    self runTestFor: version ]
        ensure: [ 
            | stream |
            stream := Transcript.
            (Smalltalk associationAt: #'Transcript') value: (Smalltalk at: #'OLDTranscript').
            stream close ]! !


!MetacelloTravisCI methodsFor: 'private' stamp: 'dkh 9/1/2012 11:10'!
failFilename
    ^ 'TravisCIFailure.txt'! !

!MetacelloTravisCI methodsFor: 'private' stamp: 'dkh 9/1/2012 10:44'!
loadMetacello: loadBlock
    | cacheRepository versionString version gitPath repository |
    cacheRepository := MCDirectoryRepository new directory: (FileDirectory default directoryNamed: 'monticello').
    versionString := #'stable'.
    Gofer new
        url: 'http://ss3.gemstone.com/ss/FileTree';
        package: 'ConfigurationOfFileTree';
        load.
    version := (Smalltalk at: #'ConfigurationOfFileTree') project version: '1.0'.
    loadBlock value: version value: 'default'.
    Gofer new
        url: 'http://seaside.gemstone.com/ss/metacello';
        package: 'ConfigurationOfGofer';
        load.
    version := (Smalltalk at: #'ConfigurationOfGofer') project version: #'stable'.
    loadBlock value: version value: 'Tests'.
    gitPath := (FileDirectory default directoryNamed: 'git_cache') fullName.
    repository := MCFileTreeRepository new
        directory: (FileDirectory on: gitPath , '/metacello-work/repository');
        yourself.
    Gofer new
        repository: repository;
        package: 'ConfigurationOfMetacello';
        load.
    version := (Smalltalk at: #'ConfigurationOfMetacello') project version: versionString.
    version repositoryOverrides: {repository}.
    loadBlock
        value: version
        value:
            #('Metacello-ToolBox' 'Metacello-TestsCore' 'Metacello-TestsTutorial' 'Metacello-TestsMC' 'Metacello-TestsReference').
    ^ version! !

!MetacelloTravisCI methodsFor: 'private' stamp: 'dkh 9/1/2012 11:10'!
runTestFor: version
    | cacheRepository successFilename failFilename suite result resultsFileName |
    (Smalltalk at: #'MetacelloPlatform') current authorName: 'testMonkey'.	"These tests save code ... need an Author"
    successFilename := self successFilename.
    failFilename := self failFilename.
    suite := TestCase suiteClass named: ' Metacello Test Suite'.
    (version currentlyLoadedClassesInVersion select: [ :cl | cl inheritsFrom: TestCase ])
        do: [ :cl | 
            cl isAbstract
                ifFalse: [ suite addTest: cl buildSuiteFromSelectors ] ].
    result := suite run.
    resultsFileName := result defects isEmpty
        ifTrue: [ successFilename ]
        ifFalse: [ failFilename ].
    FileDirectory default
        forceNewFileNamed: resultsFileName
        do: [ :fileStream | 
            fileStream lineEndConvention: #'lf'.
            fileStream
                nextPutAll: '***********************************************';
                cr.
            fileStream
                tab;
                nextPutAll: 'Results for ' , suite name;
                cr;
                nextPutAll: result printString;
                cr.
            fileStream
                nextPutAll: '***********************************************';
                cr.
            result failures notEmpty
                ifTrue: [ 
                    fileStream
                        nextPutAll: '*** FAILURES ***';
                        nextPutAll: '****************';
                        cr ].
            result failures
                do: [ :each | 
                    fileStream tab
                        nextPutAll: each class name asString , ' debug: ' , each selector printString , '.';
                        cr ].
            result errors notEmpty
                ifTrue: [ 
                    fileStream
                        nextPutAll: '*** ERRORS ***';
                        nextPutAll: '****************';
                        cr ].
            result errors
                do: [ :each | 
                    fileStream tab
                        nextPutAll: each class name asString , ' debug: ' , each selector printString , '.';
                        cr ].
            fileStream
                nextPutAll: '***********************************************';
                cr ]! !

!MetacelloTravisCI methodsFor: 'private' stamp: 'dkh 9/1/2012 11:10'!
successFilename
    ^ 'TravisCISuccess.txt'! !
