%Game Shell
var * smaller := Font.New ("Serif:14")
var * normal := Font.New ("Serif:32")
var * big := Font.New ("Serif:62:Bold")
var * small := Font.New ("Serif:28")

setscreen ("graphics:800;600,offscreenonly,nobuttonbar")
drawfillbox (0, 0, 1000, 1000, black)
Font.Draw ("Sorcerer's Maze", 118, 500, big, white)
Font.Draw ("PLAY", 345, 300, normal, white)
Font.Draw ("CONTROLS", 280, 250, normal, white)
Font.Draw ("HIGH SCORES", 260, 200, normal, white)
Font.Draw ("QUIT", 345, 150, normal, white)