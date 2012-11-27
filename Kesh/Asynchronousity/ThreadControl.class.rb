module Kesh
	module Asynchronousity
	
		# A class that provides thread flow controls
		class ThreadControl
		
			# Status of the AutoSync.
			#
			# * :thread_status_idle
			# * :thread_status_working
			# * :thread_status_sleeping
			attr_reader :status
			
			# Initialize our Thread
			def initialize()
				@thread = Thread.new { work() }
				@status = :thread_status_idle
				@stop = false
			end
			
			
			def start()
				return false unless ( @status == :thread_status_idle )
				@status = :thread_status_working
				@stop = false					
				@thread.run
				return true
			end
			
			
			def wake()
				return false unless ( @status == :thread_status_sleeping )
				@stop = false
				@thread.wakeup
				return true
			end
			
			
			def stop()
				return false unless ( @status == :thread_status_working )
				@stop = true				
			end
			

			# Returns true if the thread is currently working.
			def working?()
				return ( @status == :worker_thread_status_working )
			end			
			
			protected
			def stopping?()
				return @stop
			end
			
			
			def notStopping()			
			end
			
			
			def afterStopping()			
			end
			
			
			def sleeping()
			end
			
			
			def wakingup()
			end
			
			
			private 
			def work()
				while true
					stopping = stopping?()
					notStopping() unless stopping
					
					if ( stopping )
						@status = :thread_status_sleeping
						sleeping()
						Thread.stop
						@status = :thread_status_working
						wakingup()
					end
					
					afterStopping()					
				end
			end
			
		end
		
	end
end
				