pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- puzzle or mystery?
-- a micro-game about sorting a
-- decision before solving it.
-- my strategy squad, episode 5
-- puzzles and mysteries: an idea
-- from john kay and mervyn king,
-- radical uncertainty
-- code written with claude, an ai
-- assistant, and edited and tested
-- by andrew david roberts
-- code: mit license
-- art, sound, text: cc by 4.0
-- the my strategy squad name and
-- logo are not covered

-- tuning: same numbers as the
-- browser version
rounds_n=8
scout_cost=30
m_noise=1.2
s_noise=0.1
lo=100
hi=900
stake_m=1.5

scen={
 {k="p",t="supplier contract",x1="two suppliers, fixed prices.",x2="which saves more this year?",c="terms are in the contract.",a="supplier a",b="supplier b"},
 {k="p",t="six free days",x1="two jobs, known days and pay.",x2="which one fits better?",c="hours and rates are agreed.",a="job a",b="job b"},
 {k="p",t="lease or buy",x1="a new press: lease or buy?",x2="all quotes are on the table.",c="every cost is on the page.",a="lease",b="buy"},
 {k="p",t="stock order",x1="bulk order or small order?",x2="the discount table is fixed.",c="the catalog sets the price.",a="bulk",b="small"},
 {k="p",t="pay timing",x1="pay a bill now or in 30 days?",x2="the late fee is stated.",c="the rules are fixed.",a="pay now",b="pay later"},
 {k="p",t="delivery route",x1="two routes to the same client.",x2="maps and times are known.",c="distances can be measured.",a="route a",b="route b"},
 {k="m",t="a rival opens nearby",x1="will your customers stay?",x2="nobody can say for sure.",c="this has never happened.",a="cut prices",b="hold steady"},
 {k="m",t="a new funder",x1="a funder you have not met",x2="offers a grant with strings.",c="how it will go is unclear.",a="accept",b="decline"},
 {k="m",t="a new hire",x1="will this manager fit your",x2="team and way of working?",c="people are hard to predict.",a="hire now",b="wait"},
 {k="m",t="a rumored rule change",x1="a new rule may be coming.",x2="no one knows what it says.",c="the future is not written.",a="prepare now",b="wait and see"},
 {k="m",t="a second site",x1="will a second site work?",x2="you have no data yet.",c="the numbers are guesses.",a="open it",b="stay put"},
 {k="m",t="a new service",x1="will customers want it?",x2="you can only guess.",c="nobody has asked them yet.",a="launch",b="hold off"}
}

-- plain-english how-to-play pages
-- (keep in step with the tuning)
how_pages={
 {"the goal",{"8 decisions arrive, one at a","time. each has two options.","each option shows a payoff:","the money it should bring in.","","pick well and end with the","biggest total payoff."}},
 {"sort it first",{"before you choose, decide what","kind of problem it is. ask:","can i list everything that","could happen, and put sensible","odds on it?","","yes: it's a puzzle.","no: it's a mystery.","the clue in blue helps."}},
 {"puzzle or mystery",{"puzzle (press left): the","numbers are exact. you just","calculate: the game takes the","best option. free.","","mystery (press right): the","numbers are only guesses. you","scout: pay $30 for a closer","look, then choose."}},
 {"what happens",{"after each decision you see","what it really was, the real","payoffs, and what you missed.","","sort wrongly and you either","pay to scout for nothing, or","trust guesses that mislead you.","","4 puzzles, 4 mysteries, mixed."}},
}

function r10(x)
 return flr(x/10+0.5)*10
end

function shuf(t)
 for i=#t,2,-1 do
  local j=1+flr(rnd(i))
  t[i],t[j]=t[j],t[i]
 end
end

function kind_name(k)
 if k=="p" then return "puzzle" end
 return "mystery"
end

function _init()
 scr="title"
end

function new_game()
 local ps={}
 local ms={}
 for s in all(scen) do
  if s.k=="p" then
   add(ps,s)
  else
   add(ms,s)
  end
 end
 shuf(ps)
 shuf(ms)
 local order={}
 for i=1,4 do
  add(order,ps[i])
  add(order,ms[i])
 end
 shuf(order)
 rounds={}
 for s in all(order) do
  add(rounds,make_round(s))
 end
 ri=1
 total=0
 best_total=0
 nright=0
 scr="round"
end

function make_round(s)
 local k=1
 if s.k=="m" then k=stake_m end
 local va=r10((lo+rnd(hi-lo))*k)
 local vb=r10((lo+rnd(hi-lo))*k)
 local sa=va
 local sb=vb
 if s.k=="m" then
  sa=max(10,r10(va*(1+(rnd(2)-1)*m_noise)))
  sb=max(10,r10(vb*(1+(rnd(2)-1)*m_noise)))
 end
 return {s=s,va=va,vb=vb,sa=sa,sb=sb}
end

function sort_it(srt)
 local r=rounds[ri]
 local cost=0
 local ea=r.sa
 local eb=r.sb
 if srt=="m" then
  cost=scout_cost
 end
 -- scouting a puzzle only confirms
 -- the exact numbers
 if srt=="m" and r.s.k=="m" then
  ea=r.va*(1+(rnd(2)-1)*s_noise)
  eb=r.vb*(1+(rnd(2)-1)*s_noise)
 end
 local pick="a"
 local val=r.va
 if eb>ea then
  pick="b"
  val=r.vb
 end
 local best=max(r.va,r.vb)
 local right=(srt==r.s.k)
 res={sort=srt,right=right,pick=pick,cost=cost,payoff=val-cost,best=best}
 total+=res.payoff
 best_total+=best
 if right then nright+=1 end
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
   if hpg<#how_pages then hpg+=1 else new_game() end
  end
 elseif scr=="round" then
  if btnp(0) then sort_it("p")
  elseif btnp(1) then sort_it("m")
  end
 elseif scr=="result" then
  if btnp(5) then
   ri+=1
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
 print("puzzle or mystery?",28,30,7)
 print("a game about sorting a",18,44,6)
 print("decision before you solve it",8,52,6)
 print("idea: kay and king,",26,72,5)
 print("radical uncertainty",26,80,5)
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

function draw_round()
 local r=rounds[ri]
 local s=r.s
 print("decision "..ri.."/"..rounds_n,2,2,6)
 print("score $"..total,76,2,11)
 print(s.t,2,14,7)
 print(s.x1,2,24,6)
 print(s.x2,2,32,6)
 print(s.c,2,44,12)
 print(s.a.."  $"..r.sa,2,58,10)
 print(s.b.."  $"..r.sb,2,66,10)
 print("left: puzzle   right: mystery",2,84,7)
 print("can i list everything that",2,100,5)
 print("could happen, with odds?",2,108,5)
end

function draw_result()
 local r=rounds[ri]
 local s=r.s
 local lab=s.a
 if res.pick=="b" then lab=s.b end
 print(s.t,2,2,7)
 print("it was a "..kind_name(s.k),2,12,12)
 local c=8
 local w="wrong"
 if res.right then
  c=11
  w="right"
 end
 print("you called it a "..kind_name(res.sort),2,22,6)
 print(w,2,30,c)
 if res.sort=="p" then
  print("you calculated.",2,42,7)
 else
  print("you scouted (-$"..scout_cost..").",2,42,7)
 end
 print("you chose "..lab,2,50,7)
 print("actual: $"..r.va.." / $"..r.vb,2,60,6)
 print("payoff $"..res.payoff,2,72,10)
 print("(best possible $"..res.best..")",2,80,5)
 local got=(res.payoff+res.cost==res.best)
 if s.k=="p" and res.sort=="p" then
  print("the numbers were exact.",2,92,12)
  print("calculating was the right call.",2,100,12)
 elseif s.k=="p" then
  print("the numbers were exact.",2,92,12)
  print("scouting cost $"..scout_cost.." for nothing.",2,100,12)
 elseif res.sort=="m" and got then
  print("the numbers were only guesses.",2,92,12)
  print("scouting was the right call.",2,100,12)
 elseif res.sort=="m" then
  print("right call, but scouting only",2,92,12)
  print("shrinks a mystery.",2,100,12)
 elseif got then
  print("you got lucky. the numbers",2,92,12)
  print("were only guesses.",2,100,12)
 else
  print("the numbers were only guesses,",2,92,12)
  print("and they misled you.",2,100,12)
 end
 print("press x",2,116,10)
end

function draw_end()
 print("results",2,2,7)
 print("total payoff $"..total,2,14,10)
 print("best possible $"..best_total,2,22,6)
 print("left on the table $"..(best_total-total),2,30,8)
 print("sorted right "..nright.."/"..rounds_n,2,44,11)
 if nright>=7 then
  print("you read the cues well.",2,60,12)
 elseif nright>=5 then
  print("you read most of the cues.",2,60,12)
 else
  print("the cues are easy to miss.",2,60,12)
  print("that is the point.",2,68,12)
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
  print("in the game, a small fee",2,66,5)
  print("reveals a lot. in real life,",2,74,5)
  print("scouting only shrinks a",2,82,5)
  print("mystery, and some never",2,90,5)
  print("clear up.",2,98,5)
  print("press x",2,116,10)
 else
  print("take it home",2,2,10)
  print("sort five real decisions this",2,14,7)
  print("month: puzzle or mystery.",2,22,7)
  print("for each mystery, name one",2,30,7)
  print("cheap thing to learn first.",2,38,7)
  print("one more: what would you do",2,56,6)
  print("in a mystery you could not",2,64,6)
  print("pay to scout?",2,72,6)
  print("press x to play again",2,116,10)
 end
end
