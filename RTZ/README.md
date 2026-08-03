# Real-Time Zeus (RTZ)

An Arma 3 mod that adds real-time strategy elements to the Zeus system.

RTZ is written in SQF and follows the [ACE3 coding guidelines](https://ace3.acemod.org/wiki/development/coding-guidelines)
and CBA's modular component structure — the same conventions ACE3 and ZEN use.

## Requirements

- [CBA_A3](https://steamcommunity.com/sharedfiles/filedetails/?id=450814997)
- [Zeus Enhanced (ZEN)](https://steamcommunity.com/sharedfiles/filedetails/?id=1779063631)

[LAMBS_Danger.fsm](https://steamcommunity.com/sharedfiles/filedetails/?id=1858075458)
is loaded alongside RTZ in normal use and several components read its state, but
it is not a hard dependency — the LAMBS-facing paths degrade cleanly without it.

## Building

Built with [HEMTT](https://hemtt.dev):

```
hemtt check     # lint configs, SQF and stringtables
hemtt build     # development build
hemtt launch    # start Arma 3 with RTZ + CBA + ZEN + LAMBS and the test mission
hemtt release   # signed release zip
```

See [docs/Architecture.md](docs/Architecture.md) for the component structure and
the `core` drawing/streaming contracts.

## License

Copyright (C) 2026 Maxim

Real-Time Zeus is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the [GNU General Public License](LICENSE) for more
details.
