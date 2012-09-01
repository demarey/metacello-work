| gitPath fileInBlock |
Transcript cr; show: 'travis---->travisTest.st'.

gitPath := (FileDirectory default directoryNamed: 'git_cache') fullName.

(Smalltalk at: #FileDirectory ifAbsent: [])
  ifNil: [ 
    fileInBlock := [:fileName | 
      ((Smalltalk at: #FileSystem) workingDirectory / 'metacello-work' / 'tests' / fileName)
        readStreamDo: [:fileStream | fileStream fileIn ] ] ]
  ifNotNil: [:fileDirectoryClass | 
    fileInBlock := [:fileName |
      (fileDirectoryClass on: gitPath, '/metacello-work/tests')
        fileNamed: fileName
        do: [:fileStream | fileStream fileIn ] ] ].

fileInBlock value: 'MetacelloTravisCI.st'.

(Smalltalk at: #MetacelloTravisCI) test.