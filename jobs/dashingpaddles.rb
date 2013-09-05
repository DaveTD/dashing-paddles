SCHEDULER.every'10s', :first_in => 1 do |work|
	work.unschedule
	send_event('dashingpaddles', value: rand(100))
	y = Gameserver.new
end

