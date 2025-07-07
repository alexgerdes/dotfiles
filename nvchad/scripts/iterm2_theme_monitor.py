"""
This iTerm2 Python script calls a Lua function to notify running NeoVim 
instances of an MacOS appearance change. It is based on:

  https://oterodiaz.com/posts/making-neovim-and-emacs-adapt-to-system-dark-mode/

Install this script in iTerm2 by putting it in:

  ~/Library/Application Support/iTerm2/Scripts/AutoLaunch/

Enable the Python API in iTerm2 settings and install the python dependencies
for this script: iterm2, nest_asyncio, and pynvim. Do this via Manage
Dependencies in iTerm2. See https://iterm2.com/python-api/tutorial/running.html
for more information.
"""

#!/usr/bin/env python3


import glob

import iterm2
import nest_asyncio
from pynvim import attach

nest_asyncio.apply()


def make_lua_call(mode):
    """
     Create a Lua call to the os_appearance_changed function with the given
    mode. The call checks if the aforementioned function exists.
    """
    return f'if os_appearance_changed ~= nil then os_appearance_changed("{mode}") end'


async def notify_nvim(theme):
    """Call the os_appearance_changed function in running Neovim processes via sockets."""
    mode = "Dark" if "dark" in theme.split(" ") else "Light"

    nvim_sockets = (attach("socket", path=p) for p in glob.glob("/tmp/nvim/nvim*.sock"))

    for nvim in nvim_sockets:
        nvim.exec_lua(make_lua_call(mode))


async def main(connection):
    """Act on theme change initiated by a MacOS appearance change."""
    app = await iterm2.async_get_app(connection)
    await notify_nvim(await app.async_get_variable("effectiveTheme"))
    async with iterm2.VariableMonitor(
        connection, iterm2.VariableScopes.APP, "effectiveTheme", None
    ) as mon:
        while True:
            # Block until theme changes
            theme = await mon.async_get()
            await notify_nvim(theme)


iterm2.run_forever(main)
