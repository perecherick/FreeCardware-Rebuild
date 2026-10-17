**Languages:** English | [Русский](README.ru.md)

# Free Cardware Rebuild

An unofficial FreeCardware mod based on the original game by LewdTheMoon, built with Godot 4.7.

## Important!

This project is still a work in progress and is currently undergoing a complete codebase rewrite. A lot of stuff is either broken, missing, or hasn't been ported yet. The game isn't ready for a proper PC or mobile release either.

This warning will be removed once everything is finished and tested.

As for the release date, even God doesn't know.

## Development Status

Here's a quick overview of the progress so far:

- [x] Migrated cards from `.tscn` scenes to `.tres` resources
- [x] All cards are functional and have been tested
- [ ] Migrate all hardware to `.tres` resources
- [x] Migrated all events to `.tres` resources
- [x] Added a logging system
- [x] Added new cards: Mark, Burst, and Execution
- [x] Added a character system and at least one new playable character
- [ ] Add minibosses and rework some existing enemies
- [ ] Migrate all enemies, their moves, and effects from `.tscn` to `.tres`
- [ ] Add full keyboard support without requiring a mouse
- [ ] Finish all translations
- [ ] Fix text overflow and make sure translations display properly
- [ ] Update the cheat menu
- [ ] Rework sex scenes and migrate their data from `.tscn` to `.tres`
- [ ] Add difficulty settings and move Endless Mode to the pre-run settings
- [ ] Add character upgrades

## About the Game

In a nutshell, Free Cardware is a card-based roguelike featuring two playable characters, each with their own starting stats, deck, and hardware.

Each character starts a run with full HP, 0 LP, a deck of 10 cards, and their own unique hardware.

One thing worth clearing up, since it seems to confuse quite a few people:

- **LP** is the player's stat.
- **PP** is the enemy's stat.

### Run Types

There are currently 3 run types:

- **Normal** - Just a regular run, nothing special.
- **Pure** - You can't play sex cards, and your damage decreases with each point of Lewdness.
- **Lewd** - You can't play cards that deal damage.

You can also choose a difficulty level before starting each run. More detailed descriptions are available in-game.

## Balance Changes

Some cards, hardware, and enemies have received balance changes, including cards like **Body Slam** and **Battle Trance**.

You'll be able to find more details about all these changes on the wiki eventually.

## Make It Your Own!

Want to mess around with the game and change things however you like? All you need to do is:

1. Download or clone this repository.
2. Install Godot 4.7 or newer and open it.
3. Import `project.godot`.
4. Good luck!

## Bugs and Suggestions

Found a bug? Feel free to open an Issue and describe it in as much detail as possible. The more information you provide, the faster I'll be able to track it down and fix it.

Attaching your `debug.log` would also help a lot, if possible. To enable log file generation, turn on debug mode in the game settings or launch the game in debug mode.

Got any ideas or complaints? Feel free to start a Discussion. I'll read every single one, I promise!

## Credits

**Original game:** Free Cardware by LewdTheMoon.

Free Cardware Rebuild is an unofficial fan-made modification. The original developer is not involved in this project.

LewdTheMoon has removed the original game from itch.io, so there's no longer an official way to download it.

## License

Some code, music, and artwork included in this repository may be subject to different licenses.