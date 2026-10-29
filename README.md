# Dynamic Island for KDE Plasma on Wayland

> **How this was built.** A large part of this code was written with
> [Claude](https://claude.com/claude-code), and it has been reviewed by the
> author. The idea, the design decisions and the testing on real hardware are
> mine. Saying so up front seems more useful than letting you find out.

A pill that grows out of the top edge of the screen, stretches into a card to
show you a notification, and shrinks back into the bezel when it is done —
built for KDE Plasma 6 on Wayland. Black enough for an OLED panel by default,
and three other palettes when that is not what you want.

It is not a theme or a tweak: the app takes the `org.freedesktop.Notifications`
service away from plasmashell and draws every notification itself on a
`wlr-layer-shell` surface. Wayland is not a preference here but the whole
mechanism — the surface is a layer-shell one, and X11 has nothing to put it on.

<img src="docs/hero.gif" alt="A notification arriving: a capsule drops out of the top edge, stretches into a card with buttons, and a second card stacks behind it" width="560">

<p>
  <b>You like this project?</b><br>
  <a href="https://ko-fi.com/teodorgross"><img src="https://img.shields.io/badge/Ko--fi-teodorgross-FF5E5B?style=for-the-badge&logo=kofi&logoColor=white&labelColor=000000" height="44" alt="Support me on Ko-fi"></a>
</p>

**Interface languages:** Русский · English · Deutsch · 简体中文 · 日本語

---

## One take, on an ordinary desktop

Everything else in this file is recorded out of the scene graph. The two below
are not: they are screen captures of a real session, unscripted and uncut apart
from the waiting.

First from far enough back to see what it actually is — a whole 32:9 desktop
with no window open on it, and a notification arriving where a notification
arrives:

<img src="docs/desktop-wide.gif" alt="A 32:9 desktop showing only the wallpaper and the panel; a small card unfolds out of the top edge in the middle of the screen" width="880">

That is the size the island is meant to be: a card at the top edge and the rest
of the screen still yours. Closer in, over about twenty seconds — a file move
arriving with its progress bar and its pause and cancel buttons, the volume
keys, and a track change where the accent turns orange because the next cover
is orange:

<img src="docs/desktop.gif" alt="A Dolphin file move drops out of the top edge as a card with progress, pause and cancel; then the volume display; then a track change whose glow turns orange with the album cover" width="700">

---

## What it looks like

Every picture below is the island itself: the frames come out of the running
scene graph, not out of a drawing program — see `tools/make-media.py`.

| | |
|---|---|
| <img src="docs/screenshots/island-actions.png" alt="A Firefox notification with Open and Show folder buttons" width="380"> | **Actions.** Whatever the sender offers becomes a button. Clicking the card itself runs the default action *and* brings that application's window forward — on Wayland it cannot do that on its own. |
| <img src="docs/screenshots/island-reply.png" alt="Inline reply field inside the island" width="380"> | **Inline reply.** KDE's `inline-reply` hint is supported, so you can answer a chat message without leaving what you were doing. |
| <img src="docs/screenshots/island-critical.png" alt="A critical battery notification" width="380"> | **Critical stays.** Critical notifications never expire on their own; everything else counts down and pauses while the pointer rests on it. |
| <img src="docs/screenshots/island-stack.png" alt="Several notifications stacked behind the front one" width="380"> | **A stack you can see.** More notifications pile up visibly behind the front card. |
| <img src="docs/screenshots/island-copy.png" alt="A copy job with a progress bar, pause and cancel" width="380"> | **File operations too.** Copying, moving and deleting arrive over KDE's own job protocol, with their progress bar and their pause and cancel buttons. |
| <img src="docs/screenshots/island-volume.png" alt="The volume display inside the island, with the current track under the bar" width="380"> | **Volume and brightness.** The on-screen displays move into the island — and while music is playing the volume bar brings the track with it. |
| <img src="docs/screenshots/island-media.png" alt="A track with its cover and previous, play and next buttons" width="380"> | **What is playing.** A track change brings up its cover, title and artist, and the buttons to steer it. The accent comes from the cover. |
| <img src="docs/screenshots/island-feed.png" alt="A heise online headline in the island, with the site's own icon" width="380"> | **Feeds.** An RSS or Atom feed becomes cards, wearing the feed's own icon — and never replaying what was published while the machine was off. |
| <img src="docs/screenshots/island-webhook.png" alt="A card that arrived over HTTP, with a progress bar" width="380"> | **Webhooks.** Anything on your network that can fetch a URL can put a card up, with buttons, a progress bar and an icon. |
| <img src="docs/screenshots/history-applet.png" alt="The history applet listing four past notifications" width="380"> | **History in the panel.** The pill is short-lived, so a panel applet keeps the last hundred — and a click on a row opens what sent it. |

<details>
<summary><b>The same things, moving</b></summary>

| | |
|---|---|
| <img src="docs/volume.gif" alt="The volume display with the current track" width="380"> | Volume, with what is playing underneath |
| <img src="docs/media.gif" alt="A track starting to play" width="380"> | A track starting |
| <img src="docs/critical.gif" alt="A critical notification that stays on screen" width="380"> | A critical one, staying |
| <img src="docs/copy.gif" alt="A copy job filling its progress bar" width="380"> | A file operation |
| <img src="docs/feed.gif" alt="A feed entry arriving" width="380"> | A feed entry |
| <img src="docs/webhook.gif" alt="A card arriving over HTTP" width="380"> | A webhook card |
| <img src="docs/stack.gif" alt="Four notifications stacking" width="380"> | Four in a row, stacking |

</details>

Underneath sits a soft glow in an accent colour **computed from the sending
app's icon** — grey and transparent pixels are ignored, so a white logo still
gives up its brand colour.

Click runs the default action, middle-click dismisses, swiping up dismisses,
hovering freezes the countdown.

---

## Four ways to look

<img src="docs/screenshots/themes.png" alt="The same notification in AMOLED black, dark grey, light, and the desktop's own colours" width="700">

Clockwise from the top left, and switchable while it runs
(*Configure Dynamic Island… → Island → Colour → Made of*):

| | |
|---|---|
| **AMOLED** | Real `#000000`, which is what the island was designed around: on an OLED panel those pixels are simply off. The default. |
| **Dark** | A dark grey body, for panels where true black smears or blooms — and for anyone who finds a black hole in the screen too stark. |
| **Light** | Dark type on white, for a light desktop where a black pill is a hole. |
| **Follow the colour scheme** | Whatever Plasma's active scheme says. It reads the palette, so it changes with your scheme and needs no maintenance here. |

All four are shown above on the same grey, because that is the only ground on
which a black pill and a white one are both visible; on your desktop each sits
on your wallpaper. The glow, the accent and the artwork behind the text follow
the choice — the blurred cover is dimmed on a dark card and lightened on a
light one, or the words stop being readable.

---

## The screens it was built on

It runs on any screen Plasma runs on. But it was developed and tested on an
**OLED ultrawide**, and that is where it stops looking like a rectangle and
starts looking like part of the hardware:

* **On an OLED or AMOLED panel** the default `#000000` body is not a dark grey
  drawn over the wallpaper — those subpixels are simply off. There is no
  backlight behind the pill and no edge where it ends, so what you see is a
  hole in the screen with your notification inside it. That is the whole idea,
  and it is the one thing an LCD cannot reproduce: a backlit panel is still lit
  behind its black, so the pill keeps a faint rectangle around it. On an LCD
  the **Dark** palette is usually the more honest choice — a body that admits
  to being dark grey beats one pretending to be off.
* **On an ultrawide** the top edge is long enough that a 600 px card sits in
  the middle of it without reaching anything. The island is centred on the
  screen, so on 21:9 or 32:9 it lands over the empty middle of the top edge
  rather than over the corner where a window's title or a browser's tabs live,
  and a full-screen window loses nothing worth seeing.

On a 16:9 laptop panel the card takes up proportionally more of the top edge —
still fine, but `expandedWidth` and `compactHeight` are there if you want it
smaller. With more than one monitor, `screen` decides where it lives:
`"active"` follows you, or name a connector like `"DP-1"` to nail it down.

---

## Settings

Right-click the panel icon → *Configure Dynamic Island…*

| | |
|---|---|
| <img src="docs/screenshots/settings-island.png" alt="The Island settings page" width="380"> | **Island.** Timeouts, what it takes over, the stack, where it sits, size, colour, language, and which applications are never shown. |
| <img src="docs/screenshots/settings-sources.png" alt="The Sources settings page with a feed selected" width="380"> | **Sources.** Feeds, JSON endpoints and the webhook server. Nothing to apply — every control writes as you use it, and the running island picks it up. |

---


## Requirements

* KDE Plasma 6 on **Wayland** (there is no layer shell on X11)
* Python 3.11+

```bash
sudo dnf install python3-pyside6 python3-dbus layer-shell-qt
```

PySide6 has to come from the distribution packages — the PyPI build ships its
own Qt and collides with the system Qt that the layer-shell QML plugin was
built against.

> On Arch: `sudo pacman -S pyside6 python-dbus layer-shell-qt`,
> on openSUSE: `sudo zypper install python3-pyside6 python3-dbus layer-shell-qt`.

---

## Install

Start from the **latest release**, not from `main`: main is where the work
happens, a release is a state that was tested as a whole. Four lines get you
there:

```bash
git clone https://github.com/teodorgross/Dynamic-Island-Plasma-Wayland.git
cd Dynamic-Island-Plasma-Wayland
git checkout "$(git tag --sort=-v:refname | head -n 1)"   # the newest release
./tools/install.sh
```

The launcher runs the island straight out of this folder, so the folder stays
where it is. Updating later is the same idea from inside it:

```bash
git fetch --tags && git checkout "$(git tag --sort=-v:refname | head -n 1)"
./tools/install.sh
```

`install.sh` does all of this:

1. links `tools/run.sh` into `~/.local/bin/dynamic-island`
2. installs a desktop entry so portals can resolve the app
3. compiles the translation catalogues
4. installs a **systemd user service** and enables it, so the island is there
   after every login and every reboot
5. installs the panel applet and puts it into your panel
6. hands the notification service **and** the file-operation protocol over
   right away — the panel blinks once, windows are untouched

Add `--no-takeover` to skip the last step; the island then starts with your
next login instead of immediately.

### Try it

```bash
./tools/demo-notifications.sh
```

Just want to look at it without touching your session's notifications:

```bash
./tools/run.sh --no-bus --demo
```

---

## Uninstall

One command, and Plasma has its notifications back:

```bash
./tools/uninstall.sh
```

It stops and removes the service, takes the applet out of the panel and
uninstalls it, removes the launcher and the desktop entry, and restarts
plasmashell so the shell reclaims `org.freedesktop.Notifications` and
`org.kde.JobViewServer`.

Your settings in `~/.config/dynamic-island/` and the history in
`~/.local/share/dynamic-island/` are left alone — delete them by hand if you
want them gone.

### Turn it off without uninstalling

```bash
systemctl --user disable --now dynamic-island.service
./tools/restore-plasma-notifications.sh
```

And back on:

```bash
systemctl --user enable --now dynamic-island.service
```

---

## Autostart, and why it needs a systemd unit

plasmashell claims `org.freedesktop.Notifications` while it starts up and
never hands it back on request. A plain XDG autostart entry would lose that
race every time — it runs *after* the shell.

`tools/dynamic-island.service` wins it instead:

```ini
Before=plasma-plasmashell.service
Type=dbus
BusName=org.freedesktop.Notifications
```

`Type=dbus` makes the ordering binding: systemd treats the unit as started
only once the name is actually on the bus, so plasmashell cannot slip past.
When the shell comes up it finds the name taken and leaves the job alone —
no restart, no flicker, on every login and after every reboot.

---

## The panel applet

<img src="docs/screenshots/panel-icon.png" alt="The bell icon in the Plasma panel" width="120" align="right">

The pill is deliberately forgetful, so the applet is where a notification goes
to be read a second time. It shows the last `historyLength` notifications, each
with the accent stripe the island derived from the app icon, and the broom in
the corner throws them all away.

It reads the list straight out of
`~/.local/share/dynamic-island/history.json`, so the panel keeps working while
the island restarts. Only clearing goes over D-Bus
(`org.dynamicisland.Island.ClearHistory`), because the cached thumbnails have
to go with it.

Right-click the applet → *Configure* to pick the panel icon and whether it gets
marked while there is something in the history.

If it is not in your panel: right-click the panel → *Add Widgets* → *Dynamic
Island*.

---

## Configuration

Everything below can be clicked instead of typed: right-click the panel icon →
*Configure Dynamic Island…* → **Island** and **Sources**. The pages write the
file described here as you use them — there is no apply button, and the running
island picks each change up.

`~/.config/dynamic-island/config.json` is written on first start and re-read at
runtime; unknown keys are preserved.

| Key | Default | Meaning |
|---|---|---|
| `topMargin` | `0` | Gap to the top screen edge. `0` draws the body past the edge so the pill grows out of the bezel |
| `screen` | `"active"` | `"active"` follows the active screen, otherwise a connector like `"DP-1"` |
| `expandedWidth` | `600` | Width of the opened card; a card without buttons is drawn a little narrower |
| `expandedRadius` | `30` | Corner radius when open |
| `compactHeight` | `40` | Height of the capsule before it unfolds |
| `maxHeight` | `460` | Height cap for the card |
| `defaultTimeout` | `6000` | Display time in ms when the sender does not ask for one |
| `lowUrgencyTimeout` | `4000` | Same, for low urgency |
| `criticalNeverExpires` | `true` | Critical notifications never expire on their own |
| `pauseOnHover` | `true` | Pointer on the island freezes the countdown |
| `stackDepth` | `3` | How many cards stay visible behind the front one |
| `dismissThreshold` | `26` | Swipe distance in px before it dismisses |
| `theme` | `"amoled"` | `"amoled"`, `"dark"`, `"light"` or `"system"` — see above |
| `accentFromIcon` | `true` | Derive the accent colour from the icon |
| `fallbackAccent` | `"#0A84FF"` | Colour used when that fails |
| `glowOpacity` | `0.55` | Strength of the coloured bloom, `0` turns it off |
| `strokeOpacity` | `0.10` | Hairline border on the pill |
| `fontFamily` | `""` | Empty means the system font |
| `historyLength` | `100` | How many notifications the applet keeps, `0` disables the history |
| `showJobs` | `true` | Show copy/move/delete progress in the island, with pause and cancel |
| `showOsd` | `true` | Volume, brightness and the other on-screen displays in the island |
| `osdTimeout` | `2000` | How long an on-screen display stays, in ms |
| `showMedia` | `true` | Show a track when it starts, with previous/play/next |
| `mediaHideWhenFocused` | `true` | No track banner while the player's own window has the focus |
| `mediaTimeout` | `5000` | How long the track banner stays, in ms |
| `soundEnabled` | `true` | Play the `sound-file` / `sound-name` hints senders provide |
| `defaultSound` | `""` | Sound-theme event for notifications that ask for none |
| `blacklist` | `[]` | App names or `desktop-entry` values that never show up |
| `doNotDisturb` | `false` | Suppress everything but critical notifications |
| `sources` | `[]` | Feeds, endpoints and the webhook server — see below |

---

## Sources: feeds, APIs and webhooks

Not everything worth a card is an application on this machine. A source is
anything else that can produce one, and there are three kinds. They live under
`sources` in the config file, and the **Sources** page of the applet's
configuration dialog edits them.

### An RSS or Atom feed

```json
{"type": "rss", "name": "heise", "url": "https://www.heise.de/rss/heise-top-atom.xml",
 "interval": 900, "filter": "kernel|security", "maxItems": 3}
```

RSS and Atom are both read, and mixtures of the two — which is most of the web —
as well. `interval` is how often it is fetched, `maxItems` how many new entries
one round may announce, and `filter` a regular expression the headline has to
match; a feed is often 90 % noise and one keyword is the difference between
useful and unusable.

**Old news never arrives.** Two rules see to that, and both matter after the
machine has been off for a night:

* the first round after a start is silent — it writes down what is already in
  the feed instead of replaying it,
* and after that an entry has to be new *and* dated after the island came up,
  so a feed that reorders itself or republishes an article cannot make
  yesterday's headline pop up today.

Set `announceFirst: true` if you do want the current contents on start, and
`trustDates: false` for a feed whose dates are wrong (some are).

The card wears the **feed's own icon**: `<icon>` or `<logo>` from Atom,
`channel/image/url` from RSS, and the site's favicon when it offers neither.
It is fetched once, kept in `~/.cache/dynamic-island/feed-icons/`, and the
accent glow is derived from it — heise's cards come out heise-blue. Setting
`icon` in the source overrides that with whatever you name.

Clicking the card opens the entry.

### A JSON endpoint

```json
{"type": "rest", "name": "Statuspage", "url": "https://…/api/v2/incidents.json",
 "itemsPath": "incidents", "interval": 300,
 "headers": {"Authorization": "Bearer …"},
 "fields": {"id": "id", "summary": "name", "body": "status", "url": "shortlink"}}
```

`itemsPath` says where in the answer the list lives (`data.alerts`, or empty
when the answer *is* the item), `fields` maps the island's fields onto paths in
it. Without `fields` the usual names — `title`, `message`, `url` — are picked up
by themselves.

### A webhook other machines can push to

```json
{"type": "webhook", "bind": "127.0.0.1", "port": 8757,
 "token": "a-long-random-string", "allowCommands": false}
```

It only ever receives. The shortest way in is a plain URL — anything that can
fetch one can put a card on the island:

```
http://127.0.0.1:8757/notify/backup?summary=Backup%20finished&body=42%20GB&token=…
```

The last part of the path is what the card says it came from, so one server
serves one endpoint per service: `/notify/backup`, `/notify/grafana`,
`/notify/doorbell`. `/notify` on its own works too.

`POST` takes the same fields as a JSON body:

```bash
curl -X POST http://127.0.0.1:8757/notify/borg \
  -H 'Authorization: Bearer a-long-random-string' \
  -H 'Content-Type: application/json' \
  -d '{"summary": "Backup finished", "body": "42 GB in 11 minutes",
       "icon": "drive-harddisk", "progress": 100,
       "actions": [{"label": "Log", "type": "url", "url": "https://…"}]}'
```

`GET /health` answers `ok`, and `GET /` prints the whole payload format.

### What a payload may say

Everything is optional but `summary` — and if only `body` is given, that
becomes the headline.

| Field | Meaning |
|---|---|
| `summary` | the headline. Also accepted: `title`, `subject`, `headline` |
| `body` | the text under it. Also: `message`, `text`, `description`, `content` |
| `appName` | who it is from; the path segment fills this in when it is missing |
| `icon` | a theme icon name, an absolute path, or a `file://` url |
| `urgency` | `low`, `normal`, `critical` — or `0`, `1`, `2` |
| `id` | a stable id. The same id replaces its card instead of stacking |
| `timeout` | milliseconds. `0` stays until dismissed, omitted uses the default |
| `progress` | `0`–`100`, draws a bar |
| `url` | opened when the card itself is clicked |
| `actions` | buttons, see below |

A button is one of two things:

| `type` | What it does | Fields |
|---|---|---|
| `url` | opens it | `url` |
| `command` | runs it | `command` as a list |

There is no button that calls an endpoint back: the island receives, it is not
a client for anything.

### Writing an integration

Anything that can make an HTTP request can be one; there is no plugin API to
learn and nothing to install into the island. A shell script:

```bash
notify() {
  curl -sG "http://127.0.0.1:8757/notify/$1" \
       --data-urlencode "summary=$2" --data-urlencode "body=$3" \
       --data-urlencode "token=$ISLAND_TOKEN" >/dev/null
}
notify deploy "Deploy finished" "v2.3.1 is live"
```

Python, with buttons:

```python
import json, urllib.request

def card(payload, endpoint="app", host="127.0.0.1", port=8757, token=""):
    request = urllib.request.Request(
        f"http://{host}:{port}/notify/{endpoint}",
        data=json.dumps(payload).encode(),
        headers={"Content-Type": "application/json",
                 **({"Authorization": f"Bearer {token}"} if token else {})},
    )
    with urllib.request.urlopen(request, timeout=5) as answer:
        return json.load(answer)

card({
    "summary": "Build failed",
    "body": "3 tests red on main",
    "urgency": "critical",
    "id": "ci-main",                      # the next one replaces this card
    "url": "https://ci.example.com/main",  # opened when the card is clicked
    "actions": [{"label": "Logs", "type": "url",
                 "url": "https://ci.example.com/main/log"}],
})
```

Both give you the same card an application on the machine would get: the accent
comes from your icon, `id` lets you update a card in place — progress bars are
just a `progress` field on the same id — and the click opens your link.

If your service already publishes RSS or Atom, you do not need any of this:
point a feed source at it and the entries arrive with your site's own icon.

### About the token

The threat here is small but real: a webhook is an open port that puts text on
your screen, and with `allowCommands` a way to run programs as you. So:

* **It binds to localhost.** On `127.0.0.1` only this machine can reach it and
  the token is a nicety. Bind to anything else and the island refuses to start
  without one.
* **The token is compared in constant time**, so how long the answer takes says
  nothing about how much of the token was right.
* **`allowCommands` is off**, and turning it on requires a token even on
  loopback. A `command` button runs a program as you, and every account on the
  machine can reach `127.0.0.1` — so localhost is not a boundary for that one,
  and the island refuses to start rather than pretend it is.
* **The endpoint name is not a path.** The last part of `/notify/<name>` ends up
  as the card's app name and is looked up against your desktop entries, so a
  name carrying a separator or a leading dot is rejected outright.
* **There is no TLS.** Over a LAN behind a firewall that is fine; across the
  internet, put it behind a reverse proxy that terminates TLS, or reach it
  through a VPN. The island will not pretend a bearer token over plain HTTP is
  private.

The token itself lives in `config.json`, which is written `600` — for you and
nobody else. To keep it out of that file:

```json
{"type": "webhook", "bind": "0.0.0.0", "port": 8757,
 "tokenFile": "~/.config/dynamic-island/webhook.token"}
```

```bash
install -m 600 /dev/null ~/.config/dynamic-island/webhook.token
head -c 24 /dev/urandom | base64 > ~/.config/dynamic-island/webhook.token
```

`tokenEnv` does the same with an environment variable, for a token that comes
from somewhere else entirely — a secret manager, a systemd credential. Both
beat pasting it into a dotfile repository, and the settings page shows the
field as dots either way.

---

## Languages

**Interface:** Русский · English · Deutsch · 简体中文 · 日本語

The island's own words — the reply field, the volume label, the buttons on a
file operation — follow the **Language** setting on the *Island* page:
*Follow the desktop* by default, or one of the five by hand.

The settings pages themselves belong to the panel widget, which is a KDE
package: it follows the desktop language (System Settings → Region &
Language), the same as every other widget in your panel. That is a Plasma rule,
not a decision this project gets to make.

German is complete. The Japanese and Chinese catalogues carry the older
strings; everything added with the settings pages is still English there and is
marked as such in the `.po` files — a native speaker's pass would be welcome.

Adding or finishing a language is three commands:

```bash
cp applet/org.dynamicisland.history/translate/template.pot \
   applet/org.dynamicisland.history/translate/fr.po   # then translate it
./tools/update-translations.py       # pulls new strings out of the QML
./tools/build-translations.py        # compiles the .mo files
```

`update-translations.py --check` reports what is missing without touching
anything, which is what a pull request should be green on. Neither script needs
gettext installed. For the island's own words, add the language to `TABLE` in
`src/dynamicisland/strings.py`.

---

## File operations

Copying, moving and deleting never travel over `org.freedesktop.Notifications`.
KDE tracks them with a second protocol: the application asks
`org.kde.JobViewServer` for a view and reports progress on it, while the server
sends `cancelRequested`, `suspendRequested` and `resumeRequested` back — that is
where Plasma's pause and cancel buttons come from.

The island takes that name over as well, so a copy is a card like any other,
with its progress bar and its buttons, and the buttons still reach the
application doing the copying. Both interface versions are served, so KF6's KIO
and older clients are equally at home.

Set `showJobs` to `false` to leave file operations with Plasma's own progress
display.

> Local copies on btrfs finish before any progress can be shown — the
> filesystem makes a reflink instead of moving the data. Copying to another
> filesystem, a USB drive or over the network is where a progress card appears.

## Volume, brightness and friends

Plasma draws these itself: a volume key makes plasma-pa call
`org.kde.osdService.volumeChanged` on plasmashell, which pops up a grey box in
the middle of the screen. That name belongs to plasmashell and cannot be taken
over, so the island listens in on the bus instead — and `install.sh` switches
Plasma's own display off (`plasmarc`, `[OSD] Enabled=false`) so it is not drawn
twice. `uninstall.sh` puts that back.

Holding a volume key down moves the bar inside the banner that is already
there instead of stacking new ones behind it. `showOsd: false` hands the job
back to Plasma — turn its OSD back on with
`kwriteconfig6 --file plasmarc --group OSD --key Enabled true`.

<img src="docs/architecture.svg" alt="Applications send notifications to Dynamic Island, which writes a history file the panel applet reads, while file managers keep talking to plasmashell about copy jobs" width="880">

---

## What is playing

Every player announces itself over MPRIS, so a track change brings up a banner
with the cover, the title and the artist, plus previous, play/pause and next.
The accent is taken from the cover, like everywhere else.

The banner is for music coming from somewhere in the back. While the player's
own window has the focus — the video watched in the browser, Spotify itself in
front — the track change is already on screen, so no banner comes up; it
returns the moment the player is minimised or another window takes over. A
small KWin script reports the active window for this, the same way the
window-raising works; `mediaHideWhenFocused: false` shows the banner
regardless of focus.

This one only listens — nothing is taken away from anybody, so Plasma's media
applet keeps working as before. `showMedia: false` turns it off.

---

## Layout

```
src/dynamicisland/
  app.py          entry point: claim the bus, load the scene, run
  server.py       org.freedesktop.Notifications (dbus-python)
  controller.py   lifetime of a notification, timers, filters, actions
  model.py        the list behind the island, newest first
  artwork.py      icon/image resolution and accent colour
  history.py      what the island has already shown, as JSON on disk
  jobs.py         org.kde.JobViewServer: copy/move/delete progress
  osd.py          volume and brightness, listened for on the bus
  media.py        MPRIS: what is playing, and the buttons for it
  apps.py         which application a notification came from, and raising it
  strings.py      the island's own two words, per language
  config.py       ~/.config/dynamic-island/config.json, watched for edits
  capture.py      lets the island photograph itself; off unless asked
  window.py       layer-shell activation, input region, screen choice
  glibpump.py     keeps dbus-python alive inside the Qt loop
  sources/
    __init__.py   builds the configured sources, owns what the buttons do
    payload.py    what a source hands over, however loosely it says it
    base.py       polling, and only announcing what is new
    feed.py       RSS and Atom
    rest.py       any JSON endpoint, on a timer
    webhook.py    the HTTP endpoint other machines push to
    actions.py    open a url, call back, run a command
  qml/
    main.qml                  the layer-shell surface at the top edge
    DynamicIsland/Island.qml  the morphing pill
    DynamicIsland/*.qml       card, buttons, reply field, theme

applet/org.dynamicisland.history/
  contents/ui/main.qml        the panel widget
  contents/ui/HistoryRow.qml  one past notification
  contents/ui/ConfigIsland.qml   the island's settings, in the panel dialog
  contents/ui/ConfigSources.qml  feeds, endpoints and the webhook
  contents/ui/IslandConfig.qml   reads config.json, writes it over D-Bus
  translate/*.po              source catalogues

tools/
  install.sh / uninstall.sh   the two commands above
  run.sh                      run from the source tree
  demo-notifications.sh       fire one of every kind
  selftest.py                 drives a real pointer over a real island
  make-media.py               records the pictures and GIFs in this README
                              (all but the two docs/desktop*.gif screen captures)
  update-translations.py      finds new i18n() strings, keeps .po files in step
  build-translations.py       .po -> .mo, without gettext
  capture.py                  grabs an area out of KWin, for stills
```

---

## Development

```bash
./tools/run.sh --no-bus --demo     # looks only, session keeps its notifications
./tools/selftest.py                # clicks, swipes and asserts, needs /dev/uinput
./tools/selftest.py --offline      # only the checks that need no session
./tools/make-media.py              # re-records every picture in this README
```

`selftest.py` drives a **real pointer** over the **real surface** — it moves a
uinput device onto the pill, presses, swipes, and asserts on what the island
says it did. That is the only honest way to test an input region a compositor
owns, and it has earned its keep: it is what found the swipe measuring itself
against a moving ruler. It takes the notification service over and empties the
history at the end, so run it when you are not depending on either.

`--offline` is the subset that is only code — the feed parser, the
file-operation cards — and is what CI runs.

`make-media.py` starts an island with `DYNAMIC_ISLAND_CAPTURE` set, plays a
script of notifications at it, and turns the frames into the pictures above.
The frames come out of `QQuickWindow.grabWindow()`, so they are the scene
graph itself, alpha and all; nothing in this README is drawn by hand.

The exceptions are `docs/desktop-wide.gif` and `docs/desktop.gif` at the top,
which are screen recordings of a real session rather than captures of the
surface — which is why they are the only pictures here with a mouse pointer
and a panel in them.

---

## Known limits

* Wayland only. There is no layer shell on X11; the window would come up as an
  ordinary one, in the wrong place.
* The history is a read-only list. Actions and replies are gone once the card
  is.
* Plasma's own notification widget sees nothing while the island is running —
  that is what the history applet is for.
* Sources are polled and pushed to; there is no button that calls an endpoint
  back, on purpose.
* The settings pages need the island running: they hand their changes to it
  over D-Bus rather than writing its file behind its back.

---

## License

MIT
