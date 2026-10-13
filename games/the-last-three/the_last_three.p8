pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- the last three
-- a micro-game about the inside view
-- my strategy squad, episode 6
-- code written with claude, an ai
-- assistant, and edited and tested
-- by andrew david roberts
-- code: mit license
-- art, sound, text: cc by 4.0
-- the my strategy squad name and
-- logo are not covered

-- tuning: change these numbers
rounds=10
log_from=4
pay=130
cost=100
rlo=0.9
rhi=1.6
dis_p=0.1
dis_d=2

jobs={
 {n="tap repair",b=2,s=0.5,
  p={0.5,0.4,0.3},
  e={"seized fitting","part on back-order","second leak found"}},
 {n="water heater",b=3,s=1,
  p={0.35,0.3,0.2},
  e={"old valve seized","permit delay","wrong size sent"}},
 {n="bathroom",b=5,s=1.5,
  p={0.5,0.4,0.3},
  e={"rot behind the wall","late tiles","client changed their mind"}}
}

-- plain-english how-to-play pages
-- (keep in step with the tuning)
how_pages={
 {"the goal",{"you run a small plumbing firm","and bid for 10 jobs, one at a","time. end with as much cash","as you can.","","each job has a plan: the days","it takes if everything goes","well."}},
 {"estimate and quote",{"you give an estimate: how many","days you think it will take.","your quote is that many days","at $130 a day.","","a rival bids too. the lowest","quote wins the job. if you win,","each day it really takes costs","you $100."}},
 {"inside and outside",{"jobs 1-3: you only have your","own plan. that's the inside","view: the job as you see it.","","from job 4 you also see the","last three jobs in town: what","was planned, and what it took.","that's the outside view."}},
 {"controls",{"left/right: change your","estimate by half a day.","up/down: by a whole day.","x: send your quote.","","profit = your quote, minus","$100 for each day the job","really took."}},
}

function r5(x)
 return flr(x*2+0.5)/2
end

function pc(x)
 local v=flr((x-1)*100+0.5)
 if v>=0 then return "+"..v.."%" end
 return v.."%"
end

function money(v)
 if v<0 then return "-$"..(-v) end
 return "$"..v
end

function _init()
 scr="title"
end

function start_game()
 rd=0
 cash=0
 nwin=0
 hist={}
 qs={}
 ps={}
 new_round()
end

function new_round()
 rd+=1
 job=jobs[1+flr(rnd(#jobs))]
 plan=job.b
 riv=plan*(rlo+rnd(rhi-rlo))
 extra=0
 evs={}
 for i=1,3 do
  if rnd(1)<job.p[i] then
   extra+=job.s
   add(evs,job.e[i])
  end
 end
 if rnd(1)<dis_p then
  extra+=dis_d
  add(evs,"everything went wrong")
 end
 actual=plan+extra
 q=plan
 scr="quote"
end

function send_quote()
 add(qs,q)
 add(ps,plan)
 won=(q<=riv)
 profit=0
 if won then
  profit=pay*q-cost*actual
  cash+=profit
  nwin+=1
 end
 add(hist,{plan,actual})
 scr="result"
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
   if hpg<#how_pages then hpg+=1 else start_game() end
  end
 elseif scr=="quote" then
  -- left/right: half a day
  -- up/down: a whole day
  if btnp(0) then q-=0.5 end
  if btnp(1) then q+=0.5 end
  if btnp(2) then q+=1 end
  if btnp(3) then q-=1 end
  q=mid(0.5,q,20)
  if btnp(5) then send_quote() end
 elseif scr=="result" then
  if btnp(5) then
   if rd>=rounds then
    scr="sum"
   else
    new_round()
   end
  end
 elseif scr=="sum" then
  if btnp(5) then scr="deb" end
 elseif scr=="deb" then
  if btnp(5) then scr="title" end
 end
end

function _draw()
 cls(1)
 if scr=="title" then
  draw_title()
 elseif scr=="how" then
  draw_how()
 elseif scr=="quote" then
  draw_quote()
 elseif scr=="result" then
  draw_result()
 elseif scr=="sum" then
  draw_sum()
 else
  draw_deb()
 end
end

function draw_title()
 print("the last three",34,28,7)
 print("a game about",38,42,6)
 print("the inside view",32,50,6)
 print("estimate jobs in days.",16,68,5)
 print("lowest quote wins.",24,76,5)
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

function draw_quote()
 print("job "..rd.."/"..rounds,2,2,6)
 print("cash "..money(cash),70,2,11)
 print(job.n,2,14,7)
 print("if all goes well: "..plan.." days",2,22,6)
 print("lowest quote wins the job.",2,30,5)
 if rd>=log_from then
  print("the last three jobs in town:",2,42,12)
  local n=#hist
  local sp=0
  local sa=0
  for i=n-2,n do
   local h=hist[i]
   sp+=h[1]
   sa+=h[2]
   print("plan "..h[1].." took "..h[2].." "..pc(h[2]/h[1]),2,50+(i-n+2)*8,7)
  end
  print("together: "..pc(sa/sp),2,76,10)
 else
  print("no record yet.",2,46,5)
  print("you only have your plan.",2,54,5)
 end
 print("your estimate: "..q.." days",2,88,7)
 print("your quote: $"..(pay*q),2,96,10)
 print("l/r: half day  u/d: 1 day",2,110,6)
 print("x: send quote",2,118,6)
end

function draw_result()
 print("job "..rd.."/"..rounds..": "..job.n,2,2,7)
 if won then
  print("you won the job.",2,14,11)
 else
  print("a rival took it.",2,14,8)
 end
 print("plan: "..plan.." days",2,26,6)
 print("your estimate: "..q.." days ($"..(pay*q)..")",2,34,6)
 print("rival's quote: $"..flr(riv*pay),2,42,6)
 print("it took: "..actual.." days",2,50,10)
 if #evs==0 then
  print("- nothing went wrong",2,60,5)
 end
 for i=1,#evs do
  print("- "..evs[i],2,53+i*7,5)
 end
 if won then
  local c=11
  if profit<0 then c=8 end
  print("profit: "..money(profit),2,96,c)
 else
  print("no profit, no loss.",2,96,6)
 end
 print("cash "..money(cash),2,106,7)
 print("press x",2,118,6)
end

function draw_sum()
 local tp=0
 local ta=0
 for h in all(hist) do
  tp+=h[1]
  ta+=h[2]
 end
 local eq=0
 local ep=0
 local lq=0
 local lp=0
 for i=1,#qs do
  if i<log_from then
   eq+=qs[i]
   ep+=ps[i]
  else
   lq+=qs[i]
   lp+=ps[i]
  end
 end
 print("results",2,2,7)
 print("cash "..money(cash),2,14,11)
 print("jobs won "..nwin.."/"..rounds,2,22,6)
 print("jobs ran "..pc(ta/tp).." over plan",2,34,10)
 print("jobs 1-"..(log_from-1).." you estimated "..pc(eq/ep),2,46,6)
 print("jobs "..log_from.."-"..rounds.." you estimated "..pc(lq/lp),2,54,6)
 if lq/lp-eq/ep>=0.1 then
  print("the log moved your estimates.",2,70,12)
 else
  print("your estimates barely moved.",2,70,12)
  print("did you read the last three?",2,78,12)
 end
 print("press x",2,118,6)
end

function draw_deb()
 print("debrief",2,2,7)
 print("1. what did we expect?",2,12,6)
 print("2. what actually happened?",2,20,6)
 print("3. why the gap?",2,28,6)
 print("4. what do we change?",2,36,6)
 print("5. what does this game get",2,44,6)
 print("   wrong about real life?",2,52,6)
 print("here the delays come from",2,64,5)
 print("a short list. real life has",2,72,5)
 print("surprises nobody listed.",2,80,5)
 print("next time, write your guess",2,94,7)
 print("down first. then write the",2,102,7)
 print("real number.",2,110,7)
 print("press x to play again",2,118,10)
end
