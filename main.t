%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TO DO LIST (in no particular order)  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Spawning at correct door             %
% Locking doors + keys                 %
% Superdoors + Superkeys               %
% Colision                             %
% Goblin AI + arrows                   %
% Goblin Mother                        %
% Main Menu                            %
% High Scores                          %
% Win Conditions                       %
% Potions                              %
% Music / sound effects (?)            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sorcerer's Maze                      %
% Programmed by Alexander McMorine III %
% and Ian Frosst                       %
% Work Started 11/11/2013              %
% Work Finished --/--/--               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

const * SPRTSZ := 48
var * score : int := 0
var step : int := 0

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
        move(direct, -(speed))
        collide(m)
    end defCollide
end moveable

% The parent class for all things on-screen that DON'T move %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

class * tile
    inherit object
    export var filename
    solid := false
    pic := groundPic
    var filename : string    
    
    body proc draw
        Pic.Draw(pic, pos.x-(SPRTSZ div 2), pos.y-(SPRTSZ div 2), picCopy)
    end draw
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
    damage := 50.0
    kind := mode.friend
    solid := false
    
    body proc update
        if pos.x > maxx or pos.x < 0 or pos.y > maxy or pos.y < 0 then
            isAlive := false
        end if
        pic := fire(direct)(((step div 10) mod 2)+1)
    end update
    
    body proc collide
        if ^m.kind not= mode.neutral and ^m.solid and getDir(pos, ^m.pos) = direct then
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
        if ^m.kind = mode.enemy then
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
    var randmove := Rand.Int (0, 4)
    var t := w
    
    body proc update
        direct := getDir(pos, ^t.pos)
        pic := gobMove(direct)(((step div 10) mod 2)+1)
        isAlive := not health <= 0
        if isAlive = false then
            score -= 10
        end if
    end update
    
    body proc collide
        if ^m.kind = mode.friend then
            health -= ^m.damage
        end if
    end collide
    
    body proc draw
        Pic.Draw(pic, pos.x-(SPRTSZ div 2), pos.y-(SPRTSZ div 2), picCopy)
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
                a(i) := map((x-2)+i,(y+2)-dir)
            end for
            else
            for i : 1..3
                a(i) := map((x+3)-dir,(y-1)+i)
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
        var c := abs(^m1.pos.x - ^m2.pos.x) <= SPRTSZ and abs(^m1.pos.y - ^m2.pos.y) <= SPRTSZ
        if c then
            ^m1.defCollide(m2)
            ^m2.defCollide(m1)
        end if
        result c
    end checkColl
    
    fcn checkColl_tile(m : ^moveable, s : ^tile) : boolean
        var c := abs(^m.pos.x - ^s.pos.x) <= SPRTSZ and abs(^m.pos.y - ^s.pos.y) <= SPRTSZ and ^s.solid
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
        end if
    end spawnFireball
    
    proc loadLevel(filename : string)
        for i : 1..upper(m)
            free m(i)
        end for
            new m, 0
        currentLevel := filename
        if lastLevel = "" then
            w -> setXY(newP(maxx div 2, maxy div 2))
        else
            if lastLevel(1) > currentLevel(1) then
                w -> setXY(newP(50, 288))
            elsif lastLevel(1) < currentLevel(1) then
                w -> setXY(newP(910, 288))
            else
                if lastLevel(2) < currentLevel(2) then
                    w -> setXY(newP(400, 50))
                elsif lastLevel(2) > currentLevel(2) then
                    w -> setXY(newP(400, 575))
                end if
            end if
        end if
        
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
                    var temp := checkColl_tile(m(i), a(j))
                end for
            end if
        end for
            if Time.Elapsed - timer > 1000 then
            sweep
            timer := Time.Elapsed
        end if
    end update
    
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
end game

% Pause Screen %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

proc pausescreen
    var asdasf := Font.New ("Sans:48:Bold")
    drawfillbox (0, 0, 1000, 1000, black)
    Font.Draw ("PAUSED", 330, 330, asdasf, white)
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

% Main Program %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

View.Set("graphics:"+intstr(20*SPRTSZ)+";"+intstr(13*SPRTSZ+60)+",offscreenonly,nobuttonbar")

game.initialize("C3") 

loop
    Input.KeyDown (keys)
    game.update
    if keys ('p') then
        pausescreen
        delay (50)
    end if
    if step = 4 then
        score += 1
        step := 0
    end if
    if score < 0 then
        score := 0
    end if
    game.draw
    View.Update
    cls
    Time.DelaySinceLast (16)
    step += 1
    exit when lose
end loop

game.gameover
