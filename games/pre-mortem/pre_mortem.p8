pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- pre-mortem
-- a micro-game about imagining
-- failure before it happens.
-- my strategy squad, episode 7
-- the pre-mortem is gary klein's
-- technique
-- code written with claude, an ai
-- assistant, and edited and tested
-- by [your name]
-- code: mit license
-- art, sound, text: cc by 4.0
-- the my strategy squad name and
-- logo are not covered

-- tuning: same numbers as the
-- browser version
weeks_n=8
start=100
fcast=20
inc=14
inc_sd=6
ramp=1
delay=14
prep_c=14
-- prepared risks keep 30% of damage
-- (whole numbers, to match the
-- browser rounding exactly)
keep_pct=30
sp_below=40
sp_cost=15
pause_c=15
live_n=5
obv_n=2

names={"a key person leaves","cash runs short","customers don't come","a supplier lets you down","a rule changes","a rival copies you","a bad review spreads","you burn out"}
short={"key person","cash","customers","supplier","rule change","rival","review","burnout"}
szname={"small","medium","large"}
costs={25,40,60}
trips={0,70,50,30}

function shuf(t)
 for i=#t,2,-1 do
  local j=1+flr(rnd(i))
  t[i],t[j]=t[j],t[i]
 end
end

function gauss()
 local u=0
 for i=1,6 do
  u+=rnd(1)
 end
 return (u-3)*1.4142
end

function money(v)
 if v<0 then return "-$"..(-v) end
 return "$"..v
end

function trip_ok(t)
 return t==0 or t<cash_after()
end

function forecast()
 return start+fcast*weeks_n
end

function _init()
 scr="title"
 sel=1
 pg=1
end

function new_game()
 local ids={1,2,3,4,5,6,7,8}
 shuf(ids)
 rk={}
 for i=1,live_n do
  local r=rnd(1)
  local sz=1
  if r>=0.3 then sz=2 end
  if r>=0.7 then sz=3 end
  add(rk,{id=ids[i],sz=sz,cost=costs[sz],week=2+flr(rnd(7)),obv=false,prep=false,hit=false,dmg=0})
 end
 local ix={1,2,3,4,5}
 shuf(ix)
 for i=1,obv_n do
  rk[ix[i]].obv=true
 end
 incs={}
 for w=1,weeks_n do
  add(incs,max(0,flr(inc+gauss()*inc_sd+0.5)))
 end
 pm=false
 trip=0
 sel=1
 scr="brief"
end

function make_vis()
 vis={}
 for i=1,#rk do
  if pm or rk[i].obv then add(vis,i) end
 end
end

function cash_after()
 local c=start
 if pm then c-=delay end
 for i in all(vis) do
  if rk[i].prep then c-=prep_c end
 end
 return c
end

function run_it()
 cash=cash_after()
 for r in all(rk) do
  r.hit=false
  r.dmg=0
 end
 log={}
 stopped=false
 stop_w=0
 for w=1,weeks_n do
  local ic=incs[w]+flr(ramp*(w-1)+0.5)
  local dmg=0
  local nh=0
  local txt=""
  for r in all(rk) do
   if r.week==w then
    local d=r.cost
    if r.prep then d=flr(r.cost*keep_pct/100+0.5) end
    r.hit=true
    r.dmg=d
    dmg+=d
    nh+=1
    if nh==1 then
     txt="-"..d.." "..short[r.id]
     if r.prep then txt=txt.."*" end
    else
     txt=nh.." hits -"..dmg
    end
   end
  end
  cash+=ic-dmg
  if cash<sp_below then cash-=sp_cost end
  local tr=false
  if trip>0 and cash<=trip then
   tr=true
   cash-=pause_c
   if txt=="" then txt="tripwire!" end
  end
  add(log,{w=w,ic=ic,txt=txt,cash=cash,tr=tr})
  if tr then
   stopped=true
   stop_w=w
   break
  end
 end
end

function _update()
 if scr=="title" then
  if btnp(5) then scr="how" end
 elseif scr=="how" then
  if btnp(5) then new_game() end
 elseif scr=="brief" then
  if btnp(2) or btnp(3) then sel=3-sel end
  if btnp(5) then
   pm=(sel==2)
   make_vis()
   sel=1
   scr="risks"
  end
 elseif scr=="risks" then
  if btnp(2) then sel=(sel+#vis-2)%#vis+1 end
  if btnp(3) then sel=sel%#vis+1 end
  if btnp(5) then
   local r=rk[vis[sel]]
   r.prep=not r.prep
  end
  if btnp(4) then
   sel=1
   scr="trip"
  end
 elseif scr=="trip" then
  if btnp(2) then sel=(sel+2)%4+1 end
  if btnp(3) then sel=sel%4+1 end
  if btnp(5) and trip_ok(trips[sel]) then
   trip=trips[sel]
   run_it()
   scr="run"
  end
 elseif scr=="run" then
  if btnp(5) then scr="res" end
 elseif scr=="res" then
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
 elseif scr=="brief" then
  draw_brief()
 elseif scr=="risks" then
  draw_risks()
 elseif scr=="trip" then
  draw_trip()
 elseif scr=="run" then
  draw_run()
 elseif scr=="res" then
  draw_res()
 else
  draw_deb()
 end
end

function draw_title()
 print("pre-mortem",44,30,7)
 print("a game about imagining",20,44,6)
 print("failure before it happens",16,52,6)
 print("the pre-mortem is",30,72,5)
 print("gary klein's technique",20,80,5)
 print("press x",48,100,10)
end

function draw_how()
 print("how to play",2,2,10)
 print("you have $"..start.." and "..weeks_n.." weeks.",2,12,7)
 print("the forecast says $"..forecast()..".",2,20,7)
 print(live_n.." risks hide in your plan.",2,32,7)
 print("launch now: see only "..obv_n..".",2,40,12)
 print("pre-mortem: imagine it failed",2,48,12)
 print("and see all "..live_n..". costs $"..delay..".",2,56,12)
 print("preparing costs $"..prep_c..", cuts",2,68,7)
 print("a risk's damage by 70%.",2,76,7)
 print("set a tripwire: stop and",2,88,7)
 print("rethink if cash falls too low.",2,96,7)
 print("below $"..sp_below..", debts spiral.",2,104,7)
 print("press x",2,116,10)
end

function draw_brief()
 print("your plan",2,2,10)
 print("launch a new service.",2,14,7)
 print("cash $"..start..", "..weeks_n.." weeks.",2,22,7)
 print("the forecast says $"..forecast()..".",2,30,10)
 print("everyone feels good about it.",2,38,6)
 print("what do you do first?",2,56,6)
 local c1=5
 local c2=5
 local m1=" "
 local m2=" "
 if sel==1 then
  c1=7
  m1=">"
 else
  c2=7
  m2=">"
 end
 print(m1.." launch now",8,72,c1)
 print(m2.." pre-mortem (-$"..delay..")",8,84,c2)
 print("up/down, then x",2,116,12)
end

function draw_risks()
 if pm then
  print("a year on. it failed. why?",2,2,10)
 else
  print("the risks you can see",2,2,10)
 end
 local ca=cash_after()
 local cc=7
 if ca<sp_below then cc=8 end
 print("cash after preparing: $"..ca,2,10,cc)
 for k=1,#vis do
  local r=rk[vis[k]]
  local y=22+(k-1)*17
  local c=5
  if k==sel then c=7 end
  local mk="[ ]"
  if r.prep then mk="[x]" end
  print(mk.." "..names[r.id],2,y,c)
  print(szname[r.sz].." $"..r.cost..", around week "..r.week,18,y+7,6)
 end
 print("up/down  x: prepare  o: go",2,116,12)
end

function draw_trip()
 print("set your tripwire",2,2,10)
 print("stop and rethink if cash",2,14,7)
 print("falls to this level. costs $"..pause_c..".",2,22,7)
 for k=1,4 do
  local c=5
  if k==sel then c=7 end
  local m=" "
  if k==sel then m=">" end
  local t="no tripwire"
  if trips[k]>0 then t="stop at $"..trips[k] end
  if not trip_ok(trips[k]) then
   t=t.." - too high"
   c=2
   if k==sel then c=13 end
  end
  print(m.." "..t,8,40+(k-1)*12,c)
 end
 print("you start with "..money(cash_after())..".",2,94,6)
 print("a tripwire must sit below it.",2,102,6)
 print("x: choose",2,116,12)
end

function draw_run()
 print("the launch",2,2,10)
 for i=1,#log do
  local l=log[i]
  local y=12+(i-1)*9
  print("w"..l.w,2,y,6)
  print("+"..l.ic,16,y,11)
  local tc=8
  if l.txt=="" then tc=5 end
  if l.tr then tc=12 end
  local t=l.txt
  if t=="" then t="-" end
  print(t,36,y,tc)
  local cc=7
  if l.cash<sp_below then cc=8 end
  print(money(l.cash),100,y,cc)
 end
 if stopped then
  print("tripwire fired in week "..stop_w.." (-$"..pause_c..")",2,88,12)
 end
 print("* prepared  red: under $"..sp_below,2,100,5)
 print("press x",2,116,10)
end

function status(r)
 local seen=pm or r.obv
 if not seen then
  if r.hit then return "not seen, hit" end
  return "not seen"
 end
 if r.hit then
  if r.prep then return "prepared, hit" end
  return "unprepared, hit"
 end
 if stopped and r.week>stop_w then return "stopped first" end
 return "seen"
end

function draw_res()
 print("results",2,2,7)
 print("forecast $"..forecast(),2,12,10)
 local c=11
 if cash<0 then c=8 end
 print("you ended with "..money(cash),2,20,c)
 if stopped then
  print("tripwire stopped it, week "..stop_w..".",2,30,12)
 else
  print("you saw it through.",2,30,12)
 end
 print("what was hiding:",2,44,6)
 for i=1,#rk do
  local r=rk[i]
  print(short[r.id]..": "..status(r),2,52+(i-1)*8,7)
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
  print("here the risks come from a",2,66,5)
  print("short list of eight, and",2,74,5)
  print("imagining failure shows them",2,82,5)
  print("all. in real life, a pre-mortem",2,90,5)
  print("surfaces more, not everything.",2,98,5)
  print("press x",2,116,10)
 else
  print("take it home",2,2,10)
  print("pick your next big commitment.",2,14,7)
  print("imagine it failed a year on.",2,22,7)
  print("write five reasons. prepare",2,30,7)
  print("for the biggest. then write",2,38,7)
  print("one tripwire: a number, a",2,46,7)
  print("date, and what you'll do.",2,54,7)
  print("one more: did your tripwire",2,70,6)
  print("help, or stop you too early?",2,78,6)
  print("press x to play again",2,116,10)
 end
end
