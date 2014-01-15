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
    drawfillbox(0, 0, 1000, 1000, black)
    Font.Draw ("Intructions", 230, 530, big, white)
    Font.Draw ("Use WASD to move", 10, 450, normal, white)
    Font.Draw ("Use the arrow keys to shoot (requires mana)", 10, 400, normal, white)
    Font.Draw ("Use space to regen health (requires mana)", 10, 350, normal, white)
    Font.Draw ("Find the four magic keys to escape", 10, 300, normal, white)
    Font.Draw ("Some doors require regular keys", 10, 250, normal, white)
    Font.Draw ("Goblins will shoot at you", 10, 200, normal, white)
    Font.Draw ("You can shoot back", 10, 150, normal, white)
    Font.Draw ("Return", 690, 10, small, white)
    View.Update
    loop
        buttonwait ("down", x, y, button, click)
        if x > 685 and y > 5 and x < 800 and y < 50 then
            exitloop := true
        end if
        exit when exitloop
    end loop
    exitloop := false
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
    Font.Draw ("INSTRUCTIONS", 245, 250, normal, white)
    Font.Draw ("HIGH SCORES", 260, 200, normal, white)
    Font.Draw ("QUIT", 345, 150, normal, white)
    View.Update
    
    buttonwait ("down", x, y, button, click)
    if x > 340 and y > 295 and x < 500 and y < 340 then
        game
        scorescreen
    elsif x > 240 and y > 245 and x < 500 and y < 265 then
        controls
    elsif x > 255 and y > 195 and x < 500 and y < 240 then
        scorescreen
    elsif x > 340 and y > 145 and x < 450 and y < 180 then
        exitloop := true
    end if
    
    exit when exitloop
end loop

Window.Hide (-1)