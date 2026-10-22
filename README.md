# My Strategy Squad: Games

**Strategizing skills, without the suits.**

Strategy isn't something you buy. It's something you do. We coach the doing.

Free micro-games about strategy, for people who run small businesses and work in
nonprofits. Each game takes about five minutes, teaches one idea from the
My Strategy Squad podcast, and ends with a short debrief.

Every game comes in two versions that use the same rules and wording:

- a **PICO-8 cart** (`.p8`), for the PICO-8 fantasy console
- a **browser version** (`index.html`), a single file that runs in any browser,
  on a phone or a computer, with nothing to install

## The games

| Game | The idea | Podcast episode |
| --- | --- | --- |
| [Yes Machine](games/yes-machine/) | Every yes pushes something out. Focus means saying no. | 4: The Power of No |
| [Puzzle or Mystery?](games/puzzle-or-mystery/) | Sort a problem before you solve it. Calculate puzzles; scout mysteries. | 5: Puzzle or Mystery? |
| [The Last Three](games/the-last-three/) | Your plan is the inside view. The record is the outside view. | 6: The Inside View |
| [Pre-Mortem](games/pre-mortem/) | Imagine it failed, and ask why, before it does. | 7: It'll Be Different for Us |
| [The Squad](games/the-squad/) | Ask the right people before a big call, and watch their record. | 9: Before the Big Call |
| [Eight Shocks](games/eight-shocks/) | Stress-test your plan: held, bent, or broke. | 16: Stress-Test It in a Game |

The Last Three also has a Python version (`last_three.py`) with built-in tests
and a balance check.

## Play online

The games are published free with GitHub Pages. The home page (`index.html` at the top
of this repository) lists all six. The empty `.nojekyll` file tells GitHub Pages to
serve the files exactly as they are.

## Interactive stories

`stories/` holds interactive fiction written in [Twine](https://twinery.org/)'s SugarCube story format.
Each story is a plain-text Twee file (easy to read and to track in Git) plus the playable `index.html`
built from it.

- **The Size-Up** (`stories/the-size-up/`): help Marisol work out why her café's Saturday sales fell
  by a third. Practices "What's really going on?" Preview: Act 1.

To rebuild a story after editing its `.twee` file:

```
python3 stories/build.py stories/the-size-up/the-size-up.twee stories/formats/sugarcube-2.37.3/format.js stories/the-size-up/index.html
```

`stories/build.py` is a small stand-in for [Tweego](https://www.motoslave.net/tweego/); Tweego works too.
SugarCube is by Thomas Michael Edwards, under its own license (`stories/formats/sugarcube-2.37.3/LICENSE`).

## Brand styling

`assets/mss.css` holds the brand colors and fonts for every game, story and page on the site.
Change them there, once. Fonts are ITC American Typewriter from Adobe Fonts, loaded by each page.

## How to play

**In a browser:** open the game's `index.html` file. That's it.

**In PICO-8:** copy the `.p8` file into your PICO-8 carts folder, then type
`load` and the cart's name, and `run`.

## The debrief

Every game ends with the same five questions, used on the podcast and on the
Play-by-Play streams:

1. What did we expect?
2. What actually happened?
3. Why the gap?
4. What do we change?
5. What does this game get wrong about real life?

The fifth one matters. A game is a small world. Real life is bigger.

## Credits

Design: Andrew David Roberts. Code written with Claude, an AI assistant, and edited and
tested by Andrew David Roberts. Made with PICO-8 and plain HTML and JavaScript.

Ideas we build on, credited in each game: John Kay and Mervyn King
(*Radical Uncertainty*) for puzzles and mysteries, and Gary Klein for the
pre-mortem.

## License

Made in the spirit of Steven Levy's *Hackers*: free to play, study, change and
share.

- **Code:** MIT license. See [LICENSE](LICENSE).
- **Art, sound and text:** CC BY 4.0. See [LICENSE-CONTENT.md](LICENSE-CONTENT.md).
- The **My Strategy Squad name and knight logo** are not covered by either license.

## Find us

Podcast, streams and Substack: [LINKS]
