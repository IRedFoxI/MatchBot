requireLibrary '../../../IRC'

module Kesh
	module IRC
		module Commands
		
			class IsOnCommand < Kesh::IRC::Command
			
				attr_reader :client
				
				def initialize( client )
					super()
					Kesh::ArgTest::type( "client", client, Kesh::IRC::Client )
					@client = client
				end
				

				def format
					return "ISON #{@client.name}"
				end				
				
			end
		
		end
	end
end