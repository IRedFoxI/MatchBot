requireLibrary '../../IRC'

module Kesh
	module IRC
			
		class Topic			
		
			attr_accessor :body
			attr_accessor :setBy				
			
			def initialize( body = nil, setBy = nil )
				Kesh::ArgTest::type( "body", body, String, true )
				Kesh::ArgTest::type( "setBy", setBy, String, true )
				@body = body
				@setBy = setBy
			end				
			
		end			
			
	end
end