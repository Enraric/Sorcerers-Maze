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

playerscore.scor := 0

for i : 1 .. 10
    score(i).name := "CPU"
    score(i).scor := 0
end for
    
function clickCheck (x, y, x1, y1, x2, y2 : int) : boolean
    result (x > x1) and (x < x2) and (y > y1) and (y < y2)
end clickCheck

proc game
    cls
    Font.Draw ("This is the game", 180, 600, big, black)
    View.Update
    delay(1000)
end game

proc letterEnter
    
    var s := 1
    s := Window.Open ("graphics:450;400")
    drawfillbox(0, 0, 1000, 1000, black)
    
    var letter : int := 65
    var finish : boolean := false
    var x, y, button : int := 0
    var lettercount : int := 0
    
    playerscore.name := ""
    
    Font.Draw ("High Score! Enter your name.", 10, 350, small, white)
    
    % Left Arrow
    drawbox (100, 200, 150, 250, white)
    drawline (140, 210, 120, 210, white)
    drawline (120, 210, 110, 225, white)
    drawline (110, 225, 120, 240, white)
    drawline (120, 240, 140, 240, white)
    drawline (140, 240, 140, 210, white)
    
    % Right Arrow
    drawbox (300, 200, 350, 250, white)
    drawline (310, 210, 330, 210, white)
    drawline (330, 210, 340, 225, white)
    drawline (340, 225, 330, 240, white)
    drawline (330, 240, 310, 240, white)
    drawline (310, 240, 310, 210, white)
    
    % Enter Box
    drawbox (200, 100, 250, 150, white)
    drawline (210, 140, 210, 110, white)
    drawline (210, 110, 230, 110, white)
    drawline (230, 110, 240, 115, white)
    drawline (240, 115, 230, 120, white)
    drawline (230, 120, 220, 120, white)
    drawline (220, 120, 220, 140, white)
    drawline (220, 140, 210, 140, white)
    
    Font.Draw (chr (letter), 200, 180, big, white)
    
    loop
        buttonwait ("down", x, y, button, button)
        if clickCheck (x, y, 100, 200, 150, 250) and letter > 65 and button = 1 then
            letter -= 1
            drawfillbox (180, 150, 270, 250, black)
            Font.Draw (chr (letter), 200, 180, big, white)
        end if
        if clickCheck (x, y, 300, 200, 350, 250) and letter < 90 and button = 1 then
            letter += 1
            drawfillbox (180, 150, 270, 250, black)
            Font.Draw (chr (letter), 200, 180, big, white)
        end if
        if clickCheck (x, y, 200, 100, 250, 150) and button = 1 then
            playerscore.name += chr (letter)
            Font.Draw (playerscore.name, 150, 260, big, white)
            lettercount += 1
        end if
        exit when lettercount = 3
    end loop
    
    Window.Close (s)
    
end letterEnter

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

proc scoresort
    
    var temp : int
    
    for i : 1 .. 10
        for decreasing j : 10 .. 2
            if score(j).scor > score(j - 1).scor then
                var tempscore := score(j)
                score(j) := score(j - 1)
                score(j - 1) := tempscore
            end if
        end for
    end for
        
    var f1 : int    
    open : f1, "scores", write
    for i : 1 .. 10
        write : f1, score (i)
    end for
        close : f1
    
end scoresort

proc scorescreen
    var f1 : int
    open : f1, "scores", read
    for i : 1 .. 10
        read : f1, score (i)
    end for
        close: f1
    
    if playerscore.scor > score(10).scor then
        letterEnter
        score(10) := playerscore
        scoresort
    end if
    
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