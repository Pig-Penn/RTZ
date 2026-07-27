# Spotting Routine — Simple Explanation

This is how RTZ decides what enemies a Zeus (curator) can "see" as icons
above their heads, and when a radio contact report gets called out.

Think of it as three jobs, running in a loop:

1. **The server** checks, a few times a second, what each side's AI
   actually knows about the enemy.
2. It tells each Zeus player only what changed since last time.
3. **Each player's game** just draws whatever it was told, every frame.

---

## Job 1: The Server Checks Who Sees Who

Every couple of seconds, the server does this:

```
Look at every AI soldier and vehicle on every side.
Group them by side (BLUEFOR, OPFOR, etc).

For each side, pick ONE soldier per squad to "represent" that squad
(since in Arma, a whole squad shares the same knowledge — no need to
check every single soldier).

For each Zeus player, figure out what side they're on.

For each side that has a Zeus watching it:
    Ask: "Out of all the enemy squads, which ones does THIS side's
          AI actually know about, and how well?"

    For each enemy squad:
        - If barely anyone noticed them  -> ignore, show nothing
        - If someone has a rough idea where they are -> show a
          group icon (just a squad marker, no names)
        - If someone has gotten a good, solid look at specific
          soldiers -> show a chevron above each of those soldiers,
          and if this is the FIRST time this squad was confirmed,
          queue up a "Contact!" radio call

    Send a radio report once for the whole side, listing every
    newly-confirmed squad, with a rough location ("near Athira",
    "northwest of Kavala", etc).
```

A couple of extra rules make this feel natural:
- Once a soldier has been clearly spotted, they stay "known" for about
  10 seconds even if the AI's attention wanders — so icons don't
  flicker on and off.
- If a squad is down to one soldier, it stops showing a squad icon
  (nothing left to group).
- If a spotted soldier shoots while someone is watching them, their
  icon flashes white for a moment (a little "muzzle flash" cue).

---

## Job 2: Only Send What Changed

The server remembers what it last told each Zeus player. Every check,
it compares the new picture to the old one:

```
For each icon that should exist:
    If this is new, or something about it changed (color, name,
    position in a meaningful way) -> tell that Zeus player about it
    If nothing changed -> say nothing (saves network traffic)

For each icon that used to exist but shouldn't anymore:
    Tell that Zeus player to remove it
```

If a player reconnects into the Zeus role, they explicitly ask the
server "please resend me everything" so they don't end up with a blank
picture just because nothing "changed" from the server's point of view.

---

## Job 3: Draw What You Were Told

This part runs on each player's own computer, every single frame
(so it looks smooth), and it does no thinking of its own — it just
draws whatever the server last sent:

```
If Zeus isn't open, or the map is open -> draw nothing

For every squad icon the server told me about:
    Draw a NATO-style marker above that squad's leader
    If the mouse is hovering near it, remember that (so nearby
    soldiers can "peek" through even at long range)

If chevrons (per-soldier markers) are turned on:
    For every soldier the server told me about:
        If too far away -> skip, UNLESS their squad icon is being
        hovered over (lets you peek at squad composition from afar)
        Draw a small marker above their head
        If hovering directly on them -> show their name/rank
```

---

## The Radio Call

When a squad first gets solidly identified, one soldier "reports" it
over the radio:

```
Figure out the nearest named place on the map.
    Very close   -> "in <place>"
    Fairly close -> "near <place>"
    Farther out  -> "<direction> of <place>" (e.g. "northwest of Kavala")
    Nothing close -> no location mentioned at all

Pick a random radio phrase template, e.g. "Contact, {category} {location}"
Fill it in and have the reporting soldier say it.
```

## Naming the Contact Type

To decide what to call a contact in the radio report:

```
If they're in a plane/helicopter -> "aircraft"
If they're in a boat/submarine   -> "naval"
If they're in a tank             -> "armor"
If they're in any other vehicle  -> "vehicles"
Otherwise (on foot)              -> "infantry"
```
