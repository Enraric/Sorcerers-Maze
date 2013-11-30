%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sorcerer's Maze                      %
% Programmed by Alexander McMorine III %
% Work Started 11/11/2013              %
% Work Finished --/--/--               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

var * DEBUG_MODE := false

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

%var * potPic := Pic.FileNew("Graphics/health_potion.bmp")
var * wallPic := Pic.FileNew("Graphics/wall.bmp")
var * groundPic := Pic.FileNew("Graphics/ground.bmp")
var * wizIdle := Pic.FileNew("Graphics/mage_idle.bmp")
var * wizMove : array 1 .. 4 of array 1 .. 2 of int
var * gobIdle := Pic.FileNew("Graphics/superdoor_open.bmp")
var * gobMove : array 1 .. 4 of array 1 .. 2 of int
var * fire : array 1 .. 4 of array 1 .. 2 of int
for i : 1..2
    fire(1)(i) := Pic.FileNew("Graphics/fire_"+intstr(i)+".bmp")
end for
    for i : 2..4
    for j : 1..2
        fire(i)(j) := Pic.Rotate(fire(1)(j), (5-i)*90, 20, 20)
    end for
end for
    
% Variable Declaration %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

var * keys : array char of boolean
var * text := Font.New ("Serif:14")
var * lose : boolean := false
var * title := Font.New ("Serif:48:Bold")
type * mode : enum(friend, enemy, neutral)

% The parent class for all things on-screen %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

class * object
    export draw, setXY, pos
    var pos : point
    var pic : int
    
    deferred proc draw
    
    proc setXY(np : point)
        pos.x := np.x
        pos.y := np.y
    end setXY
end object

% The parent class for all things on-screen that move %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

class * moveable
    inherit object
    export update, collide, move, limit, kind, damage, var isAlive
    var kind : mode
    var speed : int
    var health : real
    var damage : real
    var isAlive := true
    var limited : array 1..4 of boolean := init(false, false, false, false)
    
    proc limit(i : 1..4)
        limited(i) := not limited(i)
    end limit
    
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
        if not limited(dir) then
            move(dir)
        end if
    end move
    
    deferred proc update
    deferred proc collide(m : ^moveable)
end moveable

% The parent class for all things on-screen that DON'T move %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

class * static
    inherit object
    
    pic := groundPic
    
    body proc draw
        Pic.Draw(pic, pos.x, pos.y, picCopy)
    end draw
end static

% The parent class for all types of items %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

class * item
    export use, draw, var w
    
    var w : ^moveable
    var pic : int
    
    deferred proc use
    
    proc draw(i : int)
        Pic.Draw(pic, 48 * i + 270, maxy-50, picCopy)
    end draw
end item

% Fireball Class %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

class * fireball
    inherit moveable
    export var direct
    
    speed := 5
    damage := 50.0
    kind := mode.friend
    var direct : 1..4
    
    body proc update
        move(direct)
        if pos.x > maxx or pos.x < 0 or pos.y > maxy or pos.y < 0 then
            isAlive := false
        end if
        pic := fire(direct)(1)
    end update
    
    body proc collide(m : ^moveable)
        isAlive := false
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
    
    body proc collide(m : ^moveable)
        if ^m.kind = mode.enemy then
            health -= ^m.damage
        end if
    end collide
    
    body proc update
        if mana < 100 then
            mana += 0.05
        end if
        for i : 1..4
            if keys(wdsa(i)) then
                move(i)
            end if
            pic := wizIdle
        end for
        if keys (' ') then
            heal
        end if
        lose := health <= 0
    end update
    
    body proc draw
        Pic.Draw(pic, pos.x-20, pos.y-20, picCopy)
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

% Wall Class %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

class * wall
    inherit static
    
    pic := wallPic
end wall

% Goblin Class %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

class * goblin
    inherit moveable
    export var t
    
    kind := mode.enemy
    health := 1.0
    speed := 2
    damage := 0.5
    var randmove := Rand.Int (0, 4)
    var step := 0
    var t : ^moveable
    
    body proc update
        if pos.x > ^t.pos.x+5 then
            pos.x -= speed
        elsif pos.x < ^t.pos.x-5 then 
            pos.x += speed
        else
            if pos.y > ^t.pos.y+5 then
                pos.y -= speed
            elsif pos.y < ^t.pos.y-5 then
                pos.y += speed
            end if
        end if
        isAlive := not health <= 0
    end update
    
    body proc collide(m : ^moveable)
        if ^m.kind = mode.friend then
            health -= ^m.damage
        end if
    end collide
    
    body proc draw
        Pic.Draw(gobIdle, pos.x-20, pos.y-20, picCopy)
    end draw
end goblin

% Room Class %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

class * room
    export getTile, setTile, draw, initialize, map
    
    var map : array 0..19, 0..12 of ^static
    
    proc initialize
        for x : 0..19
            for y : 0..12
                if y = 0 or x = 0 or y = 12 or x = 19 then
                    new wall, map(x, y)
                else
                    new static, map(x, y)
                end if
                map(x, y) -> setXY(newP(x*40, y*40))
            end for
        end for
    end initialize
    
    fcn getTile(x, y : int) : ^static
        result map(x, y)
    end getTile
    
    proc setTile(x, y : int, newTile : ^static)
        map(x, y) := newTile
        map(x, y) -> setXY(newP(x*40, y*40))
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
    
    var DEBUG_WIN : int
    var timer := 0
    var shot : array 1..4 of boolean := init(false, false, false, false)
    var arrowKeys : array 1..4 of char := init(KEY_UP_ARROW, KEY_RIGHT_ARROW, KEY_DOWN_ARROW, KEY_LEFT_ARROW)
    var w : ^wizard
    var g : flexible array 1..0 of ^goblin
    var f : flexible array 1..0 of ^fireball
    var level : ^room
    
    fcn checkColl(m1, m2 : ^moveable) : boolean
        var c := abs(^m1.pos.x - ^m2.pos.x) <= 40 and abs(^m1.pos.y - ^m2.pos.y) <= 40
        if c then
            ^m1.collide(m2)
            ^m2.collide(m1)
        end if
        result c
    end checkColl
    
    proc gameover
        cls
        drawfillbox (0, 0, maxx, maxy, black)
        Font.Draw ("Game Over", 250, 300, title, white)
        View.Update
    end gameover
    
    proc spawnGoblin
        new g, upper(g)+1
        new g(upper(g))
        g(upper(g)) -> t := w
        g(upper(g)) -> setXY(newP(Rand.Int(50, maxx-50), Rand.Int(50, maxy-50)))
    end spawnGoblin
    
    proc spawnFireball(i : int)
        if ^w.useMana(5) then
            new f, upper(f) + 1
            new f(upper(f))
            f(upper(f)) -> direct := i
            f(upper(f)) -> setXY(^w.pos)
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
        var numDead := 0
        for i : 1..upper(g)
            if not g(i) -> isAlive then
                var dead := g(i)
                g(i) := g(upper(g))
                numDead += 1
                free dead
                exit
            end if
        end for
        new g, upper(g)- numDead
        numDead := 0
        for i : 1..upper(f)
            if not f(i) -> isAlive then
                var dead := f(i)
                f(i) := f(upper(f))
                numDead += 1
                free dead
                exit
            end if
        end for
        new f, upper(f)- numDead
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
        w -> update
        for i : 1..upper(g)
            if g(i) -> isAlive then
                g(i) -> update
                var tmp := checkColl(g(i), w)
                for j : 1..upper(f)
                    if f(j) -> isAlive then
                        var temp := checkColl(g(i), f(j))
                    end if
                end for
            end if
        end for
        for i : 1..upper(f)
            if f(i) -> isAlive then
                f(i) -> update
            end if
        end for
        if Time.Elapsed - timer > 50 then
            sweep
            timer := Time.Elapsed
        end if
    end update
    
    proc draw
        ^level.draw
        for i : 1..upper(g)
            if g(i) -> isAlive then
                g(i) -> draw
            end if
        end for
        for i : 1..upper(f)
            if f(i) -> isAlive then
                f(i) -> draw
            end if
        end for
        w -> draw
    end draw
end game

% Main Program %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

View.Set("graphics:800;580,offscreenonly,nobuttonbar")

game.initialize(0)

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
