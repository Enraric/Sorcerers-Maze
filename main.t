%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sorcerer's Maze                      %
% Programmed by Alexander McMorine III %
% Work Started 11/11/2013              %
% Work Finished --/--/--               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Variable Declaration

const * UP := chr (119)
const * DOWN := chr (115)
const * LEFT := chr (97)
const * RIGHT := chr (100)
const * SPACE := chr (32)
var * keys : array char of boolean
var * text := Font.New ("Serif:14")
var * lose : boolean := false
var * title := Font.New ("Serif:48:Bold")
type * mode : enum(friend, enemy, neutral)

% Game Over Screen %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

proc gameover
    cls
    drawfillbox (0, 0, 1000, 1000, black)
    Font.Draw ("Game Over", 250, 300, title, white)
    View.Update
end gameover

% The parent class for all types of items
class * item
    export initialize, use, draw
    
    var pic : int
    
    proc initialize(p : int)
    end initialize
    
    deferred proc use
    
    proc draw(i : int)
        %Pic.Draw(48 * i + 50)
    end draw
end item

% The parent class for all things on-screen that move
class moveable
    export update, draw, collide, setXY, x, y, kind, damage
    var kind : mode
    var x, y : int
    var health : real
    var speed : int
    var damage : real
    
    deferred proc update
    deferred proc draw
    deferred proc collide(m : ^moveable)
    
    proc setXY(nx, ny : int)
        x := nx
        y := ny
    end setXY
end moveable

%Wizard Class %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

class * wizard
    inherit moveable
    
    kind := mode.friend
    x := 100
    y := 100
    speed := 3
    health := 50.0
    var mana := 50.0
    
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
        if keys (UP) then
            y += speed
        elsif keys (DOWN) then
            y -= speed
        elsif keys (LEFT) then
            x -= speed
        elsif keys (RIGHT) then
            x += speed
        end if
        if keys (SPACE) then
            heal
        end if
        lose := health <= 0
        
    end update
    
    body proc draw
        Draw.FillOval (x, y, 20, 20, red)
        
            Draw.FillBox (0, maxy-60, maxx, maxy, black)

        Font.Draw ("Health", 210, maxy-25, text, white)
        Font.Draw ("Mana", 210, maxy-50, text, white)
        for i : 0 .. 3
            Draw.FillBox (0, maxy-40, round (health * 2), maxy - i * 10, 47 + i)
        end for
            
        for i : 0 .. 3
            Draw.FillBox (0, maxy-60, round (mana * 2), maxy - 41 - i * 5, 32 + i)
        end for
    end draw
    
end wizard

% Goblin Class %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

class * goblin
    inherit moveable
    export var t
    
    kind := mode.enemy
    x := 300
    y := 300
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
    
    body proc collide
    end collide
    
    body proc draw
        Draw.FillOval (x, y, 20, 20, purple)
    end draw
end goblin

% Procedure to check for collisions between two moveable objects
proc checkColl(m1, m2 : ^moveable)
    if abs(^m1.x - ^m2.x) <= 40 and abs(^m1.y - ^m2.y) <= 40 then
        ^m1.collide(m2)
        ^m2.collide(m1)
    end if
end checkColl

%Main Program %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

View.Set ("graphics:800;580,offscreenonly,nobuttonbar")
var g : ^goblin
new g
var w : ^wizard
new w
^g.t := w
loop
    Input.KeyDown (keys)
    w -> update
    w -> draw
    g -> update
    g -> draw
    checkColl(w, g)
    View.Update
    cls
    Time.DelaySinceLast (16)
    exit when lose
end loop
gameover
