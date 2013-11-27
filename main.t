%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sorcerer's Maze                      %
% Programmed by Alexander McMorine III %
% Work Started 11/11/2013              %
% Work Finished --/--/--               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

var * wizIdle := Pic.FileNew("Graphics/mage_idle.bmp")
var * wizMove : array 1 .. 4 of array 1 .. 2 of int
var * gobIdle := Pic.FileNew("Graphics/superdoor_open.bmp")
var * gobMove : array 1 .. 4 of array 1 .. 2 of int

% Variable Declaration %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

var * keys : array char of boolean
var * text := Font.New ("Serif:14")
var * lose : boolean := false
var * title := Font.New ("Serif:48:Bold")
type * mode : enum(friend, enemy, neutral)

% The parent class for all things on-screen %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

class * object
    export draw, setXY, x, y
    var x, y : int
    var pic : int
    
    deferred proc draw
    
    proc setXY(nx, ny : int)
        x := nx
        y := ny
    end setXY
end object

% The parent class for all things on-screen that move %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

class * moveable
    inherit object
    export update, collide, kind, damage
    var kind : mode
    var speed : int
    var health : real
    var damage : real
    
    deferred proc update
    deferred proc collide(m : ^moveable)
end moveable

% The parent class for all things on-screen that DON'T move %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

class * static
    inherit object
    
    body proc draw
        Pic.Draw(pic, x, y, picCopy)
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
            y += speed
        label 2:
            x += speed
        label 3:
            y -= speed
        label 4:
            x -= speed
        end case
    end update
    
    body proc draw
        Pic.Draw(pic, x-20, y-20, picCopy)
    end draw
end fireball

% Wizard Class %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

class * wizard
    inherit moveable
    
    kind := mode.neutral
    x := 100
    y := 100
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
            y += speed
        elsif keys ('s') then
            y -= speed
        elsif keys ('a') then
            x -= speed
        elsif keys ('d') then
            x += speed
        else
            pic := wizIdle
        end if
        if keys (' ') then
            heal
        end if
        lose := health <= 0
    end update
    
    body proc draw
        Pic.Draw(pic, x-20, y-20, picCopy)
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
    damage := 0.75
    var randmove := Rand.Int (0, 4)
    var step := 0
    var t : ^moveable
    
    body proc update
        if x > ^t.x+5 then
            x -= speed
        elsif x < ^t.x-5 then 
            x += speed
        else
            if y > ^t.y+5 then
                y -= speed
            elsif y < ^t.y-5 then
                y += speed
            end if
        end if
    end update
    
    body proc collide(m : ^moveable)
        if ^m.kind = mode.friend then
            health -= ^m.damage
        end if
    end collide
    
    body proc draw
        Pic.Draw(gobIdle ,x-20, y-20, picCopy)
    end draw
end goblin

% Game Controller %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

module game
    export all
    
    var w : ^wizard
    var g : flexible array 1..0 of ^goblin
    var f : flexible array 1..0 of ^fireball
    var level : array 1..13, 1..20 of ^static
    
    fcn checkColl(m1, m2 : ^moveable) : boolean
        var c := abs(^m1.x - ^m2.x) <= 40 and abs(^m1.y - ^m2.y) <= 40
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
    
    proc spawn
        new g, upper(g) + 1
        new g(upper(g))
        g(upper(g)) -> t := w
        g(upper(g)) -> setXY(Rand.Int(50, maxx-50), Rand.Int(50, maxy-50))
    end spawn
    
    proc initialize(numGob : int)
        new w
        new g, numGob
        for i : 1..numGob
            new g(i)
            g(i) -> t := w
            g(i) -> setXY(Rand.Int(50, maxx-50), Rand.Int(50, maxy-50))
        end for
    end initialize
    
    proc update
        w -> update
        for i : 1..upper(g)
            g(i) -> update
            var tmp := checkColl(w, g(i))
        end for
            if keys('c') then
            spawn
        end if
    end update
    
    proc draw
        w -> draw
        for i : 1..upper(g)
            g(i) -> draw
        end for
            for i : 1..upper(f)
            f(i) -> draw
        end for
    end draw
end game

% Main Program %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

View.Set ("graphics:800;580,offscreenonly,nobuttonbar")

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
