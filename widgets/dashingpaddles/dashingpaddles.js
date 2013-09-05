var ws = null;
var wins = 0;
var you = 0;

function startGame()    
{
  if ("WebSocket" in window)
  {
     ws = new WebSocket("ws://0.0.0.0:8443");
     var gameSocket = null;
     ws.onopen = function()
     {
	requestGame(ws);
     };
     ws.onerror = function(err)
     {
	console.log('Error: ' + err.data);
     }
     ws.onmessage = function (evt) 
     { 
        var received_msg = evt.data;
	if (received_msg.substr(0,1) === "p")
	{
		ticket = received_msg.substr(2,received_msg.length - 1);
		console.log("Ticket: " + ticket);
		layoutWaiting(ws);
	}
	else if (received_msg.substr(0,1) === "g") {
		you = received_msg.substr(2,3);
		activategamekeys();
		layoutPlay();
	}
	else if (received_msg.substr(0,1) === "v") {
		victory();
	}
	else if (received_msg.substr(0,1) === "d") {
		defeat();
	}
	else if (received_msg.substr(0,1) === "s") {
		gamestate = received_msg.substr(1,received_msg.length - 1);
		redraw(gamestate);
	}
     };
     ws.onclose = function()
     { 
     };
  }
  else
  {
     alert("WebSocket NOT supported by your Browser!");
  }
}

function requestGame()
{
	ws.send("g");
}

function activategamekeys()
{
	var downpressed = false;
	var uppressed = false;
	document.onkeydown = function(event){
		event = event || window.event;
		var keycode = event.charCode || event.keyCode;
	   	if(keycode === 83){
			if (!downpressed) {
				//down();
				command('d');
				downpressed = true;
	   		}
		}
		if(keycode === 87){
			if (!uppressed){
				//up();
				command('u');
				uppressed = true;
			}
		}
	}
	document.onkeyup = function(event) { 
		event = event || window.event;
		var keycode = event.charCode || event.keyCode;

		if (downpressed && keycode === 87){ command('d'); uppressed = false; }
		else if (uppressed && keycode === 83) { command('u'); downpressed = false; }
		else if (keycode === 87) { command('s'); uppressed = false; }
		else if (keycode === 83) { command('s'); downpressed = false; }	
	
	}
}

function layoutWaiting()
{
	//console.log('adjusting widget appearance...');
	$("div#winner").hide();
	$("a#paddles1").text("Waiting for opponent to join...");
	$("a#paddles2").text("Click to accept defeat and cancel");
	$("a#paddles1").prop("href", "javascript:surrender()");
	$("a#paddles2").prop("href", "javascript:surrender()");
	$("div#p1score").text("0");
	$("div#p2score").text("0");
	$("div#instructions").hide();
	
}

function surrender()
{
	ws.send("q");
	defeat();
}

function layoutPlay()
{
	$("a#paddles1").text("");
	$("a#paddles2").text("");	
	$("div#gameArea").height(300);
	$("div#gameArea").width(500);
	$("div#gameArea").show();
	$("div#p1score").css( 'top', "2px" );
	$("div#p2score").css( 'top', "2px" );
	$("div#p1score").css( 'left', "2px" );
	$("div#p2score").css( 'right', "2px" );

}

function redraw(gamestate)
{
	//$("a#paddles1").text(gamestate);	
	var stateArray = gamestate.split(',');
	$("div#ball").css( 'left', stateArray[0] + "px" );
	$("div#ball").css( 'top', stateArray[1] + "px" );
	$("div#p1paddle").css( 'left', "15px" );
	$("div#p1paddle").css( 'top', stateArray[2] + "px" );
	$("div#p2paddle").css( 'left', "470px" );
	$("div#p2paddle").css( 'top', stateArray[3] + "px" );
	if (stateArray[4] === "0" && stateArray[5] === "0")
	{
		if (you === "1"){
			$("div#p1score").text("YOU");
		}
		else {
			$("div#p2score").text("YOU");
		}
	}
	else {
		$("div#p1score").text(stateArray[4]);
		$("div#p2score").text(stateArray[5]);
	}
}

function command(cmd)
{
	ws.send("c:" + cmd);
}

function victory()
{
	wins += 1;
	$("div#winner").text(wins);
	$("div#winner").show();
	$("a#paddles1").text(" Consecutive Wins");
	$("a#paddles1").prop("href", "javascript:startGame()");
	$("a#paddles2").text("Play Again");
	$("a#paddles2").prop("href", "javascript:startGame()");
	hideGame();
}	

function defeat()
{
	wins == 0;
	$("div#winner").text("LOSER");
	$("div#winner").show();
	$("a#paddles1").text("Dashing Paddles");
	$("a#paddles1").prop("href", "javascript:startGame()");
	$("a#paddles2").text("Play Again");
	$("a#paddles2").prop("href", "javascript:startGame()");
	hideGame();
}

function hideGame()
{
	$("div#gameArea").height(0);
	$("div#gameArea").width(0);
	$("div#gameArea").hide();
}


