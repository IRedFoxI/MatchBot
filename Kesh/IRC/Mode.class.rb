requireLibrary '../../IRC'

module Kesh
	module IRC
			
		class Mode
		
			# :mode_type_flag
			# :mode_type_parameter
			# :mode_type_clientlist
			# :mode_type_masklist				
			
			attr_reader :char
			attr_reader :type
			
			def initialize( char, type )
				Kesh::ArgTest::type( "char", char, String )
				Kesh::ArgTest::stringLength( "char", char, 1, 1 )
				Kesh::ArgTest::type( "type", type, Symbol )
				Kesh::ArgTest::valueRange( "type", type, [ :mode_type_flag, :mode_type_parameter, :mode_type_clientlist, :mode_type_masklist ] )
				@char = char
				@type = type
			end				
			
		end			
				
	end
end
