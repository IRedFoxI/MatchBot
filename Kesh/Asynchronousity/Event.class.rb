requireLibrary '../../Asynchronousity'

module Kesh
	module Asynchronousity
	
		# A class that handles callbacks.
		#
		# The following symbols are used:
		# * :event_type_before : The Event is called before something happened. Can be stopped. Possibly.
		# * :event_type_after : The Event is called after something happened. Cannot be stopped.
		class Event
		
			# Symbol representing the id of the Event
			attr_reader :id
			
			# Bool deciding whether a 'before' call can be stopped.
			attr_reader :stoppable
			
			# Initialize our Event!
			#
			# * id: Symbol representing the id of the Event.
			# * stoppable: If true, a callback returning false will stop the execution of the Event.
			def initialize( id, stoppable )
				Kesh::ArgTest::type( "id", id, Symbol )
				Kesh::ArgTest::valueRange( "stoppable", stoppable, [ true, false ] )
				@id = id
				@stoppable = stoppable
				@methods = []
				@mutex = Mutex.new
			end
			
			
			# Add a callback to the end of an Event's call list, if it's not already  added.
			#
			# * mthd: Method that is called when the Event is triggered.
			#
			# Returns return if the callback was added.
			def add( mthd )
				Kesh::ArgTest::type( "mthd", mthd, Method )
				
				contains = false
				
				@mutex.synchronize {
					contains = @methods.include?( mthd )
					@methods << mthd if !contains				
				}
				
				return !contains
			end
			
			
			# Add a callback to the start of an Event's call list, if it's not already added.
			#
			# * mthd: Method that is called when the Event is triggered.
			#
			# Returns true of the callback was added.
			def addPriority( mthd )
				Kesh::ArgTest::type( "mthd", mthd, Method )
				
				contains = false
				
				@mutex.synchronize {
					contains = @methods.include?( mthd )
					@methods.unshift( mthd ) if !contains
				}

				return !contains
			end
						
			
			# Remove a callback from an Event's call list.
			#
			# * id: Symbol representing the id of the Event.
			# * mthd: Method that is called when the Event is triggered.
			#
			# Returns true if the callback was removed.
			def remove( mthd )
				Kesh::ArgTest::type( "mthd", mthd, Method )
				
				contains = false
				
				@mutex.synchronize {
					contains = @methods.include?( mthd )
					@methods.remove( mthd ) if contains
				}
								
				return contains
			end
			
			
			# Returns true if the Event has this callback, false otherwise.
			#
			# * mthd: Method that is called when the Event is triggered.
			def has?( mthd )
				Kesh::ArgTest::type( "mthd", mthd, Method )

				contains = false
				
				@mutex.synchronize {
					contains = @methods.include?( mthd )
				}
								
				return contains
			end
			
		
			# Returns the number of callbacks for this Event.
			def count()
				count = 0
				
				@mutex.synchronize {
					count = @methods.size
				}
								
				return count
			end
			
			
			# Calls all the methods associated with an Event.  
			#
			# If 'stoppable' is true and one of the callbacks returns false, this will cause the Event to stop executing and return false.
			#
			# Parameters:
			# * sender: Object that generated the Event.
			# * type: Before or after type.
			# * parameter: Object containing information about the Event.
			#
			# Returns:
			# * False: Event stop was called.
			# * True: Event executed completed without a stop call.
			def call( sender, type, parameter = nil )
				Kesh::ArgTest::type( "sender", sender, Object )
				Kesh::ArgTest::valueRange( "type", type, [ :event_type_before, :event_type_after ] )
				Kesh::ArgTest::type( "parameter", parameter, Object, true )
				
				callbacks = []
				
				@mutex.synchronize {
					callbacks = @methods + []
				}
				
				callbacks.each do |m|
					continue = m.call( @id, sender, type, parameter )
					return false if ( @stoppable && continue == false )
				end
				
				return true
			end
			
		end
		
	end
end
						
			