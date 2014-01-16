%Game Shell
var smaller := Font.New ("Impact:14")
var normal := Font.New ("Impact:32")
var big := Font.New ("Impact:62:Bold")
var small := Font.New ("Impact:28")
var x, y, button, click : int
var exitloop : boolean := false

type scoredata :
record
    name : string (3)
    scor : int
end record

var playerscore : scoredata
var score : array 1 .. 10 of scoredata

for i : 1 .. 10
    score(i).name := "CPU"
    score(i).scor := 2500
end for
    
proc game
    cls
    Font.Draw ("This is the game", 180, 600, big, Rand.Int (0, 255))
    View.Update
    delay(1000)
end game

proc controls
    cls
    drawfillbox(0, 0, 1000, 1000, black)
    Font.Draw ("Intructions", 300, 600, big, Rand.Int (0, 255))
    Font.Draw ("Use WASD to move", 10, 450, normal, Rand.Int (0, 255))
    Font.Draw ("Use the arrow keys to shoot (requires mana)", 10, 400, normal, Rand.Int (0, 255))
    Font.Draw ("Use space to heal (requires mana)", 10, 350, normal, Rand.Int (0, 255))
    Font.Draw ("Find the four magic keys to escape", 10, 300, normal, Rand.Int (0, 255))
    Font.Draw ("Some doors require regular keys", 10, 250, normal, Rand.Int (0, 255))
    Font.Draw ("Return", 850, 10, small, white)
    View.Update
    loop
        buttonwait ("down", x, y, button, click)
        if x > 850 and y > 5 and x < 1000 and y < 50 then
            exitloop := true
        end if
        exit when exitloop
    end loop
    exitloop := false
end controls

proc scorescreen
    var f1 : int
    open : f1, "scores", read
    for i : 1 .. 10
        read : f1, score (i)
    end for
        close: f1
    
    /*
    if playerscore.scor > score(10).scor then
    letterEnter
    score(10) := playerscore
    scoresort
    end if
    */
    
    cls
    
    drawfillbox (0, 0, 1000, 1000, Rand.Int (0, 255))
    Font.Draw ("Name", 10, 600, big, Rand.Int (0, 255))
    Font.Draw ("Score", 750, 600, big, Rand.Int (0, 255))
    
    for i : 1 .. 10
        Font.Draw (score (11-i).name, 10, 45 * i + 105, normal, Rand.Int (0, 255))
        Font.Draw (intstr (score (11-i).scor), 750, 45 * i + 105, normal, Rand.Int (0, 255))
    end for
        
    Font.Draw ("Main Menu" , 405, 13, small, Rand.Int (0, 255))
    
    View.Update
    
    
    loop
        mousewhere (x, y, button)
        if x > 400 and y > 5 and x < 583 and y < 45 and button = 1 then
            exitloop := true
        end if
        exit when exitloop
    end loop
    
    
    exitloop := false
    playerscore.scor := 0
    playerscore.name := ""
end scorescreen

loop    
    setscreen ("graphics:960;684,offscreenonly,nobuttonbar")
    drawfillbox (0, 0, 1000, 1000, Rand.Int (0, 255))
    Font.Draw ("Sorcerer's Maze", 200, 600, big, Rand.Int (0, 255))
    Font.Draw ("PLAY", 457, 300, normal, Rand.Int (0, 255))
    Font.Draw ("INSTRUCTIONS", 370, 250, normal, Rand.Int (0, 255))
    Font.Draw ("HIGH SCORES", 384, 200, normal, Rand.Int (0, 255))
    Font.Draw ("QUIT", 455, 150, normal, Rand.Int (0, 255))
    
    mousewhere (x, y, button)
    if x > 452 and y > 295 and x < 540 and y < 340 then
        drawbox (452, 295, 540, 340, Rand.Int (0, 255))
        if button = 1 then
            game
            scorescreen
        end if
    elsif x > 365 and y > 245 and x < 620 and y < 290 then
        drawbox (365, 245, 620, 290, Rand.Int (0, 255))
        if button = 1 then
            controls
        end if
    elsif x > 379 and y > 195 and x < 612 and y < 240 then
        drawbox (379, 195, 612, 240, Rand.Int (0, 255))
        if button = 1 then
            scorescreen
        end if
    elsif x > 450 and y > 140 and x < 537 and y < 188 then
        drawbox (450, 140, 537, 188, Rand.Int (0, 255))
        if button = 1 then
            exitloop := true
        end if
    end if
        View.Update

    exit when exitloop
end loop

Window.Hide (-1)