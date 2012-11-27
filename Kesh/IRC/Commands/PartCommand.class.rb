requireLibrary '../../../IRC'

module Kesh
	module IRC
		module Commands
		
			class PartCommand < Kesh::IRC::Command
			
				attr_reader :channel
				attr_reader :message
				
				def initialize( channel, message = nil )
					super()
					Kesh::ArgTest::type( "channel", channel, Kesh::IRC::Channel )
					Kesh::ArgTest::type( "message", message, String, true )
					message.strip!() unless ( message == nil )
					@channel = channel
					@message = message
				end
				

				def format
					return "PART #{@channel.name} :#{@message}" unless ( @message == nil || @message == "" )
					return "PART #{@channel.name}"
				end				
								
			end
		
		end
	end
end