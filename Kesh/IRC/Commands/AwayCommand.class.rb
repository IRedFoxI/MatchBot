requireLibrary '../../../IRC'

module Kesh
	module IRC
		module Commands
		
			class AwayCommand < Kesh::IRC::Command
			
				attr_reader :message
				
				def initialize( message = nil )
					super()
					Kesh::ArgTest::type( "message", message, String, true )
					message.strip!() unless ( message == nill )
					@message = message
				end
				

				def format
					return "AWAY #{@message}" unless ( @message == nil || @message == "" )
					return "AWAY"
				end				
				
			end
		
		end
	end
end