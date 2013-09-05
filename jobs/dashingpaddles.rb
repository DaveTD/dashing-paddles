

SCHEDULER.every'10s', :first_in => 1 do |work|
	work.unschedule
	y = Gameserver.new
end

