require 'socket'
requireLibrary '../../IO'
requireClass 'Stream'


module Kesh
	module IO
	
		class FileStream < Stream
		
			def initialize( filename, mode )
				@filename = filename
				@mode = mode
				
				@file = File.new( filename, mode )
				raise RuntimeError if ( @file == nil )
			end
			
			
			def read( maxLength, block = true )
				return @file.read( maxLength ) if block
				return @file.read_nonblock( maxLength ) if !block
			end
			
			
			def peak( maxLength, block = true )
				string = @file.read( maxLength ) if block
				string = @file.read_nonblock( maxLength ) if !block				
				@file.seek( string.length * -1, IO::SEEK_CUR )				
				return string
			end
			
			
			def write( string )
				@file.write( string )
			end
			
			
			def close()
				@file.close()
			end
		
		end		
		
	end
end
