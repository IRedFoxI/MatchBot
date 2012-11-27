requireLibrary '../../IRC'

module Kesh
	module IRC
			
		class ChannelMode
		
			attr_reader :channel
			attr_reader :mode
			attr_accessor :status
			attr_accessor :parameter
			
			def initialize( channel, mode, status, parameter = nil )
				Kesh::ArgTest::type( "channel", channel, Channel )
				Kesh::ArgTest::type( "mode", mode, Mode )
				Kesh::ArgTest::type( "status", status, [ TrueClass, FalseClass ] )
				#Kesh::ArgTest::type( "parameter", parameter, String, true )
				@channel = channel
				@mode = mode
				@status = status
				@parameter = parameter
			end
			
			
			def toggle
				@status = !@status
				@parameter = nil if !@status
			end
			
		end
			
	end
end
		