requireLibrary '../../Asynchronousity'

module Kesh
	module Asynchronousity
	
		# A class containing multiple events and exposing their methodss.
		class EventSystem
		
			# Initialize our system!
			def initialize()
				@events = Hash[]
				@mutex = Mutex.new
			end
			
			# Add an Event if it doesn't already exist.
			#
			# * id: Symbol representing the id of the Event.
			# * stoppable: Bool representing whether the 'before' call can stop the Event.
			#
			# Returns true if the Event was added, false otherwise.
			def addEvent( id, stoppable )
				Kesh::ArgTest::type( "id", id, Symbol )
				Kesh::ArgTest::valueRange( "stoppable", stoppable, [ true, false ] )
				
				exists = false
				
				@mutex.synchronize {
					exists = ( @events[ id ] != nil )
					@events[ id ] = Event.new( id, stoppable ) if !exists
				}
				
				return !exists
			end
			
			
			# Returns true if the Event was removed, false otherwise.
			#
			# * id: Symbol representing the id of the Event.
			def removeEvent( id )
				Kesh::ArgTest::type( "id", id, Symbol )
				
				exists = false
				
				@mutex.synchronize {
					exists = ( @events[ id ] != nil )
					@events.delete( id ) if exists
				}
				
				return exists
			end
			
			
			# Returns true if the Event exists, false otherwise.
			#
			# * id: Symbol representing the id of the Event.
			def hasEvent?( id )
				Kesh::ArgTest::type( "id", id, Symbol )
				
				exists = false
				
				@mutex.synchronize {
					exists = ( @events[ id ] != nil )
				}
				
				return exists
			end
			
			
			# Returns the number of Events.
			def eventCount()
				count = 0
				
				@mutex.synchronize {
					count = @events.count()
				}
				
				return count
			end			
			
			
			# Add a callback to the end of an Event's call list, if it's not already added.
			#
			# * id: Symbol representing the id of the Event.
			# * mthd: Method that is called when the Event is triggered.
			#
			# Returns true if the callback was added, false otherwise.
			def addCallback( id, mthd )
				Kesh::ArgTest::type( "id", id, Symbol )
				Kesh::ArgTest::type( "mthd", mthd, Method )
				
				added = false
				
				@mutex.synchronize {			
					added = @events[ id ].add( mthd ) if ( @events[ id ] != nil )
				}

				return added
			end
						
			
			# Add a callback to the start of an Event's call list, if it's not already added.
			#
			# * id: Symbol representing the id of the Event.
			# * mthd: Method that is called when the Event is triggered.
			#
			# Returns true if the callback was added, false otherwise.
			def addPriorityCallback( id, mthd )
				Kesh::ArgTest::type( "id", id, Symbol )
				Kesh::ArgTest::type( "mthd", mthd, Method )	
				
				added = false
				
				@mutex.synchronize {			
					added = @events[ id ].addPriority( mthd ) if ( @events[ id ] != nil )
				}
				
				return added
			end
			
	
			# Remove a callback from an Event's call list.
			#
			# * id: Symbol representing the id of the Event.
			# * mthd: Method that is called when the Event is triggered.
			#
			# Returns true if the callback was removed, false otherwise.
			def removeCallback( id, mthd )
				Kesh::ArgTest::type( "id", id, Symbol )
				Kesh::ArgTest::type( "mthd", mthd, Method )
				
				removed = false
				
				@mutex.synchronize {		
					removed = @events[ id ].remove( mthd ) if ( @events[ id ] != nil )
				}
				
				return removed
			end
			
			
			# Returns whether the Event has this callback.
			#
			# * id: Symbol representing the id of the Event.
			# * mthd: Method that is called when the Event is triggered.
			def hasCallback?( id, mthd )
				Kesh::ArgTest::type( "id", id, Symbol )
				Kesh::ArgTest::type( "mthd", mthd, Method )	
				
				has = false
				
				@mutex.synchronize {			
					has = @events[ id ].include?( mthd ) if ( @events[ id ] != nil )
				}
				
				return has
			end
						
			
			# Returns hte number of callbacks for an Event.
			#
			# * id: Symbol representing the id of the Event.
			def callbackCount( id )
				Kesh::ArgTest::type( "id", id, Symbol )
				
				count = 0
				
				@mutex.synchronize {
					count = @events[ id ].count() if ( @events[ id ] != nil )
				}
				
				return count
			end							

			
			# Calls all the methods associated with an Event. 
			#
			# If 'stoppable' is true and one of the callbacks returns false, this will cause the Event to stop executing and return false.
			#
			# Parameters:
			# * id: Symbol representing the id of the Event.
			# * sender: Object that generated the Event.
			# * type: Before or after type.
			# * parameter: Object containing information about the Event.
			#
			# Returns:
			# * False: Event doesn't exist
			# * False: Event stop was called.
			# * True: Event executed completed without a stop call.
			def call( id, sender, type, parameter = nil )
				Kesh::ArgTest::type( "id", id, Symbol )
				Kesh::ArgTest::type( "sender", sender, Object )
				Kesh::ArgTest::valueRange( "type", type, [ :event_type_before, :event_type_after ] )
				Kesh::ArgTest::type( "parameter", parameter, Object, true )
				
				event = nil
				
				@mutex.synchronize {			
					event = @events[ id ] unless ( @events[ id ] == nil )
				}
				
				return false if ( event == nil )
				return event.call( sender, type, parameter )
			end
			
		end
		
	end
end			