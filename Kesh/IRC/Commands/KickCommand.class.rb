requireLibrary '../../../IRC'

module Kesh
	module IRC
		module Commands
		
			class KickCommand < Kesh::IRC::Command
			
				attr_reader :channel
				attr_reader :target
				attr_reader :message
				
				def initialize( channel, target, message = nil )
					super()
					Kesh::ArgTest::type( "channel", channel, Kesh::IRC::Channel )
					Kesh::ArgTest::type( "target", target, Kesh::IRC::Client )
					Kesh::ArgTest::type( "message", message, String, true )
					message.strip!() unless ( message == nil )
					@channel = channel
					@target = target
					@message = message
				end
				

				def format
					return "KICK #{@channel.name} #{@target.name} #{@message}" unless ( @message == nil || @message == "" )
					return "KICK #{@channel.name} #{@target.name}"
				end				
				
			end
		
		end
	end
end