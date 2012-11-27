requireLibrary '../../IRC'

module Kesh
	module IRC
			
		class ChannelModeListDelta
		
			attr_reader :channel
			attr_reader :mode
			attr_reader :status
			attr_reader :list
			
			def initialize( channel, mode, status, list = [] )
				Kesh::ArgTest::type( "channel", channel, Channel )
				Kesh::ArgTest::type( "mode", mode, Mode )
				Kesh::ArgTest::type( "status", status, [ TrueClass, FalseClass ] )
				Kesh::ArgTest::type( "list", list, Array )
				@channel = channel
				@mode = mode
				@status = status
				@list = list
			end
			
			
			def add( value )
				Kesh::ArgTest::type( "value", value, nil )
				i = @list.index( value )
				return false unless ( i == nil )
				@list << value 
				return true
			end
			
			
			def remove( value )
				Kesh::ArgTest::type( "value", value, nil )
				i = @list.index( value )
				return false if ( i == nil )
				@list.delete_at( i )
				return true
			end
			
			
			def include?( value )
				Kesh::ArgTest::type( "value", value, nil )
				return ( @list.index( value ) != nil )
			end
			
		end
		
	end
end
		