require 'celluloid/autostart'

class Timer
	include Celluloid

	def initialize(target)
		@target = target
	end

	def startTicking
		loop do
			@target.gameTick
			sleep(0.02)
		end
		
	end

end
