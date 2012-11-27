requireLibrary '../../Asynchronousity'
requireLibrary '../../DataStructures'

module Kesh
	module Asynchronousity
	
		class TimerComparer < Kesh::DataStructures::Comparer
		
			def compare( a, b )
				Kesh::ArgTest::type( "a", a, TimerCallback )
				Kesh::ArgTest::type( "b", b, TimerCallback )
				return ( a.start - b.start )
			end
			
		end
	
	end
end
