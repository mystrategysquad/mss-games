#!/usr/bin/env python3
"""
THE LAST THREE
A micro-game about the inside view and the planning fallacy.
My Strategy Squad, Episode 6 ("The Inside View"). Play-by-Play tie-in.

You run a small outfit. For each job you give an estimate in days; your quote
is that many days at $130 a day. The lowest quote wins the job.
Jobs 1-3: you only have your own plan (the inside view).
Jobs 4-10: you can see the last three jobs in town, plan versus what really
happened (the outside view).

How to run:
    python3 last_three.py              play the game
    python3 last_three.py --seed 42    repeatable run
    python3 last_three.py --selftest   run the built-in tests
    python3 last_three.py --sim        balance check: naive vs log-informed quoting

Tuning lives in the constants below. The PICO-8 cart (the_last_three.p8) and the
browser version (the-last-three.html) use the same numbers and the same wording.

Code written with Claude, an AI assistant, and edited and tested by [YOUR NAME].
Code: MIT license. Art, sound and text: CC BY 4.0.
The My Strategy Squad name and logo are not covered by these licenses.
"""
import argparse
import math
import random
import statistics as st

# ---------- tuning ----------
ROUNDS = 10
LOG_FROM = 4            # the "last three" log appears from this round
PAY = 130               # paid per quoted day
COST = 100              # cost per day actually worked
RIVAL_LO, RIVAL_HI = 0.9, 1.6   # rival quote as a multiple of plan (hidden)
DISASTER_P, DISASTER_DAYS = 0.10, 2.0

JOBS = [
    dict(name="tap repair", base=2.0, size=0.5, p=[0.5, 0.4, 0.3],
         events=["seized fitting", "part on back-order", "second leak found"]),
    dict(name="water heater", base=3.0, size=1.0, p=[0.35, 0.3, 0.2],
         events=["old valve seized", "permit delay", "wrong size sent"]),
    dict(name="bathroom", base=5.0, size=1.5, p=[0.5, 0.4, 0.3],
         events=["rot behind the wall", "late tiles", "client changed their mind"]),
]

# ---------- helpers ----------
def r5(x):
    """Round to the nearest half day."""
    return math.floor(x * 2 + 0.5) / 2


def days(x):
    return f"{x:g}"


def money(v):
    """-210 -> '-$210'."""
    return f"-${abs(v):g}" if v < 0 else f"${v:g}"


def pct(ratio):
    """1.38 -> '+38%'."""
    return f"{math.floor((ratio - 1) * 100 + 0.5):+d}%"


def new_job(rng):
    job = rng.choice(JOBS)
    plan = job["base"]
    rival = plan * (RIVAL_LO + rng.random() * (RIVAL_HI - RIVAL_LO))
    extra = 0.0
    events = []
    for p, ev in zip(job["p"], job["events"]):
        if rng.random() < p:
            extra += job["size"]
            events.append(ev)
    if rng.random() < DISASTER_P:
        extra += DISASTER_DAYS
        events.append("everything went wrong")
    return dict(job=job, plan=plan, rival=rival, actual=plan + extra, events=events)


def settle(j, quote):
    """Lowest quote wins; ties go to you. Profit only if you win the job."""
    won = quote <= j["rival"]
    profit = PAY * quote - COST * j["actual"] if won else 0
    return won, profit


def clamp_quote(x):
    return min(20.0, max(0.5, r5(x)))


# ---------- the game ----------
TITLE = """
==============================
  THE LAST THREE
  a game about the inside view
==============================
Each job has a plan: the days it takes if everything goes well.
You give an estimate in days. Your quote is that many days at $130 a day.
The lowest quote wins the job.
If you win, every day the job really takes costs you $100.
Jobs 1 to 3: you only have your plan. From job 4, you see the last three jobs in town.
"""

DEBRIEF = """
DEBRIEF
 1. What did we expect?
 2. What actually happened?
 3. Why the gap?
 4. What do we change?
 5. What does this game get wrong about real life?

In this game the delays come from a short list.
Real life has surprises nobody listed.

Next time you estimate something, write your guess down first.
Then write the real number.
"""


def play(rng, ask=input, say=print):
    hist, qs, ps = [], [], []
    cash = 0.0
    wins = 0
    say(TITLE)
    for rd in range(1, ROUNDS + 1):
        j = new_job(rng)
        job = j["job"]
        say(f"--- Job {rd}/{ROUNDS}: {job['name']}   (cash {money(cash)}) ---")
        say(f"If all goes well: {days(j['plan'])} days.")
        if rd >= LOG_FROM:
            say("The last three jobs in town:")
            last = hist[-3:]
            for plan, actual in last:
                say(f"   plan {days(plan)}, took {days(actual)}  ({pct(actual / plan)})")
            say(f"   together: {pct(sum(a for _, a in last) / sum(p for p, _ in last))}")
        else:
            say("No record yet. You only have your own plan.")
        say(f"You charge {money(PAY)} a day. The lowest quote wins.")
        raw = ask(f"Your estimate in days [{days(j['plan'])}]: ").strip()
        try:
            est = clamp_quote(float(raw)) if raw else clamp_quote(j["plan"])
        except ValueError:
            est = clamp_quote(j["plan"])
        say(f"Your quote: {money(PAY * est)}")
        won, profit = settle(j, est)
        qs.append(est)
        ps.append(j["plan"])
        hist.append((j["plan"], j["actual"]))
        if won:
            wins += 1
            cash += profit
            say("You won the job.")
        else:
            say("A rival took it.")
        say(f"Plan: {days(j['plan'])} days   Your estimate: {days(est)} days (quote {money(PAY * est)})")
        say(f"Rival's quote: {money(math.floor(j['rival'] * PAY))}   It took: {days(j['actual'])} days")
        for ev in j["events"] or ["nothing went wrong"]:
            say(f"   - {ev}")
        say(f"Profit: {money(profit)}" if won else "No profit, no loss.")
        say("")

    tp = sum(p for p, _ in hist)
    ta = sum(a for _, a in hist)
    early = sum(qs[: LOG_FROM - 1]) / sum(ps[: LOG_FROM - 1])
    late = sum(qs[LOG_FROM - 1:]) / sum(ps[LOG_FROM - 1:])
    say("=== RESULTS ===")
    say(f"Cash: {money(cash)}   Jobs won: {wins}/{ROUNDS}")
    say(f"Jobs ran {pct(ta / tp)} over plan on average.")
    say(f"Jobs 1-{LOG_FROM - 1}: you estimated {pct(early)} versus plan.")
    say(f"Jobs {LOG_FROM}-{ROUNDS}: you estimated {pct(late)} versus plan.")
    if late - early >= 0.10:
        say("The log moved your estimates.")
    else:
        say("Your estimates barely moved. Did you read the last three?")
    say(DEBRIEF)
    return dict(cash=cash, wins=wins, overrun=ta / tp, early=early, late=late)


# ---------- tests and balance check ----------
def selftest():
    assert r5(2.24) == 2.0 and r5(2.26) == 2.5 and r5(2.75) == 3.0
    assert pct(1.38) == "+38%" and pct(0.9) == "-10%"
    assert money(-210) == "-$210" and money(45) == "$45"
    j = dict(job=JOBS[0], plan=2.0, rival=2.5, actual=3.0, events=[])
    assert settle(j, 2.0) == (True, PAY * 2.0 - COST * 3.0)   # won, loses money
    assert settle(j, 2.5)[0] is True                          # ties go to you
    assert settle(j, 3.0) == (False, 0)                       # lost the job
    rng = random.Random(1)
    for _ in range(1000):
        x = new_job(rng)
        assert x["actual"] >= x["plan"]
        assert RIVAL_LO * x["plan"] <= x["rival"] <= RIVAL_HI * x["plan"]
    # the log must be hidden before round LOG_FROM and shown from then on
    out = []
    play(random.Random(5), ask=lambda prompt: "", say=out.append)
    text = "\n".join(map(str, out))
    assert text.count("The last three jobs in town") == ROUNDS - LOG_FROM + 1
    assert text.count("No record yet") == LOG_FROM - 1
    assert "DEBRIEF" in text
    assert "What did we expect?" in text and "write your guess down first" in text
    assert "Rival's quote" in text and "Your estimate" in text
    assert "you quoted" not in text
    # the displayed (rounded-down) rival quote must agree with who won
    rng = random.Random(9)
    for _ in range(5000):
        x = new_job(rng)
        for est in [r5(x["plan"] * k) for k in (0.8, 1.0, 1.2, 1.4, 1.6)]:
            won, _ = settle(x, est)
            shown = math.floor(x["rival"] * PAY)
            assert (PAY * est <= shown) == won
    # bad input falls back to the plan
    out = []
    res = play(random.Random(5), ask=lambda prompt: "abc", say=out.append)
    assert res["early"] == 1.0
    print("selftest ok")


def simulate(n=20000, seed=3):
    def naive(rd, hist):
        return 1.0

    def informed(rd, hist):
        if rd < LOG_FROM:
            return 1.0
        last = hist[-3:]
        return sum(a for _, a in last) / sum(p for p, _ in last)

    print(f"{n} games per policy (rounds 1-{LOG_FROM - 1} are the same for both)")
    for name, pol in [("quote the plan", naive), ("quote the log", informed)]:
        rng = random.Random(seed)
        early, late, wins_late, overs = [], [], [], []
        for _ in range(n):
            hist, e, l, w = [], 0.0, 0.0, 0
            for rd in range(1, ROUNDS + 1):
                j = new_job(rng)
                q = clamp_quote(j["plan"] * pol(rd, hist))
                won, profit = settle(j, q)
                if rd < LOG_FROM:
                    e += profit
                else:
                    l += profit
                    w += won
                hist.append((j["plan"], j["actual"]))
                overs.append(j["actual"] / j["plan"] - 1)
            early.append(e)
            late.append(l)
            wins_late.append(w)
        print(f"  {name:15s} rounds {LOG_FROM}-{ROUNDS}: mean profit {st.mean(late):7.1f}, "
              f"chance of a loss {sum(1 for x in late if x < 0) / n:.2f}, "
              f"jobs won {st.mean(wins_late):.1f}/{ROUNDS - LOG_FROM + 1}, "
              f"average overrun {st.mean(overs) * 100:.0f}%")


if __name__ == "__main__":
    ap = argparse.ArgumentParser(description="The Last Three: a game about the inside view")
    ap.add_argument("--seed", type=int, default=None)
    ap.add_argument("--selftest", action="store_true")
    ap.add_argument("--sim", action="store_true")
    a = ap.parse_args()
    if a.selftest:
        selftest()
    elif a.sim:
        simulate()
    else:
        play(random.Random(a.seed))
