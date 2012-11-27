requireLibrary '../../../IRC'

module Kesh
	module IRC
		module Commands
		
			class NickCommand < Kesh::IRC::Command
			
				attr_reader :newName
				
				def initialize( newName )
					super()
					Kesh::ArgTest::type( "newName", newName, String )
					newName.strip!()
					Kesh::ArgTest::stringLength( "newName", newName, 1, 20 )
					@newName = newName
				end
	
				def format
					"NICK #{@newName}"
				end
				
			end
		
		end
	end
end