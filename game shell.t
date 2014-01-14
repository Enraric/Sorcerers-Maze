%Game Shell
var maller := Font.New ("Serif:14")
var normal := Font.New ("Serif:32")
var big := Font.New ("Serif:62:Bold")
var small := Font.New ("Serif:28")
var x, y, button : int

proc game
    cls
    Font.Draw ("This is the game", 118, 500, big, white)
end game

setscreen ("graphics:800;600,offscreenonly,nobuttonbar")
drawfillbox (0, 0, 1000, 1000, black)
Font.Draw ("Sorcerer's Maze", 118, 500, big, white)
Font.Draw ("PLAY", 345, 300, normal, white)
Font.Draw ("CONTROLS", 280, 250, normal, white)
Font.Draw ("HIGH SCORES", 260, 200, normal, white)
Font.Draw ("QUIT", 345, 150, normal, white)

buttonwait ("down", x, y, button)
if x > 340 and y > 295 and x < 1000 and y < 1000 then
    game
elsif x > 295 and x < 463 and y > 5 and y < 45 then
    %exitloopy := true
elsif x > 720 and x < 795 and y > 5 and y < 45 then
    %exitloopy := true
    %exitvar := true
end if