requireLibrary '../../IRC'
requireClass 'Mode'

module Kesh
	module IRC
			
		class ClientListMode < Mode

			attr_reader :prefix
			
			def initialize( char, type, prefix )
				Kesh::ArgTest::type( "prefix", prefix, String )
				Kesh::ArgTest::stringLength( "prefix", prefix, 1, 1 )
				super( char, type )
				@prefix = prefix
			end				
			
		end			
				
	end
end
