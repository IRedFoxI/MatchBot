requireLibrary '../../IRC'

module Kesh
	module IRC
			
		class ChannelModeList
		
			attr_reader :channel
			attr_reader :mode
			attr_reader :list
			
			def initialize( channel, mode, list = [] )
				Kesh::ArgTest::type( "channel", channel, Channel )
				Kesh::ArgTest::type( "mode", mode, Mode )
				Kesh::ArgTest::type( "list", list, Array )
				@channel = channel
				@mode = mode
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
			
			
			def matches?( value )
				Kesh::ArgTest::type( "value", value, nil )
				return false unless ( @mode.type == :mode_masklist )
				return ( @list.index { |v| value[/#{v}/] } != nil )
			end
			
			
			def matchAgainst?( value )
				Kesh::ArgTest::type( "value", value, nil )
				return ( @list.index { |v| v[/#{value}/] } != nil )
			end
			
		end
		
	end
end
		