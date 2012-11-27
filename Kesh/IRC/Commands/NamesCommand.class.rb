requireLibrary '../../../IRC'

module Kesh
	module IRC
		module Commands
		
			class NamesCommand < Kesh::IRC::Command
			
				attr_reader :channel
				
				def initialize( channel )
					super()
					Kesh::ArgTest::type( "channel", channel, Kesh::IRC::Channel )
					@channel = channel
				end
				

				def format
					return "NAMES #{@channel.name}"
				end				
				
			end
		
		end
	end
end