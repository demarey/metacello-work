actions
merge: description type: type

	| spec |
	spec := 
		(self project repositorySpec)
			description: description;
			type: type;
			yourself.
	self addMember: 
		(self mergeMember 
			name: spec name;
			spec: spec;
			yourself)