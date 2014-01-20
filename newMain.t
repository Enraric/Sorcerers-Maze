%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TO DO LIST (in no particular order)  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Locking doors + keys                 %
% Superdoors + Superkeys               %
% Goblin AI + arrows                   %
% Goblin Mother                        %
% Win Conditions                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sorcerer's Maze                      %
% Programmed by Alexander McMorine III %
% and Ian Frosst                       %
% Work Started 11/11/2013              %
% Work Finished --/--/--               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

const * SPRTSZ := 48
var * score : int := 3600
var step : int := 0

var * smaller := Font.New ("Impact:14")
var * normal := Font.New ("Impact:32")
var * big := Font.New ("Impact:62:Bold")
var * small := Font.New ("Impact:28")
var * xThing, yThing, button: int

type scoredata :
record
    name : string (3)
    scor : int
end record

var playerscore : scoredata
var scores : array 1 .. 10 of scoredata

playerscore.scor := 0

for i : 1 .. 10
    scores(i).name := "CPU"
    scores(i).scor := 0
end for
    
% Stuff for Collision Detection %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

type * point:
record
    x : int
    y : int
end record

fcn * newP(x, y : int) : point
    var t : point
    t.x := x
    t.y := y
    result t
end newP

fcn * getDir(p1, p2 : point) : 1..4
    var n := p2.y - p2.x > p1.y - p1.x
    var m := p2.y + p2.x > p1.y + p1.x
    if n then
        if m then
            result 1
        else
            result 4
        end if
    else
        if m then
            result 2
        else
            result 3
        end if
    end if
end getDir

fcn * getText(s : string) : string
    var t := Window.Open("text:2;1,nobuttonbar")
    put s
    var text : string
    get text : *
    Window.Close(t)
    result text
end getText

% Loading Game Sprites %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fcn loadPics(name : string) : array 1 .. 4 of array 1 .. 2 of int
    var a : array 1..4 of array 1..2 of int
    for i : 1..2
        a(1)(i) := Pic.FileNew("Graphics/"+name+"_"+intstr(i)+".bmp")
    end for
        for i : 2..4
        for j : 1..2
            a(i)(j) := Pic.Rotate(a(1)(j), (5-i)*90, SPRTSZ div 2, SPRTSZ div 2)
        end for
    end for
        result a
end loadPics

fcn loadPics2(name : string) : array 1 .. 4 of array 1 .. 2 of int
    var a : array 1..4 of array 1..2 of int
    for i : 1..4
        for j : 1..2
            a(i)(j) := Pic.FileNew("Graphics/"+name+"_"+intstr(i)+"_"+intstr(j)+".bmp")
        end for
    end for
        result a
end loadPics2

%var * potPic := Pic.FileNew("Graphics/health_potion.bmp")
var * doorPic := Pic.FileNew("Graphics/door_closed.bmp")
var * wallPic := Pic.FileNew("Graphics/wall.bmp")
var * groundPic := Pic.FileNew("Graphics/ground.bmp")
var * wizIdle := Pic.FileNew("Graphics/mage_idle.bmp")
var * wizMove := loadPics2("mage")
var * gobMove := loadPics2("troll")
var * fire := loadPics("fire")

% Variable Declaration %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

var * keys : array char of boolean
var * text := Font.New ("Serif:14")
var * lose := false
var * title := Font.New ("Serif:48:Bold")
type * mode : enum(friend, enemy, neutral)

% The parent class for all things on-screen %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

class * object
    export draw, setXY, pos, solid, kind, damage
    var pos : point
    var pic : int
    var solid : boolean
    var kind : mode := mode.friend
    var damage : real := 0
    
    deferred proc draw
    
    proc setXY(np : point)
        pos.x := np.x
        pos.y := np.y
    end setXY
end object

% The parent class for all things on-screen that move %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

class * moveable
    inherit object
    export defUpdate, defCollide, move, var isAlive, var direct
    solid := true
    var step := 0    
    var speed := 0
    var direct : 1..4 := 1
    var health : real
    var isAlive := true
    
    proc move(dir : 1..4, s : int)
        case dir of
        label 1:
            pos.y += s
        label 2:
            pos.x += s
        label 3:
            pos.y -= s
        label 4:
            pos.x -= s
        end case
    end move
    
    deferred proc update
    deferred proc collide(m : ^object)
    
    proc defUpdate
        update        
        move(direct, speed)
        step += 1
    end defUpdate
    
    proc defCollide(m : ^object)
        move(direct, -speed)
        collide(m)
    end defCollide
end moveable

% The parent class for all things on-screen that DON'T move %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

class * tile
    inherit object
    export var filename, sDraw
    solid := false
    pic := groundPic
    var filename : string    
    
    body proc draw
        Pic.Draw(pic, pos.x-(SPRTSZ div 2), pos.y-(SPRTSZ div 2), picCopy)
    end draw
    
    proc sDraw(i : int)
        var c := blue
        if i = 1 then
            c := green
        end if
        Draw.FillBox(pos.x-(SPRTSZ div 4), pos.y-(SPRTSZ div 4), pos.x+(SPRTSZ div 4), pos.y+(SPRTSZ div 4), c)
    end sDraw
end tile

% The parent class for all types of items %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

class * item
    export use, draw, var w
    
    var w : ^moveable
    var pic : int
    
    deferred proc use
    
    proc draw(i : int)
        Pic.Draw(pic, 48 * i + 270, maxy-50, picMerge)
    end draw
end item

% Item Classes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

class * potion
    inherit item
    
    body proc use
        
    end use
end potion

% Fireball Class %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

class * fireball
    inherit moveable    
    speed := 8
    damage := 10.0
    kind := mode.friend
    solid := false
    
    body proc update
        if pos.x > maxx or pos.x < 0 or pos.y > maxy or pos.y < 0 then
            isAlive := false
        end if
        pic := fire(direct)(((step div 10) mod 2)+1)
    end update
    
    body proc collide
        if ^m.kind not= mode.neutral and ^m.solid then
            isAlive := false
        end if
    end collide
    
    body proc draw
        Pic.Draw(pic, pos.x-(SPRTSZ div 2), pos.y-(SPRTSZ div 2), picMerge)
    end draw
end fireball

% Wizard Class %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

class * wizard
    inherit moveable
    export useMana
    kind := mode.neutral
    pos := newP(maxx div 2, (maxy-60) div 2)
    pic := wizIdle
    var mSpeed := 4
    health := 100.0
    var mana := 100.0
    var items : flexible array 1..0 of ^item
    var wdsa : array 1..4 of char := init('w','d','s','a')
    
    proc heal
        if mana > 0 then
            mana -= 1
            health += 1
        end if
        if health > 100 then
            health := 100
        end if
    end heal
    
    fcn useMana(use : real) : boolean
        var u := mana - use > 0
        if u then
            mana -= use
        end if
        result u
    end useMana
    
    body proc collide
        if ^m.kind = mode.enemy or ^m.kind = mode.friend then
            health -= ^m.damage
        end if
    end collide
    
    body proc update
        if mana < 100 then
            mana += 0.1
        end if
        pic := wizIdle
        speed := 0
        for i : 1..4
            if keys(wdsa(i)) then
                direct := i
                speed := mSpeed
                pic := wizMove(i)(((step div 10) mod 2)+1)
                exit
            end if
        end for
            if keys (' ') then
            heal
        end if
        if keys ('c') and mana < 100 then
            mana := 100
        end if
        if keys ('e') and health < 100 then
            health := 100
        end if
        lose := health <= 0
    end update
    
    body proc draw
        %Pic.Draw(pic, pos.x-(SPRTSZ div 2), pos.y-(SPRTSZ div 2), picMerge)
        Draw.FillBox(pos.x-24, pos.y-24, pos.x+23, pos.y+23, purple)
        Draw.FillBox (0, maxy-60, maxx, maxy, black)
        Font.Draw ("Health", 210, maxy-25, text, white)
        Font.Draw ("Mana", 210, maxy-50, text, white)
        for i : 0 .. 3
            Draw.FillBox (0, maxy-40, round (health * 2), maxy - i * 10, 47 + i)
        end for
            for i : 0 .. 3
            Draw.FillBox (0, maxy-60, round (mana * 2), maxy - 41 - i * 5, 32 + i)
        end for
            for i : 1..upper(items)
            items(i) -> draw(i)
        end for
    end draw
end wizard
var * w : ^wizard

% Wall Class %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

class * wall
    inherit tile
    solid := true
    pic := wallPic
end wall

% Goblin Class %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

class * goblin
    inherit moveable
    
    kind := mode.enemy
    health := 1.0
    speed := 2
    damage := 0.5
    var randmove := Rand.Int (0, 4)
    var t := w
    var mana : real := 10
    
    fcn useMana(use : real) : boolean
        var u := mana - use > 0
        if u then
            mana -= use
        end if
        result u
    end useMana
    
    body proc update
        mana += 1
        if step = Rand.Int (24, 72) then
            direct := Rand.Int(1, 4)
            step := 0
        end if
        if step = 73 then
            direct := Rand.Int(1, 4)
            step := 0
        end if
        %direct := getDir(pos, ^t.pos)
        pic := gobMove(direct)(((step div 10) mod 2)+1)
        isAlive := not health <= 0
        if isAlive = false then
            score += 10
        end if
    end update
    
    body proc collide
        if ^m.kind = mode.friend then
            health -= ^m.damage
        end if
    end collide
    
    body proc draw
        %Pic.Draw(pic, pos.x-(SPRTSZ div 2), pos.y-(SPRTSZ div 2), picCopy)
        drawfillbox (pos.x-(SPRTSZ div 2), pos.y-(SPRTSZ div 2), pos.x+(SPRTSZ div 2), pos.y+(SPRTSZ div 2), green)
    end draw
end goblin

% Room Class %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

class * room
    export getNear, getTile, setTile, draw, map
    
    var map : array 0..19, 0..12 of ^tile
    
    fcn getNear(x, y : int, dir : 1..4) : array 1..3 of ^tile
        var a : array 1..3 of ^tile
        if dir = 1 or dir = 3 then
            for i : 1..3
                a(i) := map((x-1)+(i mod 3),(y+2)-dir)
            end for
            else
            for i : 1..3
                a(i) := map((x+3)-dir,(y-1)+(i mod 3))
            end for
        end if
        result a
    end getNear
    
    fcn getTile(x, y : int) : ^tile
        result map(x, y)
    end getTile
    
    proc setTile(x, y : int, newTile : ^tile)
        map(x, y) := newTile
        map(x, y) -> setXY(newP((SPRTSZ div 2)+x*SPRTSZ, (SPRTSZ div 2)+y*SPRTSZ))
    end setTile
    
    proc draw
        for x : 0..19
            for y : 0..12
                map(x, y) -> draw
            end for
        end for
    end draw
end room

% Door Classes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

class * door
        inherit tile
    pic := doorPic
    solid := true
end door
    
class * lockDoor
        inherit door
end lockDoor
    
class * superDoor
        inherit lockDoor
end superDoor
    
% Game Controller %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

module game
    export all
    
    var timer := 0
    var shot : array 1..4 of boolean := init(false, false, false, false)
    var arrowKeys : array 1..4 of char := init(KEY_UP_ARROW, KEY_RIGHT_ARROW, KEY_DOWN_ARROW, KEY_LEFT_ARROW)
    var m : flexible array 1..0 of ^moveable
    var level : ^room
    var lastLevel, currentLevel := ""
    
    fcn checkColl(m1, m2 : ^moveable) : boolean
        var c := abs(^m1.pos.x - ^m2.pos.x) < SPRTSZ and abs(^m1.pos.y - ^m2.pos.y) < SPRTSZ
        if c then
            ^m1.defCollide(m2)
            ^m2.defCollide(m1)
        end if
        result c
    end checkColl
    
    fcn checkColl_tile(m : ^moveable, s : ^tile) : boolean
        var c := abs(^m.pos.x - ^s.pos.x) < SPRTSZ and abs(^m.pos.y - ^s.pos.y) < SPRTSZ and ^s.solid
        if c then
            ^m.defCollide(s)
        end if
        result c
    end checkColl_tile
    
    proc gameover
        cls
        drawfillbox (0, 0, maxx, maxy, black)
        Font.Draw ("Game Over", 300, 350, title, white)
        View.Update
    end gameover
    
    proc spawnGoblin(pos : point)
        new m, upper(m)+1
        new goblin, m(upper(m))
        m(upper(m)) -> setXY(pos)
    end spawnGoblin
    
    proc spawnFireball(i : int)
        if ^w.useMana(10) then
            new m, upper(m)+1
            new fireball, m(upper(m))
            m(upper(m)) -> direct := i
            m(upper(m)) -> setXY(^w.pos)
            m(upper(m)) -> move(i, 49)
            var tmp := checkColl_tile (m(upper(m)), level -> getTile (m(upper(m)) -> pos.x div 48, m(upper(m)) -> pos.y div 48))
        end if
    end spawnFireball
    
    /*
    proc spawnFireGob(i : int)
        if ^g.useMana(10) then
            new m, upper(m)+1
            new fireball, m(upper(m))
            m(upper(m)) -> direct := i
            m(upper(m)) -> setXY(^w.pos)
            m(upper(m)) -> move(i, 49)
            var tmp := checkColl_tile (m(upper(m)), level -> getTile (m(upper(m)) -> pos.x div 48, m(upper(m)) -> pos.y div 48))
        end if
    end spawnFireGob
    */
    
    proc draw
        ^level.draw
        for i : 1..upper(m)
            if m(i) -> isAlive then
                m(i) -> draw
            end if
        end for
            w -> draw
        Font.Draw (intstr(score), maxx-(length(intstr(score))*10), maxy-25, text, white)
    end draw
    
    proc loadLevel(filename : string)
        for i : 1..upper(m)
            free m(i)
        end for
            new m, 0
        currentLevel := filename
        
        var f : int
        var d : flexible array 1..0 of ^door
            open : f, "Levels/"+filename+".txt", get
        for decreasing y : 12..0
            var line : string
            get : f, line : *
            for x : 0..19
                var t : ^tile
                case line(x+1) of
                label 'w':
                    new wall, t
                label 'd':
                    new door, t
                    new d, upper(d) + 1
                    d(upper(d)) := t
                label 'l':
                    new lockDoor, t
                    new d, upper(d) + 1
                    d(upper(d)) := t
                label 's':
                    new superDoor, t
                    new d, upper(d) + 1
                    d(upper(d)) := t
                label 'g':
                    new tile, t
                    spawnGoblin(newP((SPRTSZ div 2)+x*SPRTSZ, (SPRTSZ div 2)+y*SPRTSZ))
                label:
                    new tile, t
                end case
                level -> setTile(x, y, t)
            end for
        end for
            for i : 1..upper(d)
            var fname : string
            get : f, fname
            d(i) -> filename := fname
        end for
            close : f
        if lastLevel = "" then
            w -> setXY(newP(9*48 + 24, 6*48 + 24))
        else
            if lastLevel(1) < currentLevel(1) then
                w -> setXY(newP(72, 312))
            elsif lastLevel(1) > currentLevel(1) then
                w -> setXY(newP(888, 312))
            else
                if lastLevel(2) > currentLevel(2) then
                    w -> setXY(newP(456, 72))
                elsif lastLevel(2) < currentLevel(2) then
                    w -> setXY(newP(456, 552))
                end if
            end if
        end if 
    end loadLevel
    
    proc initialize(levelName : string)
        new w
        new level
        loadLevel(levelName)
    end initialize
    
    proc sweep
        var a : flexible array 1..0 of ^moveable
        for i : 1..upper(m)
            if m(i) -> isAlive then
                new a, upper(a) + 1
                a(upper(a)) := m(i)
            else
                free m(i)
            end if
        end for
        for i : 1..upper(a)
            m(i) := a(i)
        end for
        new m, upper(a)
    end sweep
    
    proc update
        if keys('l') then
            loadLevel(getText(""))
        end if
        for i : 1..4
            if keys(arrowKeys(i)) then
                if not shot(i) then
                    spawnFireball(i)
                    shot(i) := true
                end if
            elsif shot(i) then
                shot(i) := false
            end if
        end for
            w -> defUpdate
        var c := ^level.getNear(^w.pos.x div SPRTSZ, ^w.pos.y div SPRTSZ, ^w.direct)
        for i : 1..3
            %c(i) -> sDraw(i)
            if checkColl_tile(w, c(i)) then
                if objectclass(c(i)) >= door then
                    lastLevel := currentLevel
                    loadLevel(c(i) -> filename)
                end if
            end if
        end for
            for i : 1..upper(m)
            if m(i) -> isAlive then
                m(i) -> defUpdate
                var tmp := checkColl(m(i), w)
                for j : i+1..upper(m)
                    if m(j) -> isAlive then
                        var temp := checkColl(m(i), m(j))
                    end if
                end for
                    var a := ^level.getNear(^(m(i)).pos.x div SPRTSZ, ^(m(i)).pos.y div SPRTSZ, ^(m(i)).direct)
                for j : 1..3
                    if checkColl_tile(m(i), a(j)) then
                        
                    end if
                end for
            end if
        end for
            if Time.Elapsed - timer > 1000 then
            sweep
            timer := Time.Elapsed
        end if
    end update
end game

% Pause Screen %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

proc pausescreen
    var asdasf := Font.New ("Impact:62:Bold")
    drawfillbox (0, 0, 1000, 1000, black)
    Font.Draw ("PAUSED", 350, 310, asdasf, white)
    View.Update
    delay(100)
    loop
        Input.KeyDown(keys)
        if keys ('p') then
            delay(50)
            exit
        end if
    end loop
end pausescreen

% Game Procedure%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

proc gamerun
    %Music.PlayFileLoop("ScienceBlaster.mp3")
    game.initialize("C3") 
    
    loop
        Input.KeyDown (keys)
        game.update
        if keys ('p') then
            pausescreen
            delay (50)
        end if
        if step = 5 then
            score -= 1
            step := 0
        end if
        if score = 0 then
            lose := true
        end if
        game.draw
        View.Update
        cls
        Time.DelaySinceLast (16)
        step += 1
        exit when lose
    end loop
    playerscore.scor := score
    game.gameover
end gamerun

% Function for clicking buttons %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function clickCheck (x, y, x1, y1, x2, y2 : int) : boolean
    result (x > x1) and (x < x2) and (y > y1) and (y < y2)
end clickCheck

% Procedure for entering high score name %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

proc letterEnter
    
    var s := 1
    s := Window.Open ("graphics:450;400")
    drawfillbox(0, 0, 1000, 1000, black)
    
    var letter : int := 65
    var finish : boolean := false
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
        buttonwait ("down", xThing, yThing, button, button)
        if clickCheck (xThing, yThing, 100, 200, 150, 250) and letter > 65 and button = 1 then
            letter -= 1
            drawfillbox (180, 150, 270, 250, black)
            Font.Draw (chr (letter), 200, 180, big, white)
        end if
        if clickCheck (xThing, yThing, 300, 200, 350, 250) and letter < 90 and button = 1 then
            letter += 1
            drawfillbox (180, 150, 270, 250, black)
            Font.Draw (chr (letter), 200, 180, big, white)
        end if
        if clickCheck (xThing, yThing, 200, 100, 250, 150) and button = 1 then
            playerscore.name += chr (letter)
            Font.Draw (playerscore.name, 150, 260, big, white)
            lettercount += 1
        end if
        exit when lettercount = 3
    end loop
    
    Window.Close (s)
end letterEnter

% Intructions Screen %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
        mousewhere (xThing, yThing, button)
        if xThing > 850 and yThing > 5 and xThing < 1000 and yThing < 50 then
            drawbox (845, 5, 955, 45, white)
            if button = 1 then
                exit
            end if
        end if
        View.Update
    end loop
end controls

% High Score Sorting %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

proc scoresort
    var temp : int
    
    for i : 1 .. 10
        for decreasing j : 10 .. 2
            if scores(j).scor > scores(j - 1).scor then
                var tempscore := scores(j)
                scores(j) := scores(j - 1)
                scores(j - 1) := tempscore
            end if
        end for
    end for
        
    var f1 : int    
    open : f1, "scores", write
    for i : 1 .. 10
        write : f1, scores (i)
    end for
        close : f1
end scoresort

% The High Score Screen %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

proc scorescreen
    var f1 : int
    open : f1, "scores", read
    for i : 1 .. 10
        read : f1, scores (i)
    end for
        close: f1
    
    if playerscore.scor > scores(10).scor then
        letterEnter
        scores(10) := playerscore
        scoresort
    end if
    
    cls
    Pic.ScreenLoad ("back.jpg", -10, -10, picMerge)
    Font.Draw ("Name", 10, 600, big, white)
    Font.Draw ("Score", 750, 600, big, white)
    
    for i : 1 .. 10
        Font.Draw (scores (11-i).name, 10, 45 * i + 105, normal, white)
        Font.Draw (intstr (scores (11-i).scor), 750, 45 * i + 105, normal, white)
    end for
        
    Font.Draw ("Main Menu" , 405, 13, small, white)
    View.Update
    
    loop
        mousewhere (xThing, yThing, button)
        if xThing > 400 and yThing > 5 and xThing < 575 and yThing < 50 then
            drawbox (400, 5, 575, 50, white)
            if button = 1 then
                exit
            end if
        end if
        View.Update
    end loop
    
    playerscore.scor := 0
    playerscore.name := ""
end scorescreen

% Main Program %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

View.Set("graphics:"+intstr(20*SPRTSZ)+";"+intstr(13*SPRTSZ+60)+",offscreenonly,nobuttonbar")

loop    
    Pic.ScreenLoad ("back.jpg", -10, -10, picMerge)
    Font.Draw ("Sorcerer's Maze", 210, 600, big, white)
    Font.Draw ("PLAY", 457, 300, normal, white)
    Font.Draw ("INSTRUCTIONS", 370, 250, normal, white)
    Font.Draw ("HIGH SCORES", 384, 200, normal, white)
    Font.Draw ("QUIT", 455, 150, normal, white)
    
    mousewhere (xThing, yThing, button)
    if xThing > 452 and yThing > 295 and xThing < 540 and yThing < 340 then
        drawbox (452, 295, 540, 340, white)
        if button = 1 then
            gamerun
            scorescreen
        end if
    elsif xThing > 365 and yThing > 245 and xThing < 620 and yThing < 290 then
        drawbox (365, 245, 620, 290, white)
        if button = 1 then
            controls
        end if
    elsif xThing > 379 and yThing > 195 and xThing < 612 and yThing < 240 then
        drawbox (379, 195, 612, 240, white)
        if button = 1 then
            scorescreen
        end if
    elsif xThing > 450 and yThing > 140 and xThing < 537 and yThing < 188 then
        drawbox (450, 143, 540, 188, white)
        if button = 1 then
            exit
        end if
    end if
    View.Update
end loop

Window.Hide (-1)