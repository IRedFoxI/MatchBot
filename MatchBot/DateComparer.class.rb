require 'date'
require File.expand_path( File.dirname( __FILE__ ) + '/../Loader.library.rb' )
requireLibrary '../DataStructures'

module MatchBot

	class DateComparer < Kesh::DataStructures::Comparer
	
		def compare( a, b )
			return ( a.date - b.date )
		end
		
	end
	
end
