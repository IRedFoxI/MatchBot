requireLibrary '../../../IRC'

module Kesh
	module IRC
		module Commands
		
			class QuitCommand < Kesh::IRC::Command
			
				attr_reader :message
				
				def initialize( message = nil )
					super()
					Kesh::ArgTest::type( "message", message, String, true )
					message.strip!() unless ( message == nil )
					@message = message
				end
				

				def format
					return "QUIT :#{@message}" unless ( @message == nil || @message == "" )
					return "QUIT"
				end				
				
			end
		
		end
	end
end