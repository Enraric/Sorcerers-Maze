%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sorcerer's Maze                      %
% Programmed by Alexander McMorine III %
% Work Started 11/11/2013              %
% Work Finished --/--/--               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
    export update, collide, kind, damage, var isAlive
    var kind : mode
    var speed : int
    var health : real
    var damage : real
    var limit : 1..4
    var isAlive := true
    
    deferred proc update
    deferred proc collide(m : ^moveable)
end moveable

% The parent class for all things on-screen that DON'T move %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

class * static
    inherit object
    
    body proc draw
        Pic.Draw(pic, pos.x, pos.y, picCopy)
    end draw
end static

% The parent class for all types of items %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

class * item
    export initialize, use, draw, var w
    
    var w : ^moveable
    var pic : int
    
    proc initialize(p : int)
    end initialize
    
    deferred proc use
    
    proc draw(i : int)
        Pic.Draw(pic, 48 * i + 50, maxy-50, picCopy)
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
        case direct of
        label 1:
            pos.y += speed
        label 2:
            pos.x += speed
        label 3:
            pos.y -= speed
        label 4:
            pos.x -= speed
        end case
        if pos.x > maxx or pos.x < 0 or pos.y > maxy or pos.y < 0 then
            isAlive := false
        end if
        pic := fire(direct)(1)
    end update
    
    body proc collide(m : ^moveable)
        isAlive := false
    end collide
    
    body proc draw
        Pic.Draw(pic, pos.x-20, pos.y-20, picCopy)
    end draw
end fireball

% Wizard Class %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

class * wizard
    inherit moveable
    
    kind := mode.neutral
    pos := newP(100, 100)
    pic := wizIdle
    speed := 3
    health := 50.0
    var mana := 50.0
    var items : flexible array 1..0 of ^item
    
    proc heal
        if mana > 0 then
            mana -= 1
            health += 1
        end if
        if health > 100 then
            health := 100
        end if
    end heal
    
    body proc collide(m : ^moveable)
        if ^m.kind = mode.enemy then
            health -= ^m.damage
        end if
    end collide
    
    body proc update
        if mana < 100 then
            mana += 0.05
        end if
        if keys ('w') then
            pos.y += speed
        elsif keys ('s') then
            pos.y -= speed
        elsif keys ('a') then
            pos.x -= speed
        elsif keys ('d') then
            pos.x += speed
        else
            pic := wizIdle
        end if
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

% Game Controller %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

module game
    export all
    
    var timer := 0
    var shot := false
    var w : ^wizard
    var g : flexible array 1..0 of ^goblin
    var f : flexible array 1..0 of ^fireball
    var level : array 1..13, 1..20 of ^static
    var arrowKeys : array 1..4 of char := init(KEY_UP_ARROW, KEY_RIGHT_ARROW, KEY_DOWN_ARROW, KEY_LEFT_ARROW)
    
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
        new f, upper(f) + 1
        new f(upper(f))
        f(upper(f)) -> direct := i
        f(upper(f)) -> setXY(^w.pos)
    end spawnFireball
    
    proc initialize(numGob : int)
        new w
        for i : 1..numGob
            spawnGoblin
        end for
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
                spawnFireball(i)
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
        w -> draw
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
            
        locate(1,1)
        put upper(f)
    end draw
end game

% Main Program %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

View.Set("graphics:800;580,offscreenonly,nobuttonbar")

game.initialize(10)

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
