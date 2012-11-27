module Kesh
	module IO
	
		class Serialisable
		
			def serialise( stream )
				raise NotImplementedError
			end
			
			def Serialisable.deserialize( stream )
				raise NotImplementedError
			end
			
		end
		
	end
end