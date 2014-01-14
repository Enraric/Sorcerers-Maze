%Game Shell
var maller := Font.New ("Serif:14")
var normal := Font.New ("Serif:32")
var big := Font.New ("Serif:62:Bold")
var small := Font.New ("Serif:28")
var x, y, button, click : int
var exitloop : boolean := false

proc game
    cls
    Font.Draw ("This is the game", 118, 500, big, black)
    View.Update
    delay(1000)
end game

proc controls
    cls
    Font.Draw ("These are the controls", 10, 500, big, black)
    View.Update
    delay(1000)
end controls

proc scorescreen
    cls
    Font.Draw ("These are the scores", 55, 500, big, black)
    View.Update
    delay(1000)
end scorescreen

loop    
    setscreen ("graphics:800;600,offscreenonly,nobuttonbar")
    drawfillbox (0, 0, 1000, 1000, black)
    Font.Draw ("Sorcerer's Maze", 118, 500, big, white)
    Font.Draw ("PLAY", 345, 300, normal, white)
    Font.Draw ("CONTROLS", 280, 250, normal, white)
    Font.Draw ("HIGH SCORES", 260, 200, normal, white)
    Font.Draw ("QUIT", 345, 150, normal, white)
    View.Update
    
    buttonwait ("down", x, y, button, click)
    if x > 340 and y > 295 and x < 500 and y < 340 then
        game
        scorescreen
    elsif x > 275 and y > 245 and x < 500 and y < 265 then
        controls
    elsif x > 255 and y > 195 and x < 500 and y < 240 then
        scorescreen
    elsif x > 340 and y > 145 and x < 450 and y < 180 then
        exitloop := true
    end if
    
    exit when exitloop
end loop

Window.Hide (-1)