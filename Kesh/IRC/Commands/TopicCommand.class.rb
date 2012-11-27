requireLibrary '../../../IRC'

module Kesh
	module IRC
		module Commands
		
			class TopicCommand < Kesh::IRC::Command
			
				attr_reader :channel
				attr_reader :body
				
				def initialize( channel, body = nil )
					super()
					Kesh::ArgTest::type( "channel", channel, Kesh::IRC::Channel )
					Kesh::ArgTest::type( "body", body, String, true )
					body.strip!() unless ( body == nil )
					@channel = channel
					@body = body
				end
				

				def format
					return "TOPIC #{@channel.name} :#{@body}" unless ( @body == nil || @body == "" )
					return "TOPIC #{@channel.name}"
				end				
				
			end
		
		end
	end
end