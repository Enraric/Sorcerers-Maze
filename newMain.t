%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sorcerer's Maze                      %
% Programmed by Alexander McMorine III %
% and Ian Frosst                       %
% Work Started 11/11/2013              %
% Work Finished --/--/--               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Variable Declaration %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

const * SPRTSZ := 48
var * score : int := 9999
var step : int := 0
var * wonTheGame, lose := false
var * keys : array char of boolean
var * ccc : array 1..4 of boolean := init(false, false, false, false)
var * text := Font.New ("Serif:14")
var * title := Font.New ("Serif:48:Bold")
var * smaller := Font.New ("Impact:14")
var * normal := Font.New ("Impact:32")
var * big := Font.New ("Impact:62:Bold")
var * small := Font.New ("Impact:28")
var * xxx, yyy, button: int
type * mode : enum(friend, enemy, neutral, key) % for checking types of objects because objectclass sucks

type scoredata :
record
    name : string (3)
    scor : int
end record

var playerscore : scoredata
var scores : array 1 .. 10 of scoredata

playerscore.scor := 0

for i : 1 .. 10
    scores(i).name := ""
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

% Gets the approximate direction from one point to another
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

var * doorPic := Pic.FileNew ("Graphics/door_closed.bmp")
var * sDoorPic := Pic.FileNew("Graphics/superdoor.bmp")
var * wallPic := Pic.FileNew ("Graphics/wall.bmp")
var * groundPic := Pic.FileNew ("Graphics/ground.bmp")
var * sKeyPic := Pic.FileNew ("Graphics/superkey.bmp")
var * wizIdle := Pic.FileNew ("Graphics/mage_idle.bmp")
var * wizMove := loadPics2 ("mage")
var * gobMove := loadPics2 ("troll")
var * bossIdle := Pic.FileNew ("Graphics/boss_idle.bmp")
var * bossMove := loadPics2 ("boss")
var * fire := loadPics ("fire")

% The parent class for all things on-screen %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

class * object
    export draw, setXY, pos, solid, kind, damage
    var pos : point
    var pic : int
    var solid : boolean
    var kind : mode := mode.friend
    var damage : real := 0
    
    deferred proc draw
    body proc draw
        Pic.Draw(pic, pos.x-(SPRTSZ div 2), pos.y-(SPRTSZ div 2), picMerge)
    end draw
    
    proc setXY(np : point)
        pos.x := np.x
        pos.y := np.y
    end setXY
end object

% The parent class for all things on-screen that move %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

class * moveable
    inherit object
    export defUpdate, defCollide, move, canHit, var isAlive, var direct
    solid := true
    var canHit : boolean
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
    body proc update
    end update
    
    deferred proc collide(m : ^object)
    body proc collide
    end collide
    
    % Called every frame
    proc defUpdate
        update        
        move(direct, speed)
        step += 1
    end defUpdate
    
    % Called when colliding with something else
    proc defCollide(m : ^object)
        if ^m.solid then
            move(direct, -speed)
        end if
        collide(m)
    end defCollide
end moveable

% The parent class for all things on-screen that DON'T move %%%%%% Like keys? Hmmm... %%%%%%%%%%%%%%

class * tile
    inherit object
    export var filename, canEnter, sDraw
    solid := false
    pic := groundPic
    var filename : string
    var canEnter : boolean   
    
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
        Pic.Draw(pic, 48 * i + 270, maxy-54, picMerge)
    end draw
end item

% Item Classes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

class * superKey
    inherit moveable
    pic := sKeyPic
    solid := false
    kind := mode.key
    body proc collide
        if ^m.kind = mode.neutral then
            isAlive := false
            ccc(direct) := true
        end if
    end collide
end superKey

% Super Key item for inventory %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

class * superKey_item
    inherit item
    pic := sKeyPic
end superKey_item

% Fireball Class %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

class * fireball
    inherit moveable    
    speed := 8
    damage := 5
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
        if ^m.kind = mode.enemy then
            health -= ^m.damage
        elsif ^m.kind = mode.key then
            new items, upper (items)+1
            new superKey_item, items(upper (items))
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
        Pic.Draw(pic, pos.x-(SPRTSZ div 2), pos.y-(SPRTSZ div 2), picMerge)
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
    pic := gobMove(1)(1)
    var t := w
    var mana : real := 10
    
    body proc update
        direct := getDir(pos, ^t.pos)
        pic := gobMove(direct)(((step div 10) mod 2)+1)
        isAlive := not health <= 0
        if isAlive = false then
            score += 15
        end if
    end update
    
    body proc collide
        if ^m.kind = mode.friend then
            health -= ^m.damage
        end if
    end collide
end goblin

% Boss Class %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

class * boss
    inherit goblin
    health := 100.0
    speed := 1
    canHit := false
    
    body proc update
        if ~canHit and step = 100 then
            canHit := true
            speed := 0
            step := 0
        elsif canHit and step = 50 then
            canHit := false
            direct := getDir(pos, ^t.pos)
            speed := 1
            step := 0
        end if
        pic := bossMove(direct)(((step div 15) mod 2)+1)
        if canHit then
            pic := bossIdle
        end if
        isAlive := not health <= 0
        wonTheGame := not isAlive
    end update
    
    body proc collide
        if ^m.kind = mode.friend and canHit then
            health -= ^m.damage
        end if
    end collide
    
    body proc draw
        Pic.Draw(pic, pos.x-(SPRTSZ div 2), pos.y-(SPRTSZ div 2), picMerge)
        Font.Draw("Boss:", 60, 60, smaller, black)
        Draw.FillBox(110, 60, 110+round(7.9*health), 70, brightred)
    end draw
end boss

% Room Class %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

class * room
    export getNear, getTile, setTile, draw, map
    
    var map : array 0..19, 0..12 of ^tile
    
    % Get 3 tiles in front of a tile (for collisions)
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
    canEnter := true
    pic := doorPic
    solid := true
end door
    
class * lockDoor
        inherit door
end lockDoor
    
class * superDoor
        inherit lockDoor
        pic := sDoorPic
    canEnter := ccc(1) and ccc(2) and ccc(3) and ccc(4)
end superDoor
    
% Game Controller %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

module game
    export all
    
    var timer := 0
    var spawned := false
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
        delay(1000)
    end gameover
    
    proc victory
        cls
        for i : 1 .. 500
            drawfillbox (0, 0, maxx, maxy, Rand.Int (0, 255))
            Font.Draw ("Victory!", 320, 350, big, Rand.Int (0, 255))
            View.Update
        end for
    end victory 
    
    % Spawning things into game
    
    proc spawnSKey(num : 1..4, pos : point)
        new m, upper(m)+1
        new superKey, m(upper(m))
        m(upper(m)) -> setXY(pos)
        m(upper(m)) -> direct := num
    end spawnSKey
    
    proc spawnGoblin(pos : point)
        new m, upper(m)+1
        new goblin, m(upper(m))
        m(upper(m)) -> setXY(pos)
    end spawnGoblin
    
    proc spawnBoss (pos : point)
        new m, upper(m)+1
        new boss, m(upper(m))
        m(upper(m)) -> setXY(pos)
    end spawnBoss
    
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
    
    % Loads levels from text files
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
                label 'm':
                    new tile, t
                    spawnBoss(newP((SPRTSZ div 2)+x*SPRTSZ, (SPRTSZ div 2)+y*SPRTSZ))
                label:
                    new tile, t
                    if line(x+1) = '1' or line(x+1) = '2' or line(x+1) = '3' or line(x+1) = '4' then
                        var u := strint(line(x+1))
                        if ~ccc(u) then
                            spawnSKey(u, newP((SPRTSZ div 2)+x*SPRTSZ, (SPRTSZ div 2)+y*SPRTSZ))
                        end if
                    end if
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
    
    % Removes dead moveables from list
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
            if checkColl_tile(w, c(i)) then
                if objectclass(c(i)) >= door then
                    if c(i) -> canEnter then
                        lastLevel := currentLevel
                        loadLevel(c(i) -> filename)
                    end if
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
                    if objectclass(m(i)) = boss then
                    if m(i) -> canHit then
                        if ~spawned then
                            for e : 1 .. 2
                                spawnGoblin(m(i) -> pos)
                                m(upper(m)) -> move(Rand.Int(1,4), 50)
                            end for
                                spawned := true
                        end if
                    elsif spawned then
                        spawned := false
                    end if
                end if
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
        exit when lose or wonTheGame
    end loop
    playerscore.scor := score
    if wonTheGame then
        game.victory
    elsif lose then
        game.gameover
    end if
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
        buttonwait ("down", xxx, yyy, button, button)
        if clickCheck (xxx, yyy, 100, 200, 150, 250) and letter > 65 and button = 1 then
            letter -= 1
            drawfillbox (180, 150, 270, 250, black)
            Font.Draw (chr (letter), 200, 180, big, white)
        end if
        if clickCheck (xxx, yyy, 300, 200, 350, 250) and letter < 90 and button = 1 then
            letter += 1
            drawfillbox (180, 150, 270, 250, black)
            Font.Draw (chr (letter), 200, 180, big, white)
        end if
        if clickCheck (xxx, yyy, 200, 100, 250, 150) and button = 1 then
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
    Pic.ScreenLoad ("Graphics/back.jpg", -10, -10, picMerge)
    Font.Draw ("Intructions", 300, 600, big, white)
    Font.Draw ("Use WASD to move", 10, 450, normal, white)
    Font.Draw ("Tap the arrow keys to throw fire (requires mana)", 10, 400, normal, white)
    Font.Draw ("Hold the space bar to heal (requires mana)", 10, 350, normal, white)
    Font.Draw ("Tap P to pause and unpause", 10, 300, normal, white)
    Font.Draw ("Find the four magic keys to escape", 10, 250, normal, white)
    Font.Draw ("Return", 850, 10, small, white)
    View.Update
    loop
        mousewhere (xxx, yyy, button)
        if xxx > 850 and yyy > 5 and xxx < 1000 and yyy < 50 then
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
    
    if playerscore.scor > scores(10).scor and wonTheGame then
        letterEnter
        scores(10) := playerscore
        scoresort
    end if
    
    cls
    Pic.ScreenLoad ("Graphics/back.jpg", -10, -10, picMerge)
    Font.Draw ("Name", 10, 600, big, white)
    Font.Draw ("Score", 750, 600, big, white)
    
    for i : 1 .. 10
        Font.Draw (scores (11-i).name, 10, 45 * i + 105, normal, white)
        Font.Draw (intstr (scores (11-i).scor), 750, 45 * i + 105, normal, white)
    end for
        
    Font.Draw ("Main Menu" , 405, 13, small, white)
    View.Update
    
    loop
        mousewhere (xxx, yyy, button)
        if xxx > 400 and yyy > 5 and xxx < 575 and yyy < 50 then
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
Music.PlayFileLoop("Music/Geothermal.mp3")
loop    
    Pic.ScreenLoad ("Graphics/back.jpg", -10, -10, picMerge)
    Font.Draw ("Sorcerer's Maze", 210, 600, big, white)
    Font.Draw ("PLAY", 457, 300, normal, white)
    Font.Draw ("INSTRUCTIONS", 370, 250, normal, white)
    Font.Draw ("HIGH SCORES", 384, 200, normal, white)
    Font.Draw ("QUIT", 455, 150, normal, white)
    
    mousewhere (xxx, yyy, button)
    if xxx > 452 and yyy > 295 and xxx < 540 and yyy < 340 then
        drawbox (452, 295, 540, 340, white)
        if button = 1 then
            gamerun
            scorescreen
        end if
    elsif xxx > 365 and yyy > 245 and xxx < 620 and yyy < 290 then
        drawbox (365, 245, 620, 290, white)
        if button = 1 then
            controls
        end if
    elsif xxx > 379 and yyy > 195 and xxx < 612 and yyy < 240 then
        drawbox (379, 195, 612, 240, white)
        if button = 1 then
            scorescreen
        end if
    elsif xxx > 450 and yyy > 140 and xxx < 537 and yyy < 188 then
        drawbox (450, 143, 540, 188, white)
        if button = 1 then
            exit
        end if
    end if
    View.Update
end loop
Music.PlayFileStop
Window.Hide (-1)