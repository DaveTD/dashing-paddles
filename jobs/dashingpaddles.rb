<<<<<<< HEAD


SCHEDULER.every'10s', :first_in => 1 do |work|
	work.unschedule
=======
SCHEDULER.every'10s', :first_in => 1 do |work|
	work.unschedule
	send_event('dashingpaddles', value: rand(100))
>>>>>>> aa96ad53c20cdc17e6707e9f7670da9dbf642414
	y = Gameserver.new
end

