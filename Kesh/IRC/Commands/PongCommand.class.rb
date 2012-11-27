requireLibrary '../../../IRC'

module Kesh
	module IRC
		module Commands
		
			class PongCommand < Kesh::IRC::Command
			
				attr_reader :token
				
				def initialize( token )
					super()
					Kesh::ArgTest::type( "token", token, String )
					Kesh::ArgTest::stringLength( "token", token, 1 )
					@token = token
				end
	
				def format
					"PONG :#{@token}"
				end
				
			end
		
		end
	end
end