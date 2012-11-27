requireLibrary '../../Asynchronousity'

module Kesh
	module Asynchronousity
	
		# A class representing a Job to be executed.
		class Job
		
			# Status of the Job.
			#
			# * :job_status_waiting
			# * :job_status_running
			# * :job_status_complete
			# * :job_status_error			
			attr_reader :status
			
			# Exception thrown by the Job.
			attr_reader :exception
			
			# State object passed to the callbacks.
			attr_reader :stateObj
			
			# Initialize our Job!
			#
			# * workMethod: Called to start the Job.
			# * endMethod: Called when the Job is finished.
			# * stateObj: Passed to the methods when they are called.
			def initialize( workMethod, endMethod, stateObj = nil )
				Kesh::ArgTest::type( "workMethod", workMethod, Method )
				Kesh::ArgTest::type( "@endMethod", endMethod, Method, true )
				Kesh::ArgTest::type( "stateObj", stateObj, Object, true )
				@workMethod = workMethod
				@endMethod = endMethod
				@stateObj = nil
				@status = :job_status_waiting
				@exception = nil
			end
			
			
			# Performs the workMethod callback.
			def work()
				begin
					raise RuntimeError.new( "Unable to start job." ) if ( canStart() == false )
					@status = :job_status_running						
					@workMethod.call( self )
					@status = :job_status_complete
					workFinished()
					return true
					
				rescue Exception => ex
					@exception = ex
					@status = :job_status_error
					workFinished()
					return false
					
				end
			end
			
			
			private
			def workFinished()
				begin
					@endMethod.call( self ) unless ( @endMethod == nil )
				rescue Exception
				end
			end
			
			
			public
			# Returns true if the Job is able to be started, false otherwise.
			def canStart()
				return true
			end
			
		end
		
	end
end
				