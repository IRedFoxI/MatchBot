requireLibrary '../../../IRC'

module Kesh
	module IRC
		module Commands
		
			class JoinCommand < Kesh::IRC::Command
			
				attr_reader :channel
				
				def initialize( channel, key = nil )
					super()
					Kesh::ArgTest::type( "channel", channel, Kesh::IRC::Channel )
					Kesh::ArgTest::type( "key", key, String, true )
					@channel = channel
					@key = key					
					@key.strip!() if ( @key != nil )
				end
				

				def format
					return "JOIN #{@channel.name} #{@key}" if ( @key != nil && @key != "" )
					return "JOIN #{@channel.name}"
				end
				
			end
		
		end
	end
end
