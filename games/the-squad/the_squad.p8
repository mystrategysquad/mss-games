pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- the squad
-- a micro-game about asking the
-- right people before a big call.
-- my strategy squad, episode 9:
-- before the big call
-- code written with claude, an ai
-- assistant, and edited and tested
-- by [your name]
-- code: mit license
-- art, sound, text: cc by 4.0
-- the my strategy squad name and
-- logo are not covered

-- tuning: same numbers as the
-- browser version
rounds_n=8
favors0=10
per_dec=2
p_go_good=0.8
p_go_bad=0.6
pay_gg=100
pay_gn=-30
pay_bg=-100
pay_bn=20

advs={
 {n="pat",r="always upbeat"},
 {n="dee",r="always careful"},
 {n="clive",r="blunt and fair"},
 {n="lee",r="the accountant"}
}

decs={
 {"take a bank loan","money"},
 {"buy the bigger press","money"},
 {"raise your prices","money"},
 {"pay for a big ad push","money"},
 {"hire a manager","people"},
 {"promote your best worker","people"},
 {"bring on a partner","people"},
 {"let a difficult client go","people"},
 {"open a second site","market"},
 {"launch a new service","market"},
 {"enter a new town","market"},
 {"sign the long lease","rules"},
 {"take the grant with strings","rules"},
 {"change your legal setup","rules"}
}

function shuf(t)
 for i=#t,2,-1 do
  local j=1+flr(rnd(i))
  t[i],t[j]=t[j],t[i]
 end
end

function say(a,good,topic)
 if a==1 then return rnd(1)<0.9 end
 if a==2 then return rnd(1)<0.2 end
 if a==3 then
  if rnd(1)<0.8 then return good end
  return not good
 end
 local acc=0.55
 if topic=="money" then acc=0.9 end
 if rnd(1)<acc then return good end
 return not good
end

function money(v)
 if v<0 then return "-$"..(-v) end
 return "$"..v
end

function sgn(v)
 if v<0 then return "-$"..(-v) end
 return "+$"..v
end

function word(v)
 if v then return "go" end
 return "no"
end

function _init()
 scr="title"
 sel=1
 pg=1
end

function new_game()
 local idx={}
 for i=1,#decs do
  add(idx,i)
 end
 shuf(idx)
 rounds={}
 for k=1,rounds_n do
  local d=decs[idx[k]]
  local good=rnd(1)<0.5
  local p=p_go_bad
  if good then p=p_go_good end
  add(rounds,{t=d[1],topic=d[2],good=good,gut=(rnd(1)<p),asked={}})
 end
 ri=1
 favors=favors0
 nask=0
 total=0
 best_total=0
 rec_asked={0,0,0,0}
 rec_right={0,0,0,0}
 sel=1
 scr="round"
end

function ask_adv(a)
 local r=rounds[ri]
 if favors>0 and nask<per_dec and r.asked[a]==nil then
  r.asked[a]=say(a,r.good,r.topic)
  favors-=1
  nask+=1
 end
end

function decide(go)
 local r=rounds[ri]
 local pay=0
 local best=0
 if r.good then
  best=pay_gg
  if go then pay=pay_gg else pay=pay_gn end
 else
  best=pay_bn
  if go then pay=pay_bg else pay=pay_bn end
 end
 for a=1,4 do
  if r.asked[a]~=nil then
   rec_asked[a]+=1
   if r.asked[a]==r.good then rec_right[a]+=1 end
  end
 end
 total+=pay
 best_total+=best
 lastgo=go
 lastpay=pay
 lastbest=best
 scr="result"
end

function _update()
 if scr=="title" then
  if btnp(5) then scr="how" end
 elseif scr=="how" then
  if btnp(5) then new_game() end
 elseif scr=="round" then
  if btnp(2) then sel=(sel+2)%4+1 end
  if btnp(3) then sel=sel%4+1 end
  if btnp(5) then ask_adv(sel) end
  if btnp(0) then decide(false) end
  if btnp(1) then decide(true) end
 elseif scr=="result" then
  if btnp(5) then
   ri+=1
   nask=0
   sel=1
   if ri>rounds_n then
    scr="end"
   else
    scr="round"
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

function _draw()
 cls(1)
 if scr=="title" then
  draw_title()
 elseif scr=="how" then
  draw_how()
 elseif scr=="round" then
  draw_round()
 elseif scr=="result" then
  draw_result()
 elseif scr=="end" then
  draw_end()
 else
  draw_deb()
 end
end

function draw_title()
 print("the squad",46,30,7)
 print("a game about asking the",18,44,6)
 print("right people first",30,52,6)
 print("press x",48,100,10)
end

function draw_how()
 print("how to play",2,2,10)
 print("eight big decisions. each is",2,12,7)
 print("secretly a good idea or a bad.",2,20,7)
 print("your gut says go or no.",2,32,7)
 print("it leans optimistic.",2,40,7)
 print("you have "..favors0.." favors: ask up",2,52,12)
 print("to "..per_dec.." advisers per decision.",2,60,12)
 print("good idea: go "..sgn(pay_gg)..", no "..sgn(pay_gn),2,72,7)
 print("bad idea: go "..sgn(pay_bg)..", no "..sgn(pay_bn),2,80,7)
 print("left: no-go   right: go",2,88,7)
 print("watch each adviser's record.",2,96,7)
 print("press x",2,116,10)
end

function draw_round()
 local r=rounds[ri]
 print("decision "..ri.."/"..rounds_n,2,2,6)
 print("score "..money(total),76,2,11)
 print(r.t,2,12,7)
 print("topic: "..r.topic,2,20,5)
 print("your gut says: "..word(r.gut),2,30,10)
 print("favors left: "..favors,2,40,12)
 for a=1,4 do
  local y=52+(a-1)*12
  local c=5
  local m=" "
  if a==sel then
   c=7
   m=">"
  end
  print(m..advs[a].n,2,y,c)
  print(rec_right[a].."/"..rec_asked[a],40,y,6)
  if r.asked[a]~=nil then
   local col=11
   if not r.asked[a] then col=8 end
   print("says "..word(r.asked[a]),64,y,col)
  end
 end
 print(advs[sel].n..": "..advs[sel].r,2,100,6)
 print("x ask  left no  right go",2,110,12)
 print("numbers = right/asked so far",2,118,5)
end

function draw_result()
 local r=rounds[ri]
 print(r.t,2,2,7)
 local c=11
 local w="good"
 if not r.good then
  c=8
  w="bad"
 end
 print("it was a "..w.." idea.",2,14,c)
 local d="no-go"
 if lastgo then d="go" end
 print("you said "..d..".",2,24,7)
 local pc=11
 if lastpay<0 then pc=8 end
 print("payoff "..sgn(lastpay),2,36,pc)
 print("(best possible "..sgn(lastbest)..")",2,44,5)
 local y=58
 for a=1,4 do
  if r.asked[a]~=nil then
   local rt="wrong"
   local col=8
   if r.asked[a]==r.good then
    rt="right"
    col=11
   end
   print(advs[a].n.." said "..word(r.asked[a])..": "..rt,2,y,col)
   y+=8
  end
 end
 if y==58 then print("you asked no one.",2,58,5) end
 print("press x",2,116,10)
end

function draw_end()
 print("results",2,2,7)
 print("total "..money(total),2,12,10)
 print("best possible "..money(best_total),2,20,6)
 print("left on the table "..money(best_total-total),2,28,8)
 for a=1,4 do
  print(advs[a].n..": right "..rec_right[a].." of "..rec_asked[a].." asked",2,42+(a-1)*8,7)
 end
 print("who they really were:",2,76,6)
 print("pat: go 9 in 10, any truth",2,84,5)
 print("dee: no 8 in 10, any truth",2,92,5)
 print("clive: right 8 in 10",2,100,5)
 print("lee: 9 in 10 on money only",2,108,5)
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
  print("here the advisers have fixed",2,66,5)
  print("personalities and a clear",2,74,5)
  print("record. in real life, people",2,82,5)
  print("change, and their record",2,90,5)
  print("takes time to see.",2,98,5)
  print("press x",2,116,10)
 else
  print("take it home",2,2,10)
  print("pick one big call this month.",2,14,7)
  print("ask someone with nothing to",2,22,7)
  print("gain, who will disagree.",2,30,7)
  print("write down what they said.",2,38,7)
  print("one more: who would you ask",2,56,6)
  print("in real life, someone with",2,64,6)
  print("nothing to gain who will",2,72,6)
  print("disagree?",2,80,6)
  print("press x to play again",2,116,10)
 end
end
