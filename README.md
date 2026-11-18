# Daybreak

World time and calendars on a day and night globe that lives in your menu bar.

Instead of doing time zone sums in your head, Daybreak shows where everyone's day is at a glance and lets you slide through your own day to see what time it'll be for them. An iPhone version is on the way.

## What it does

**Menu bar** -- today's weekday, day and month side by side, stacked or as a small calendar page, with the time in any place you pin next to it.

**Globe** -- the Earth lit by NASA imagery with daylight where the sun is up and city lights coming on as night falls, and it turns to show a place when you pick it.

**Your time and place** -- your own time, country and time zone at the top, worked out from where your Mac is.

**Places you follow** -- the time in each place on your list, added by searching for a city or a time zone.

**Time slider** -- slide through your day and every place on your list follows, so you can see what time a meeting at three would be everywhere.

**Month** -- the month at a glance, where picking a day moves everything to that date.

**Smart swap** -- when you travel to a place on your list it swaps places with the one you left, so home stays on the list while you're away.

## How it works

**Your location** -- Daybreak asks for it to show your own time and place, and Apple's maps turn it into a city and country name.

**What reaches the internet** -- searching for a city goes through Apple's maps, and the app checks for updates. The globe's imagery ships with the app.

## Requirements

- **macOS 27** -- for the Mac app
- **Sparkle** -- installs updates and is the only third-party dependency

## Building

The Xcode project is generated from `project.yml` using `xcodegen` and isn't committed, and neither is `Config/Release.xcconfig` which holds the Apple development team, the updates host and the Sparkle public key for release builds. Make it by copying `Config/Release.xcconfig.example` and filling it in.

To try a change type `go` anywhere in this repo and pick Rebuild to:

1. Build Daybreak in Release
2. Quit the running Mac app
3. Install the new build in `/Applications`
4. Reopen it

Both Rebuild and Release only handle the Mac app for now because `project.yml` sets `WORKSHOP_PLATFORMS` to `macOS`.

The `go` command, its menu and its scripts all come from a private repo shared by all my apps, and the menu needs [gum](https://github.com/charmbracelet/gum) which the private repo installs.

## Releasing

Daybreak is released as a DMG from its own website and installed copies update themselves through Sparkle.
