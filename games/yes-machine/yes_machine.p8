pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- yes machine
-- a micro-game about the power of no
-- my strategy squad, episode 4
-- code written with claude, an ai
-- assistant, and edited and tested
-- by andrew david roberts
-- code: mit license
-- art, sound, text: cc by 4.0
-- the my strategy squad name and
-- logo are not covered

-- tuning: same numbers as the
-- browser version
weeks=8
cap0=10
pay_pen=0.3
cap_min=4

types={"older-home repairs","new installs","emergency call-outs"}
names={
 {"leaky tap in a 1920s house","rotten pipe under a kitchen","old boiler valve seized"},
 {"bathroom for a new build","six flats, bulk fit-out","kitchen remodel"},
 {"burst pipe, sunday morning","night-time flood call","blocked main drain"}
}

-- plain-english how-to-play pages
-- (keep in step with the tuning)
how_pages={
 {"the goal",{"you run a small trade business.","the game lasts 8 weeks.","each week you have about 10","slots: chunks of working time.","","your score adds up your cash,","how well you're known for your","focus, and the energy you have","left at the end."}},
 {"your focus",{"first, pick your focus: the","kind of work you want to be","known for. older-home repairs,","new installs, or emergency","call-outs.","","work on your focus builds your","name. work off it pays, but","pulls you away from it."}},
 {"offers",{"each week, offers arrive. each","shows how many slots it needs","and what it pays per slot.","","x: yes. take the job.","o: no. turn it down.","up: redirect. a polite no,","with someone else's name to","give them. (o is z or c)"}},
 {"too much work",{"say yes to more slots than","you have, and the extra goes","badly: you aren't paid for it,","and you lose 30% of its fee.","","it also costs energy and","reputation. low energy means","fewer slots the next week."}},
 {"known for it",{"known for it: how strongly","people link you to your focus.","on-focus work raises it.","off-focus work lowers it.","","redirecting off-focus work","raises it a little, and can","bring an on-focus offer next","week. saying no is free."}},
}

function r5(x)
 return flr(x/5+0.5)*5
end

function f1(x)
 return flr(x*10)/10
end

function capeff()
 return max(cap_min,cap0-flr((10-hh)/2.5))
end

function _init()
 scr="title"
 sel=0
 pg=1
end

function start_game()
 foc=sel
 wk=0
 cash=0
 kk=3
 hh=10
 cr=0
 new_cr=0
 new_week()
end

function new_week()
 wk+=1
 used=0
 on_s=0
 off_s=0
 red_off=0
 new_cr=0
 make_offers()
 oi=1
 scr="offer"
end

function make_offers()
 offers={}
 local n=4+min(2,cr)
 for i=1,n do
  local on=(i>4) or rnd(1)<0.25+0.05*kk
  local ty=foc
  if not on then
   ty=(foc+1+flr(rnd(2)))%3
  end
  local s=2+flr(rnd(4))
  local r=0
  if on then
   r=r5(120+6*kk+rnd(20))
  elseif rnd(1)<0.25 then
   r=r5(150+rnd(40))
  else
   r=r5(85+rnd(45))
  end
  add(offers,{ty=ty,on=on,s=s,r=r,n=names[ty+1][1+flr(rnd(3))]})
 end
end

function decide(ch)
 local o=offers[oi]
 if ch=="yes" then
  local room=max(0,capeff()-used)
  local fit=min(o.s,room)
  local over=o.s-fit
  used+=o.s
  -- clawback rounded to whole dollars
  cash+=fit*o.r-flr(over*o.r*pay_pen+0.5)
  if o.on then
   on_s+=o.s
  else
   off_s+=o.s
  end
 elseif ch=="red" then
  new_cr+=1
  if not o.on then red_off+=1 end
 end
 oi+=1
 if oi>#offers then
  close_week()
 end
end

function close_week()
 pk=kk
 ph=hh
 wov=max(0,used-capeff())
 wused=used
 wcap=capeff()
 if wov==0 then hh+=0.5 end
 hh-=wov
 hh=mid(0,hh,10)
 kk=mid(0,kk+0.5*on_s-0.5*off_s+0.25*red_off-0.25*wov,10)
 cr=new_cr
 scr="wrap"
end

function score()
 return flr(cash+120*kk+60*hh)
end

function _update()
 if scr=="title" then
  if btnp(5) then
   scr="how"
   hpg=1
  end
 elseif scr=="how" then
  if btnp(4) and hpg>1 then hpg-=1 end
  if btnp(5) then
   if hpg<#how_pages then hpg+=1 else scr="focus" end
  end
 elseif scr=="focus" then
  if btnp(2) then sel=(sel+2)%3 end
  if btnp(3) then sel=(sel+1)%3 end
  if btnp(5) then start_game() end
 elseif scr=="offer" then
  if btnp(5) then decide("yes")
  elseif btnp(4) then decide("no")
  elseif btnp(2) then decide("red")
  end
 elseif scr=="wrap" then
  if btnp(5) then
   if wk>=weeks then
    scr="end"
   else
    new_week()
   end
  end
 elseif scr=="end" then
  if btnp(5) then
   scr="deb"
   pg=1
  end
 elseif scr=="deb" then
  if btnp(5) then
   if pg==1 then
    pg=2
   else
    scr="title"
   end
  end
 end
end

function bar(x,y,w,v,c)
 rect(x,y,x+w,y+4,7)
 local fw=flr((w-2)*v/10)
 if fw>0 then rectfill(x+1,y+1,x+fw,y+3,c) end
end

function _draw()
 cls(1)
 if scr=="title" then
  draw_title()
 elseif scr=="how" then
  draw_how()
 elseif scr=="focus" then
  draw_focus()
 elseif scr=="offer" then
  draw_offer()
 elseif scr=="wrap" then
  draw_wrap()
 elseif scr=="end" then
  draw_end()
 else
  draw_deb()
 end
end

function draw_title()
 print("yes machine",42,30,7)
 print("a game about",38,44,6)
 print("the power of no",32,52,6)
 print("press x",48,100,10)
end

function draw_how()
 local pg_=how_pages[hpg]
 print("how to play "..hpg.."/"..#how_pages,2,2,10)
 print(pg_[1],2,14,12)
 for i=1,#pg_[2] do
  print(pg_[2][i],2,16+i*8,7)
 end
 if hpg>1 then print("o: back",2,116,5) end
 if hpg<#how_pages then
  print("x: next",96,116,10)
 else
  print("x: start",92,116,10)
 end
end

function draw_focus()
 print("pick your focus",2,2,10)
 print("what do you want to be",2,14,6)
 print("known for?",2,22,6)
 for i=0,2 do
  local c=5
  if i==sel then c=7 end
  local m="  "
  if i==sel then m="> " end
  print(m..types[i+1],8,44+i*12,c)
 end
 print("up/down to choose, x to start",2,116,6)
end

function draw_offer()
 local o=offers[oi]
 print("week "..wk.."/"..weeks,2,2,6)
 print("cash $"..cash,70,2,11)
 print("focus: "..types[foc+1],2,10,7)
 print("known",2,20,6)
 bar(32,19,60,kk,10)
 print(f1(kk),96,20,10)
 print("energy",2,28,6)
 bar(32,27,60,hh,12)
 print(f1(hh),96,28,12)
 print("slots",2,36,6)
 bar(32,35,60,min(10,used*10/capeff()),9)
 print(used.."/"..capeff(),96,36,7)
 print("offer "..oi.."/"..#offers,2,50,5)
 print(o.n,2,60,7)
 if o.on then
  print("on your focus",2,68,11)
 else
  print("off your focus",2,68,8)
 end
 print(o.s.." slots x $"..o.r.." = $"..(o.s*o.r),2,78,10)
 print("x yes   o no   up redirect",2,116,12)
end

function draw_wrap()
 print("end of week "..wk,2,2,7)
 local c=7
 if wov>0 then c=8 end
 print("slots used "..wused.."/"..wcap,2,14,c)
 if wov>0 then print(wov.." over",2,22,8) end
 print("known for it "..f1(pk).." > "..f1(kk),2,34,10)
 print("energy "..f1(ph).." > "..f1(hh),2,42,12)
 if wov>0 then
  print("you took on too much.",2,58,6)
  print("pay clawed back, energy down.",2,66,6)
 elseif off_s>on_s then
  print("off-focus work is pulling",2,58,6)
  print("you away from your focus.",2,66,6)
 elseif cr>0 then
  print("your redirects may bring",2,58,6)
  print("good work back next week.",2,66,6)
 else
  print("a steady week.",2,58,6)
 end
 print("cash $"..cash,2,96,11)
 print("press x",2,116,10)
end

function draw_end()
 print("results",2,2,7)
 print("cash $"..cash,2,14,11)
 print("known for it "..f1(kk).."/10",2,24,10)
 print("energy "..f1(hh).."/10",2,32,12)
 print("score "..score(),2,44,7)
 if kk>=8 then
  print("people know what you are for.",2,60,6)
 elseif kk<=4 then
  print("your reputation drifted away",2,60,6)
  print("from your focus.",2,68,6)
 else
  print("you are partly known for it.",2,60,6)
 end
 print("press x",2,116,10)
end

function draw_deb()
 if pg==1 then
  print("debrief",2,2,10)
  print("1. what did we expect?",2,12,7)
  print("2. what actually happened?",2,20,7)
  print("3. why the gap?",2,28,7)
  print("4. what do we change?",2,36,7)
  print("5. what does this game get",2,44,7)
  print("   wrong about real life?",2,52,7)
  print("here the offers come from a",2,64,5)
  print("short list. real life is",2,72,5)
  print("messier, and a no can cost",2,80,5)
  print("relationships.",2,88,5)
  print("press x",2,116,10)
 else
  print("take it home",2,2,10)
  print("write down three things you",2,14,7)
  print("will say no to this month,",2,22,7)
  print("and the words you would use",2,30,7)
  print("for each one.",2,38,7)
  print("then say each one out",2,50,7)
  print("loud, once.",2,58,7)
  print("press x to play again",2,116,10)
 end
end
