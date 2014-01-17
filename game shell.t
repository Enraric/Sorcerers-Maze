%Game Shell
var smaller := Font.New ("Impact:14")
var normal := Font.New ("Impact:32")
var big := Font.New ("Impact:62:Bold")
var small := Font.New ("Impact:28")
var x, y, button: int
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
    score(i).scor := 0
end for
    
proc game
    cls
    Font.Draw ("This is the game", 180, 600, big, black)
    View.Update
    delay(1000)
end game

proc controls
    cls
    Pic.ScreenLoad ("back.jpg", -10, -10, picMerge)
    Font.Draw ("Intructions", 300, 600, big, white)
    Font.Draw ("Use WASD to move", 10, 450, normal, white)
    Font.Draw ("Tap the arrow keys to throw fire (requires mana)", 10, 400, normal, white)
    Font.Draw ("Hold the space bar to heal (requires mana)", 10, 350, normal, white)
    Font.Draw ("Tap P to pause and unpause", 10, 300, normal, white)
    Font.Draw ("Find the four magic keys to escape", 10, 250, normal, white)
    Font.Draw ("Some doors require regular keys", 10, 200, normal, white)
    Font.Draw ("Return", 850, 10, small, white)
    View.Update
    loop
        mousewhere (x, y, button)
        if x > 850 and y > 5 and x < 1000 and y < 50 then
            drawbox (845, 5, 955, 45, white)
            if button = 1 then
                exitloop := true
            end if
        end if
        exit when exitloop
        View.Update
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
    
    Pic.ScreenLoad ("back.jpg", -10, -10, picMerge)
    Font.Draw ("Name", 10, 600, big, white)
    Font.Draw ("Score", 750, 600, big, white)
    
    for i : 1 .. 10
        Font.Draw (score (11-i).name, 10, 45 * i + 105, normal, white)
        Font.Draw (intstr (score (11-i).scor), 750, 45 * i + 105, normal, white)
    end for
        
    Font.Draw ("Main Menu" , 405, 13, small, white)
    
    View.Update
    
    
    loop
        mousewhere (x, y, button)
        if x > 400 and y > 5 and x < 575 and y < 50 then
            drawbox (400, 5, 575, 50, white)
            if button = 1 then
                exitloop := true
            end if
        end if
        exit when exitloop
        View.Update
    end loop
    
    
    exitloop := false
    playerscore.scor := 0
    playerscore.name := ""
end scorescreen

loop    
    setscreen ("graphics:960;684,offscreenonly,nobuttonbar")
    Pic.ScreenLoad ("back.jpg", -10, -10, picMerge)
    Font.Draw ("Sorcerer's Maze", 210, 600, big, white)
    Font.Draw ("PLAY", 457, 300, normal, white)
    Font.Draw ("INSTRUCTIONS", 370, 250, normal, white)
    Font.Draw ("HIGH SCORES", 384, 200, normal, white)
    Font.Draw ("QUIT", 455, 150, normal, white)
    
    mousewhere (x, y, button)
    if x > 452 and y > 295 and x < 540 and y < 340 then
        drawbox (452, 295, 540, 340, white)
        if button = 1 then
            game
            scorescreen
        end if
    elsif x > 365 and y > 245 and x < 620 and y < 290 then
        drawbox (365, 245, 620, 290, white)
        if button = 1 then
            controls
        end if
    elsif x > 379 and y > 195 and x < 612 and y < 240 then
        drawbox (379, 195, 612, 240, white)
        if button = 1 then
            scorescreen
        end if
    elsif x > 450 and y > 140 and x < 537 and y < 188 then
        drawbox (450, 140, 537, 188, white)
        if button = 1 then
            exitloop := true
        end if
    end if
    View.Update
    
    exit when exitloop
end loop

Window.Hide (-1)