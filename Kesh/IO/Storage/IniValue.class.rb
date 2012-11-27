requireLibrary '../../../IO'
requireClass '../Serialisable'

module Kesh
	module IO
		module Storage
	
			class IniValue < Kesh::IO::Serialisable
			
				attr_reader :name
				attr_accessor :value
				
				def initialize( name, value )
					@name = name
					@value = value
				end
				
				
				def serialise( stream )
					ArgTest::type( "stream", stream, Kesh::IO::Stream )
					stream.writeLine( @name + "=" + @value.to_s )
				end
				
				
				def IniValue.deserialise( stream )
					ArgTest::type( "stream", stream, Kesh::IO::Stream )
					
					line = stream.readLine()
					return nil if ( line == nil )
					return nil if ( line.length == 0 )
					
					if ( !line[ /^([^=]+)=(.+)?$/ ] )
						puts line
						raise SyntaxError
					end
					
					return IniValue.new( $1, ( $2 != nil ? $2.chomp : nil ) )
				end
				
			end
			
		end		
	end
end
	