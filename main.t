%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sorcerer's Maze                      %
% Programmed by Alexander McMorine III %
% Work Started 11/11/2013              %
% Work Finished --/--/--               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Stuff for Colision Detection %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

% Loading Game Sprites %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fcn loadPics(name : string) : array 1 .. 4 of array 1 .. 2 of int
    var a : array 1..4 of array 1..2 of int
    for i : 1..2
        a(1)(i) := Pic.FileNew("Graphics/"+name+"_"+intstr(i)+".bmp")
    end for
        for i : 2..4
        for j : 1..2
            a(i)(j) := Pic.Rotate(a(1)(j), (5-i)*90, 20, 20)
        end for
    end for
        result a
end loadPics

%var * potPic := Pic.FileNew("Graphics/health_potion.bmp")
var * wallPic := Pic.FileNew("Graphics/wall.bmp")
var * groundPic := Pic.FileNew("Graphics/ground.bmp")
var * wizIdle := Pic.FileNew("Graphics/mage_idle.bmp")
var * wizMove := loadPics("mage")
var * gobMove := loadPics("troll")
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
    export defUpdate, defCollide, move, var isAlive, var limit, var direct
    solid := true
    var speed : int
    var direct : 1..4
    var health : real
    var isAlive := true
    var limit : array 1..4 of boolean := init(false, false, false, false)
    
    proc move_unckecked(dir : 1..4)
        case dir of
        label 1:
            pos.y += speed
        label 2:
            pos.x += speed
        label 3:
            pos.y -= speed
        label 4:
            pos.x -= speed
        end case
    end move_unckecked
    
    proc move(dir : 1..4)
        if not limit(dir) then
            move_unckecked(dir)
        end if
    end move
    
    deferred proc update
    deferred proc collide(m : ^object)
    
    proc defUpdate
        update
        for i : 1..4
            limit(i) := false
        end for
    end defUpdate
    
    proc defCollide(m : ^object)
        collide(m)
        limit(getDir(pos, ^m.pos)) := ^m.solid
    end defCollide
end moveable

% The parent class for all things on-screen that DON'T move %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

class * tile
    inherit object
    solid := false
    pic := groundPic
    
    body proc draw
        Pic.Draw(pic, pos.x-20, pos.y-20, picMerge)
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

% Fireball Class %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

class * fireball
    inherit moveable    
    speed := 5
    damage := 50.0
    kind := mode.friend
    solid := false
    
    body proc update
        move(direct)
        if pos.x > maxx or pos.x < 0 or pos.y > maxy or pos.y < 0 then
            isAlive := false
        end if
        pic := fire(direct)(1)
    end update
    
    body proc collide
        if ^m.kind not= mode.neutral and ^m.solid then
            isAlive := false
        end if
    end collide
    
    body proc draw
        Pic.Draw(pic, pos.x-20, pos.y-20, picMerge)
    end draw
end fireball

% Wizard Class %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

class * wizard
    inherit moveable
    export useMana
    kind := mode.neutral
    pos := newP(100, 100)
    pic := wizIdle
    speed := 3
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
        for i : 1..4
            if keys(wdsa(i)) then
                move(i)
                pic := wizMove(i)(1)
            end if
        end for
            if keys (' ') then
            heal
        end if
        lose := health <= 0
    end update
    
    body proc draw
        Pic.Draw(pic, pos.x-20, pos.y-20, picMerge)
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
    var step := 0
    var t := w
    
    body proc update
        direct := getDir(pos, ^t.pos)
        move(direct)
        pic := gobMove(direct)(1)
        isAlive := not health <= 0
    end update
    
    body proc collide
        if ^m.kind = mode.friend then
            health -= ^m.damage
        end if
    end collide
    
    body proc draw
        Pic.Draw(pic, pos.x-20, pos.y-20, picCopy)
    end draw
end goblin

% Room Class %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

class * room
    export getNear, getTile, setTile, draw, initialize, map
    
    var map : array 0..19, 0..12 of ^tile
    
    proc initialize
        for x : 0..19
            for y : 0..12
                if y = 0 or x = 0 or y = 12 or x = 19 then
                    new wall, map(x, y)
                else
                    new tile, map(x, y)
                end if
                map(x, y) -> setXY(newP(20+x*40, 20+y*40))
            end for
        end for
    end initialize
    
    fcn getNear(x, y : int) : array 1..9 of ^tile
        var a : array 1..9 of ^tile
        var c := 1
        for xind : -1..1
            for yind : -1..1
                a(c) := map(x+xind, y+yind)
                c += 1
            end for
        end for
            result a
    end getNear
    
    fcn getTile(x, y : int) : ^tile
        result map(x, y)
    end getTile
    
    proc setTile(x, y : int, newTile : ^tile)
        map(x, y) := newTile
        map(x, y) -> setXY(newP(20+x*40, 20+y*40))
    end setTile
    
    proc draw
        for x : 0..19
            for y : 0..12
                map(x, y) -> draw
            end for
        end for
    end draw
end room

% Game Controller %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

module game
    export all
    
    var timer := 0
    var shot : array 1..4 of boolean := init(false, false, false, false)
    var arrowKeys : array 1..4 of char := init(KEY_UP_ARROW, KEY_RIGHT_ARROW, KEY_DOWN_ARROW, KEY_LEFT_ARROW)
    var m : flexible array 1..0 of ^moveable
    var level : ^room
    
    fcn checkColl(m1, m2 : ^moveable) : boolean
        var c := abs(^m1.pos.x - ^m2.pos.x) <= 40 and abs(^m1.pos.y - ^m2.pos.y) <= 40
        if c then
            ^m1.defCollide(m2)
            ^m2.defCollide(m1)
        end if
        result c
    end checkColl
    
    fcn checkColl_tile(m : ^moveable, s : ^tile) : boolean
        var c := abs(^m.pos.x - (^s.pos.x)) <= 40 and abs(^m.pos.y - (^s.pos.y)) <= 40
        if c then
            ^m.defCollide(s)
        end if
        result c
    end checkColl_tile
    
    proc gameover
        cls
        drawfillbox (0, 0, maxx, maxy, black)
        Font.Draw ("Game Over", 250, 300, title, white)
        View.Update
    end gameover
    
    proc spawnGoblin
        new m, upper(m)+1
        new goblin, m(upper(m))
        m(upper(m)) -> setXY(newP(Rand.Int(100, maxx-100), Rand.Int(100, maxy-100)))
    end spawnGoblin
    
    proc spawnFireball(i : int)
        if ^w.useMana(10) then
            new m, upper(m)+1
            new fireball, m(upper(m))
            m(upper(m)) -> direct := i
            m(upper(m)) -> setXY(^w.pos)
        end if
    end spawnFireball
    
    proc initialize(numGob : int)
        new w
        new level
        for i : 1..numGob
            spawnGoblin
        end for
            ^level.initialize
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
        if keys('c') then
            spawnGoblin
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
        var c := ^level.getNear(^w.pos.x div 40, ^w.pos.y div 40)
        for i : 1..9
            var tmp := checkColl_tile(w, c(i))
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
                    var a := ^level.getNear(^(m(i)).pos.x div 40, ^(m(i)).pos.y div 40)
                for j : 1..9
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
    end draw
end game

% Main Program %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

View.Set("graphics:800;580,offscreenonly,nobuttonbar")

game.initialize(1)

loop
    Input.KeyDown (keys)
    game.update
    game.draw
    View.Update
    cls
    Time.DelaySinceLast (16)
    exit when lose
end loop

game.gameover
