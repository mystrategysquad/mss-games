pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- eight shocks
-- a micro-game about stress-testing
-- a plan. my strategy squad, ep 16
-- code written with claude, an ai
-- assistant, and edited and tested
-- by andrew david roberts
-- code: mit license
-- art, sound, text: cc by 4.0
-- the my strategy squad name and
-- logo are not covered
-- the five cushions are episode 14's
-- five ways to build resilience

-- tuning: same numbers as the
-- browser version
pts0=8
rounds=3
per_round=3
fix_moves=2
sev_base=10
bent_gap=3
max_lv=4

areas={"spread","slack","options","response","signals"}
helps={"don't depend on one thing","spare cash and capacity","short, reversible deals","a written response ready","early warning signs"}
shocks={
 {n="a key person leaves",d="your best worker quits.",w={2,1,0,3,0}},
 {n="customer or funder pulls out",d="a third of income, one call.",w={3,1,0,1,1}},
 {n="cash arrives late",d="a big payment is 90 days late",w={0,3,1,1,1}},
 {n="costs jump",d="main supplier raises prices.",w={2,1,3,0,0}},
 {n="the ground shifts",d="a rival or a rule changes.",w={0,0,2,1,3}},
 {n="your reputation takes a hit",d="a bad review spreads fast.",w={1,0,0,3,2}},
 {n="demand surges",d="a great story doubles demand.",w={0,2,1,3,0}},
 {n="the wildcard",d="something nobody listed.",w={1,2,2,0,1}}
}

function _init()
 scr="title"
 sel=1
end

function new_game()
 lv={0,0,0,0,0}
 pool=pts0
 moves=99
 rd=0
 ver=1
 res={}
 sel=1
 scr="alloc"
end

function draw_round()
 local ids={}
 local pool_ids={1,2,3,4,5,6,7,8}
 for i=1,per_round do
  local j=1+flr(rnd(#pool_ids))
  add(ids,pool_ids[j])
  del(pool_ids,pool_ids[j])
 end
 local seen=false
 for r in all(res) do
  if r.id==8 then seen=true end
 end
 local has=false
 for v in all(ids) do
  if v==8 then has=true end
 end
 if rd==rounds-1 and not seen and not has then
  ids[per_round]=8
 end
 rd+=1
 deck=ids
 di=1
 rres={}
 scr="shock"
end

function protection(sh)
 local p=0
 for i=1,5 do
  p+=lv[i]*sh.w[i]
 end
 return p
end

function face()
 local id=deck[di]
 local sh=shocks[id]
 local p=protection(sh)
 local ex=0
 if id==8 then ex=1 end
 local sev=sev_base+ex+flr(rnd(3))-1
 local out="broke"
 if p>=sev then
  out="held"
 elseif p>=sev-bent_gap then
  out="bent"
 end
 local best=0
 local bv=0
 for i=1,5 do
  local c=lv[i]*sh.w[i]
  if c>bv then
   bv=c
   best=i
  end
 end
 cur={id=id,p=p,sev=sev,out=out,best=best}
 add(res,cur)
 add(rres,cur)
 scr="result"
end

function pts_of(o)
 if o=="held" then return 2 end
 if o=="bent" then return 1 end
 return 0
end

function total()
 local t=0
 for r in all(res) do
  t+=pts_of(r.out)
 end
 return t
end

function ocol(o)
 if o=="held" then return 11 end
 if o=="bent" then return 10 end
 return 8
end

function _update()
 if scr=="title" then
  if btnp(5) then scr="how" end
 elseif scr=="how" then
  if btnp(5) then new_game() end
 elseif scr=="alloc" or scr=="fix" then
  if btnp(2) then sel=(sel+3)%5+1 end
  if btnp(3) then sel=sel%5+1 end
  if btnp(1) then
   if pool>0 and lv[sel]<max_lv and moves>0 then
    lv[sel]+=1
    pool-=1
    moves-=1
   end
  end
  -- in the fix step, only lift a point
  -- you still have a move to re-place
  if btnp(0) then
   if lv[sel]>0 and (scr=="alloc" or pool<moves) then
    lv[sel]-=1
    pool+=1
   end
  end
  if btnp(5) then
   if scr=="alloc" and pool==0 then
    draw_round()
   elseif scr=="fix" and pool==0 then
    draw_round()
   end
  end
 elseif scr=="shock" then
  if btnp(5) then face() end
 elseif scr=="result" then
  if btnp(5) then
   if di<#deck then
    di+=1
    scr="shock"
   elseif rd<rounds then
    scr="round"
   else
    scr="end"
   end
  end
 elseif scr=="round" then
  if btnp(5) then
   moves=fix_moves
   ver+=1
   scr="fix"
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
 elseif scr=="alloc" or scr=="fix" then
  draw_alloc()
 elseif scr=="shock" then
  draw_shock()
 elseif scr=="result" then
  draw_result()
 elseif scr=="round" then
  draw_round_sum()
 elseif scr=="end" then
  draw_end()
 else
  draw_deb()
 end
end

function draw_title()
 print("eight shocks",40,30,7)
 print("a game about",38,44,6)
 print("stress-testing your plan",16,52,6)
 print("press x",48,100,10)
end

function draw_how()
 print("how to play",2,2,10)
 print("spread 8 points across five",2,14,7)
 print("cushions. max 4 in each.",2,22,7)
 print("then shocks hit: three a round,",2,34,7)
 print("three rounds.",2,42,7)
 print("each is held, bent or broke,",2,54,7)
 print("depending on the cushions.",2,62,7)
 print("after each round, 2 moves to",2,74,7)
 print("fix your plan.",2,82,7)
 print("up/down pick, left/right change",2,96,12)
 print("press x",2,116,10)
end

function draw_alloc()
 print("plan version "..ver,2,2,10)
 if scr=="alloc" then
  print("points left: "..pool,2,12,7)
 else
  print("moves "..moves.."  points "..pool,2,12,7)
 end
 for i=1,5 do
  local y=24+(i-1)*14
  local c=5
  if i==sel then c=7 end
  local m=" "
  if i==sel then m=">" end
  print(m..areas[i],2,y,c)
  for k=1,max_lv do
   local col=5
   if k<=lv[i] then col=10 end
   rectfill(66+(k-1)*14,y,66+(k-1)*14+10,y+6,col)
  end
 end
 print(helps[sel],2,98,6)
 if scr=="alloc" and pool>0 then
  print("place all points, then x",2,116,5)
 elseif scr=="fix" and pool>0 then
  print("place the point you lifted",2,116,5)
 else
  print("x: face the shocks",2,116,12)
 end
end

function draw_shock()
 local sh=shocks[deck[di]]
 print("round "..rd.."/"..rounds,2,2,6)
 print("shock "..di.."/"..#deck,80,2,6)
 print(sh.n,2,40,8)
 print(sh.d,2,52,7)
 print("press x to face it",2,100,10)
end

function draw_result()
 local sh=shocks[cur.id]
 print(sh.n,2,2,7)
 print(cur.out,2,16,ocol(cur.out))
 print("your protection: "..cur.p,2,32,6)
 print("it needed about "..cur.sev,2,40,6)
 if cur.best>0 then
  print("helped most: "..areas[cur.best],2,56,12)
 else
  print("nothing in your plan helped.",2,56,12)
 end
 print("press x",2,116,10)
end

function draw_round_sum()
 print("round "..rd.." results",2,2,7)
 for i=1,#rres do
  local r=rres[i]
  print(shocks[r.id].n,2,16+(i-1)*16,6)
  print(r.out,10,24+(i-1)*16,ocol(r.out))
 end
 print("fix your thinnest cushion,",2,76,7)
 print("not just the last shock.",2,84,7)
 print(fix_moves.." moves.",2,92,7)
 print("press x",2,116,10)
end

function draw_end()
 local lowi=1
 for i=2,5 do
  if lv[i]<lv[lowi] then lowi=i end
 end
 print("results",2,2,7)
 print("score "..total().."/18",2,12,10)
 for i=1,#res do
  local r=res[i]
  print(shocks[r.id].n,2,24+(i-1)*8,ocol(r.out))
 end
 print("held",2,96,11)
 print("bent",30,96,10)
 print("broke",58,96,8)
 print("thinnest: "..areas[lowi],2,106,12)
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
  print("here the shocks come from a",2,72,5)
  print("list of eight. real life",2,80,5)
  print("adds ones nobody listed.",2,88,5)
  print("press x",2,116,10)
 else
  print("take it home",2,2,10)
  print("draw three shocks for your own",2,14,7)
  print("one-page plan. mark each part",2,22,7)
  print("held, bent or broke. fix the",2,30,7)
  print("top one.",2,38,7)
  print("press x to play again",2,116,10)
 end
end
