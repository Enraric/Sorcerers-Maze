%Game Shell
var smaller := Font.New ("Serif:14")
var normal := Font.New ("Serif:32")
var big := Font.New ("Serif:62:Bold")
var small := Font.New ("Serif:28")
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
    Font.Draw ("This is the game", 180, 600, big, black)
    View.Update
    delay(1000)
end game

proc controls
    cls
    drawfillbox(0, 0, 1000, 1000, black)
    Font.Draw ("Intructions", 300, 620, big, white)
    Font.Draw ("Use WASD to move", 10, 450, normal, white)
    Font.Draw ("Use the arrow keys to shoot (requires mana)", 10, 400, normal, white)
    Font.Draw ("Use space to heal (requires mana)", 10, 350, normal, white)
    Font.Draw ("Find the four magic keys to escape", 10, 300, normal, white)
    Font.Draw ("Some doors require regular keys", 10, 250, normal, white)
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
    
    drawfillbox (0, 0, 1000, 1000, black)
    Font.Draw ("Name", 10, 620, big, white)
    Font.Draw ("Score", 750, 620, big, white)
       
    for i : 1 .. 10
        Font.Draw (score (11-i).name, 10, 45 * i + 125, normal, white)
        Font.Draw (intstr (score (11-i).scor), 750, 45 * i + 125, normal, white)
    end for
    
    Font.Draw ("Main Menu" , 405, 13, small, white)
    
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
    drawfillbox (0, 0, 1000, 1000, black)
    Font.Draw ("Sorcerer's Maze", 180, 600, big, white)
    Font.Draw ("PLAY", 435, 300, normal, white)
    Font.Draw ("INSTRUCTIONS", 335, 250, normal, white)
    Font.Draw ("HIGH SCORES", 350, 200, normal, white)
    Font.Draw ("QUIT", 435, 150, normal, white)
    View.Update
    
    buttonwait ("down", x, y, button, click)
    if x > 435 and y > 300 and x < 500 and y < 340 then
        game
        scorescreen
    elsif x > 335 and y > 250 and x < 650 and y < 395 then
        controls
    elsif x > 350 and y > 200 and x < 650 and y < 245 then
        scorescreen
    elsif x > 435 and y > 150 and x < 650 and y < 195 then
        exitloop := true
    end if
    
    exit when exitloop
end loop

Window.Hide (-1)