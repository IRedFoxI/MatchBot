requireLibrary '../../../IRC'

module Kesh
	module IRC
		module Commands
		
			class InviteCommand < Kesh::IRC::Command
			
				attr_reader :target
				attr_reader :channel
				
				def initialize( target, channel )
					super()
					Kesh::ArgTest::type( "target", target, Kesh::IRC::Client )
					Kesh::ArgTest::type( "channel", channel, Kesh::IRC::Channel )
					@target = target
					@channel = channel
				end
				

				def format
					return "INVITE #{@target.name} #{@channel.name}"
				end				
				
			end
		
		end
	end
end