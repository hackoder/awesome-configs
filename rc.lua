-- Standard awesome library
require("awful")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")

--{{{ dbg function
function dbg(vars)
    local a = ""
    local text = "<span color = \"#FF004D\">dbg</span>"
    for i=1, table.maxn(vars) do
        local j = vars[i]
        a = "<span color='#553333'>" .. i .. " </span>"

        if type(j) == "table" then
          -- element count
          local count = 0
          local longest_key = 6
          for k,v in pairs(j) do count = count + 1; longest_key = math.max((type(k) == "string" and #k) or 0, longest_key) end
          a = a .. "table #" .. count
          -- show elements
          if vars.f then
            for k,v in pairs(j) do
              a = a .. string.format("\n  <span color='#333333'>%-"..longest_key.."s</span> %s", k, tostring(v))
            end
          end

        else a = a .. tostring(j) or "nil"
        end
        text = text .. " \n" .. a
    end
    naughty.notify{ text = text, timeout = 0, hover_timeout = 0.2, screen = screen.count() }
end
--}}}
--{{{ remap function
function remap(from_mod, from_key, to, desc)
  return awful.util.table.join(awful.key(from_mod, from_key, 
    function(c) 
      for i,j in ipairs(to) do
        sendkey(j)
      end
    end, nil, desc))
end
--}}}

require("shifty")
require("wicked")
require("inotify")

require("mpd")
mpc = mpd.new()

--{{{ vars 

--{{{ vars / common
theme_path = "/home/koniu/.config/awesome/theme.dark.master.lua"
icon_path = "/home/koniu/.config/awesome/icons/"
beautiful.init(theme_path)
modkey = "Mod4"
if screen.count() == 2 then LCD = 2 else LCD = 1 end

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.tile,
--    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
--    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.floating,
--    awful.layout.suit.fair.horizontal,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
--    awful.layout.suit.magnifier,
}

--custom
config = {}
config.terminal = "urxvtc"

config.tasklist_noicons = true
-- step for scrolling
config.step = 15

-- screen offset it scrolls within
config.scroll_offset = 2

-- some shortcuts
join = awful.util.table.join
doc = awful.doc

awful.help.combo_subst = {
["(%u)"] = function(m) return string.lower(m) end,
  control = "ctl",
  mod1 = "alt",
  mod4 = "win",
  mod5 = "ralt",
  XF86 = "x",
  forward = "fwd",
}

awful.help.combo_ignore_groups = {
  "1. global actions" ,
  "default"
}
--}}}

--{{{ vars / shifty

--{{{ vars / shifty / config.tags
shifty.config.tags = {

["sys"]     = { position = 0, exclusive = true, mwfact = 0.75307, screen = LCD, layout = "tilebottom"   },
["jack"]    = { position = 0, exclusive = true, mwfact = 0.25307, nmaster = 2, screen = LCD,
                icon_only = true, icon = icon_path .. "audio-x-generic.png", layout = "floating"        },
["term"]    = { position = 2, exclusive = true,  screen = LCD,                                          },
["www"]     = { position = 3, exclusive = true,  screen = LCD,                                          },
["fb"]      = { position = 9, exclusive = true,                                                         },
["dir"]     = { rel_index = 1, exclusive = false,                                                       },
["gq"]      = { rel_index = 1, icon_only = true, icon = icon_path .. "gq.png",
                max_clients = 2, spawn = 'gq',                                                          },
["gimp"]    = { spawn = "gimp", icon = "/usr/share/icons/hicolor/16x16/apps/gimp.png",
                layout = "max", icon_only = true, sweep_delay = 2, exclusive = true,                    },
["xev"]     = { rel_index = 0, spawn = "urxvtc -title 'Event Tester' -name xev -e sh -c 'xev -id $WINDOWID'" },
["live"]    = { icon = "/home/koniu/live.png", layout = "floating", sweep_delay = 2, icon_only = true,  },
["im"]      = { position = 1, spawn = "urxvtc -title IRC -name irc -e screen -t irc -S irc -R irssi"    },
["tetris"]  = { rel_index = 0, spawn = "urxvtc -font '-*-*-*-*-*-*-*-240-*-*-*-*-*-2' -name tetris -e tetris"                }, 

}
--}}}

--{{{ vars / shifty / config.apps
shifty.config.apps = {

    -- tag matches
    { match = { "tail", "^top", "fping", "mtr", "htop", "iwconfig", "Wicd", "apt" 
                                                    },  tag = "sys",	                                },
    { match = { "urxvt"                             },	tag = "term",                                 },
    { match = { "^mc$"                              },  tag = "dir",                                  },
    { match = { "Wine"                              },  tag = "wine",                                 },
    { match = { "Ardour.*", "Jamin",                },  tag = "ardour",                               },
    { match = { "Gmpc",                             },  tag = "mpd",                                  },
    { match = { "foobar2000.exe",                   },  tag = "fb", nopopup = true,                   },
    { match = { "Deluge", "nicotine", "Tucan.py"    },  tag = "dl",                                   },
    { match = { "[Mm]player",                       },  tag = "mplayer",                              },
    { match = { "^Acroread.*"                       },  tag = "pdf",                                  },
    { match = { "^irc$",                            },  tag = "im",                                   },

    -- gajim
    { match = { "^Gajim",                           },  tag = "im",                                   },
    { match = { "^messages$",                       },  nopopup = true, slave = true                  },
    { match = { "^roster$",                         },  float = true, geometry = { 838,35,186,733 },
                                                        dockable = true, struts = { right = 186 },
                                                        skip_taskbar = true,                          },

    -- popterm (aka scratchpad)
    { match = { "popterm",                          },  intrusive = true, opacity = 0.8,
                                                        --dockable = true, struts = { bottom = 200 },
                                                        float = true, sticky = true, ontop = true,
                                                        geometry = { 0, 568, 1024, 200 }, hide = false,
                                                        skip_taskbar = true, titlebar = nil },
    -- ableton live
    { match = { "Live",                             }, 	tag = "live", nopopup = true,
                                                        geometry = { 0, 34, 1400, 1000 },             },
    -- firefox
    { match = { "Iceweasel.*", "Firefox.*", "^Chrome$" },  tag = "www",
      keys = join( remap({ "Mod5" }, "Left",   {105, 112}, "Previous tab"),
                   remap({ "Mod5" }, "Right",  {105, 117}, "Next tab") )                              },

    -- qjackctl tweaks
    { match = { "jackctl"                           },  tag = "jack",                                 },
    { match = { "Informat.*CK Audio Connection Kit" },  kill = true,                                  },
    { match = { "qjackctlMessagesForm",
                "Error.*Connection Kit"             },  nopopup = true,                               },

    -- gimp
    { match = { "Gimp",                             },  tag = "gimp",
      keys = join(
        awful.key({ "Mod1" }, "b", function(c) local a = getclient("role", "gimp-toolbox")
                                               if a then a.hide = not a.hide end
                                               end, nil, "Toggle toolbox"),
        awful.key({ "Mod1" }, "v", function(c) local a = getclient("role", "gimp-dock")
                                               if a then a.hide = not a.hide end
                                               end, nil, "Toggle dock"))                              }, 
    { match = { "^gimp.toolbox$",                   },  struts = { right=170}, skip_taskbar = true,
                                                        geometry = {854,35,170,733}, slave = true     },
    { match = { "^gimp.dock$",                      },  struts = { left=186}, skip_taskbar = true,
                                                        geometry = {0,35,186,733}, slave = true       },
    -- geeqie
    { match = { "^Geeqie$"                          },  tag = "gq"                                    },
    { match = { "Full screen...Geeqie"              },  intrusive = true                              },
    { match = { "Tools...Geeqie"                    },
      keys = join(awful.key({}, "Escape", function(c)  getclient("id", c.group_id + 2):kill() end))   },

    -- various tweaks
    { match = { "htop"                              },  keys = join(
                                                                      remap({}, "Delete", {75,36}),
                                                                      remap({}, "period", {{50,60},{116,36}}),
                                                                      remap({}, "comma", {{50,59},{111,36}})
                                                                                                  )     },
    { match = { "sqlitebrowser"                     },  slave = true, float = false, tag = "sql"      },

    -- slaves
    { match = { "gimp-image-window","xmag","^Downloads$", "ufraw", "qjackctl", "fping", "watch",
                                                    },  slave = true,                                 },

    -- floats
    { match = { "recordMyDesktop", "Skype", "QQQjackctl", "MPlayer", "xmag", "gcolor2", "javax.swing"
                                                    },  float = true,                                 },
    -- nopopup 
    { match = { "^Downloads$", 
                                                    },  nofocus = true,                             },

    -- intruders
    { match = { "^dialog$", "xmag", "gcolor2", "^Download$", "^menu$",
                                                    },  intrusive = true,                             },
    -- skip_taskbar 
    { match = { "^xev$", "^menu$"                   },  skip_taskbar = true,                          },
    
    -- dock 
    { match = { "^menu$",                           },  dockable = true, ontop = true, opacity = 0.9  },


    -- all
    { match = { "",                                 },  honorsizehints = false,  
                                                        buttons = join(
                                                            awful.button({ }, 1, function (c) client.focus = c; c:raise() end, nil, "Focus client"),
                                                            awful.button({ "Mod1" }, 1, function (c) awful.mouse.client.move() end, nil, "Move client"),
                                                            awful.button({ "Mod1" }, 3, awful.mouse.client.resize, nil, "Resize client" )
                                                        ),                                            },

}
--}}}

--{{{ vars / shifty / ardour 

shifty.config.tags["ard"] = { 
  layout = "tilebottom", mwfact = 0.8, exclusive = true,
  keys = join(
    awful.key({ "Mod1" }, "m", 
      function(c) local m = getclient("instance", "ardour_mixer")
        local e = getclient("instance", "ardour_editor")
        if m then
          if m.hide then m.hide = false; e.hide = true
          else m.hide = true; e.hide = false end
        end 
      end)
  )
}

local ardour_clients = {
  { match = { "Ardour"                }, tag = "ard" },
  { match = { "ardour_mixer"          }, hide = true },
  { match = { "Ardour...Log"          }, 
      struts = { bottom = 102 }, 
      geometry = { 0, 666, 1024, 102 }
  },
  { match = { "ardour_plugin_editor", "Ardour...Log"  }, slave = true, skip_taskbar = true,
    keys = join(
      awful.key({}, "Escape", function(c) c:kill() end)
    )
  } 
}

for i, m in ipairs(ardour_clients) do table.insert(shifty.config.apps, m) end

--}}}

--{{{ vars / shifty / gittags(tm)

local gittags = {
  [ "d:awsm" ] = { push = "push mg +", main = "zsh", dir = "/home/koniu/awesome", commit = "-a -s",
                   url = "http://git.naquadah.org/?p=awesome.git;a=shortlog;h=refs/heads/master" },
[ "d:shifty" ] = { push = "push mg +", main = "vim lib/shifty.lua.in", dir = "/home/koniu/shifty", commit = "-a -s",
                   url = "http://git.mercenariesguild.net/?p=awesome.git;a=shortlog;h=refs/heads/shifty-master" },
  [ "d:conf" ] = { push = "push origin +", main = "vim rc.lua", dir = "/home/koniu/.config/awesome", commit = "-a",
                   url = "http://github.com/koniu/awesome-configs/commits/master/rc.lua" },
  [ "d:obv" ] = { push = "", main = "zsh", dir = "/home/koniu/.config/awesome/obvious", commit = "-a -s",
                   url = "http://git.mercenariesguild.net/?p=obvious.git;a=shortlog;h=refs/heads/master" },
  [ "d:vali" ] = { push = "", main = "zsh", dir = "/home/koniu/data/kit/git/validichro", commit = "-a",
                   url = "" },
}


for n, v in pairs(gittags) do

  --{{{ vars / shifty / gittags(tm) / commands
  local spawn = "urxvtc -name "..n.."main -title '"..v.main.."' -cd "..v.dir.." -e "..v.main
  local see_www = function() awful.tag.viewonly(shifty.name2tag("www")) end
  local cmds = {
    log = function() terminal("-font 6x10 -name "..n.."pop -hold -title '"..n.." git log' -cd "..v.dir.." -e git -p log") end,
    diff = function() terminal("-font 6x10 -name "..n.."pop -hold -title '"..n.." git diff' -cd "..v.dir.." -e git -p diff --patch-with-stat") end,
    pull = function() terminal("-name "..n.."pop -hold -title '"..n.." git pull' -cd "..v.dir.." -e git pull") end,
    status = function() terminal("-name "..n.."pop -hold -title '"..n.." git status' -cd "..v.dir.." -e git status") end,
    prompt = function() terminal("-name "..n.."cmd -title '"..n.." git prompt' -cd "..v.dir.." -e zsh") end,
    commit = function() terminal("-name "..n.."cmd -hold -title '"..n.." git commit' -cd "..v.dir.." -e git commit "..v.commit) end,
    gitweb = function() awful.util.spawn("firefox '"..v.url.."'"); see_www(); end,
    apidoc = function() awful.util.spawn("firefox http://awesome.naquadah.org/doc/api/"); see_www(); end,
    push = function()
                local br=awful.util.pread("cd "..v.dir.."; git branch --no-color 2> /dev/null | grep \\*")
                br = br:sub(3, #br-1)
                terminal("-name "..n.."pop -hold -title '"..n.." git push "..br.."' -cd "..v.dir.." -e git "..v.push..br) 
           end,
    branch = function()
                prompt.exec({
                args = {
                  fg_cursor = "#FF1CA9", bg_cursor = beautiful.bg_normal, ul_cursor="single",
                  selectall = true, prompt = "<span color='#FF1CA9'>Branch</span>: "
                },

                run_function = function(line)
                  local txt = awful.util.pread("cd "..v.dir.."; git checkout "..line.." 2>&1")
                  local clr = "white"
                  if txt:find("^error") then
                    clr = "red"
                  elseif txt:find("^Switched") then
                    clr = "green"
                  end
                  naughty.notify{ text="<span color='"..clr.."'>"..txt:sub(1,#txt-1).."</span>" }
	              end,

                completion_function = function (cmd, cur_pos, ncomp)
                  local branches = {}
                  local matches = {}
                  local g = io.popen("cd "..v.dir.."; git branch")
                  for line in g:lines() do table.insert(branches, line:sub(3, #line)) end
                  g:close()
                  if cur_pos ~= #cmd + 1 and cmd:sub(cur_pos, cur_pos) ~= " " then return cmd, cur_pos end
                  for i, j in ipairs(branches) do
                    if branches[i]:find("^" .. cmd:sub(1, cur_pos)) then
                      table.insert(matches, branches[i])
                    end
                  end
                  if #matches == 0 then return cmd, cur_pos end
                  while ncomp > #matches do ncomp = ncomp - #matches end

                  return matches[ncomp], cur_pos
                end})
            end
  }
  --}}}

  --{{{ vars / shifty / gittags(tm) / tag settings + bindings
  awful.doc.set_default({ group = "gittags(tm)" })
  shifty.config.tags[n] = {
    position = 9, exclusive = true,  screen = LCD, layout = awful.layout.suit.tile.bottom, spawn = spawn,
    keys  = awful.util.table.join(
              awful.key({ modkey }, "l", cmds.log, nil, "git log" ),
              awful.key({ modkey }, "d", cmds.diff, nil, "git diff"),
              awful.key({ modkey }, ".", cmds.push, nil, "git push"),
              awful.key({ modkey }, ",", cmds.pull, nil, "git pull"),
              awful.key({ modkey }, "c", cmds.commit, nil, "git commit"),
              awful.key({ modkey }, "s", cmds.status, nil, "git status"),
              awful.key({ modkey }, "w", cmds.gitweb, nil, "gitweb"),
              awful.key({ modkey }, "a", cmds.apidoc, nil, "api reference"),
              awful.key({ modkey }, "b", cmds.branch, nil, "git checkout"),
              awful.key({ modkey }, "grave", cmds.prompt, nil, "cmdline")
            ),
  }
  awful.doc.set_default({ })
  --}}}

  --{{{ vars / shifty / gittags(tm) / client settings + bindings
  awful.doc.set_default({ group = "gittags(tm) / client" })
  -- match to tags
  table.insert(shifty.config.apps,
               { match = { n.."main$", n.."cmd$", n.."pop$" }, tag = n })
  -- slave/skip_taskbar popups and commandline
  table.insert(shifty.config.apps,
               { match = { n.."cmd$", n.."pop$" }, slave = true, titlebar = true, skip_taskbar = true })
  -- popups die on 'q'
  table.insert(shifty.config.apps,
               { match = { n.."pop$" }, keys = join(awful.key({}, "q", function(c) c:kill() end, nil, "quit")), })
  -- reload main window with mod+alt+l
  table.insert(shifty.config.apps,
               { match = { n.."main$" }, keys = join(awful.key({"Mod1", modkey}, "l", function(c) c:kill(); awful.util.spawn(spawn) end, nil, "reload client")), })
  -- reload commands on mod+alt+l
  for m, f in pairs(cmds) do
    table.insert(shifty.config.apps,
               { match = { n.." git "..m },
                 keys = join(awful.key({"Mod1", modkey}, "l", function(c) c:kill(); f() end, nil, "reload client")), })
  end
  awful.doc.set_default({ })
  --}}}

end
--}}}

shifty.config.defaults = { 
    layout = "max",
    leave_kills = false,
}

shifty.config.default_name = "?"
shifty.config.layouts = layouts
shifty.init()
--}}}

--{{{ vars / naughty
naughty.config.spacing = 1
naughty.config.default_preset = {
  font = 'Monospace 6.5',
  border_width = 1,
  margin = 5,
  screen = LCD,
  opacity = 0.95,
}
--}}}

--{{{ vars / widgets
config.widgets = {}
config.widgets.watchmount = { "/dev/sda2", "/media/", "/mnt/" }
config.widgets.autostart = {
  photo = "gq %f",
  movies = "urxvtc -name mc -geometry 169x55 -e mc %f ~/data/tmp", 
  default = "urxvtc -name mc -geometry 169x55 -e mc %f"
}
config.widgets.space = "   "
config.widgets.wifi = "wlan1"
--}}}

--{{{ vars / logwatch
config.logs = {
  aptitude  = { file = "/var/log/aptitude", },
  mpd       = { file = "/home/koniu/.mpd/mpd.log",
                subst = {
                  ["^.- %d%d:%d%d : "] = "", -- cut out syslog's date/hostname prefix
                },
  },
  syslog    = { file = "/var/log/syslog",
                ignore = {
                  "Changing fan level",
                  "CRON",
  --                "MAC",
                  "IPv6",
                },
                subst = {
                  ["^.- %d%d:%d%d:%d%d %w- "] = "", -- cut out syslog's date/hostname prefix
                  ["%[%d%d%d%d%d%d+%.%d%d%d%d%d%d%] "] = "", -- cut out kernel's timestamp
                },
                color = {
                  ["%d+%.%d+%.%d+%.%d+"] = "#e0e0e0", -- highlight ipv4 addresses
                  ["%w+:%w+:%w+:%w+:%w+:%w+"] = "#e0c0c0", -- highlight macs
                  [" [Aa]dd%w- "] = "#99cc99",
                  [" [Nn]ew "] = "#99cc99",
                  [" [Rr]emov%w- "] = "#cc9999",
                  [" [Ee]rr%w- "] = "#ff9999",
                  [" [Tt]imeout "] = "#ff9999",
                  ["%w-="] = "#666666",
                  ["^%w-:"] = "#9999B6",
                  [" .-: "] = "#B6B099",
                },
                quiet = false,
  },
  awesome   = { file = "/home/koniu/log/awesome",
                ignore = {
                  "/var/lib/dpkg", -- aptwidget failure when aptitude running
                  "seek to:", "Close unzip stream", "pos is: ", "Image won't fit",  -- mpd/gmpc junk
                  "geeqie", "LIRC", -- geeqie junk
                  "gimp",
                  "^nolog",
                  "deprecate"
                },
                quiet = false
  },
}
config.logs_quiet = true
--}}}

--}}}

--{{{ functions

--{{{ functions / run_or_raise
function run_or_raise(cmd, properties)
   local clients = client.get()
   for i, c in pairs(clients) do
      if match(properties, c) then
         local ctags = c:tags()
         if table.getn(ctags) == 0 then
            -- ctags is empty, show client on current tag
            local curtag = awful.tag.selected()
            awful.client.movetotag(curtag, c)
         else
            -- Otherwise, pop to first tag client is visible on
            awful.tag.viewonly(ctags[1])
         end
         -- And then focus the client
         client.focus = c
         c:raise()
         return
      end
   end
   awful.util.spawn_with_shell(cmd)
end
--}}}

--{{{ functions / match
-- Returns true if all pairs in table1 are present in table2
function match (table1, table2)
   for k, v in pairs(table1) do
      if table2[k] ~= v then
         return false
      end
   end
   return true
end
--}}}

--{{{ functions / scrollclient
-- scrolling clients bigger than workspace
function scrollclient()
  local c = client.focus
  if not c then return end

  local ss = screen[c.screen].geometry
  local ws = awful.wibox.get_workarea(c.screen)
  local cc = c:geometry()
  local mc = mouse.coords()
  local step = 0

  -- left edge
  if mc.x < config.scroll_offset and cc.x < 0 then
    step = math.min(config.step, -cc.x)
    awful.client.moveresize(step,0,0,0,c)
  end

  -- right edge
  if mc.x > ws.width - config.scroll_offset and cc.x + cc.width > ws.width + 1 then
    step = math.min(config.step, cc.x + cc.width-ws.width)
    awful.client.moveresize(-step,0,0,0,c)
  end

  -- top edge
  if mc.y < config.scroll_offset and cc.y < ss.height - ws.height then
    step = math.min(config.step, ss.height - ws.height - cc.y - 1) -- FIXME: -1 is for the frame to hide under panels BROKEN
    awful.client.moveresize(0,step,0,0,c)
  end

  -- bottom edge
  if mc.y > ws.height - config.scroll_offset and cc.y + cc.height > ss.height then
    step = math.min(config.step, cc.y + cc.height - ss.height)
    awful.client.moveresize(0,-step,0,0,c)
  end
end
--}}}

--{{{ functions / lua completion
function lua_completion (line, cur_pos, ncomp)
   -- Only complete at the end of the line, for now
   if cur_pos ~= #line + 1 then
      return line, cur_pos
   end

   -- We're really interested in the part following the last (, [, comma or space
   local lastsep = #line - (line:reverse():find('[[({, ]') or #line)
   local lastidentifier
   if lastsep ~= 0 then
      lastidentifier = line:sub(lastsep + 2)
   else
      lastidentifier = line
   end

   local environment = _G

   -- String up to last dot is our current environment
   local lastdot = #lastidentifier - (lastidentifier:reverse():find('.', 1, true) or #lastidentifier)
   if lastdot ~= 0 then
      -- We have an environment; for each component in it, descend into it
      for env in lastidentifier:sub(1, lastdot):gmatch('([^.]+)') do
         if not environment[env] or type(environment[env]) ~= "table" then
            -- Oops, no such subenvironment, bail out
            return line, cur_pos
         end
         environment = environment[env]
      end
   end

   local tocomplete = lastidentifier:sub(lastdot + 1)
   if tocomplete:sub(1, 1) == '.' then
      tocomplete = tocomplete:sub(2)
   end

   local completions = {}
   for k, v in pairs(environment) do
      if type(k) == "string" and k:sub(1, #tocomplete) == tocomplete then
         table.insert(completions, k)
      end
   end

   if #completions == 0 then
      return line, cur_pos
   end

   table.sort(completions)
   while ncomp > #completions do
      ncomp = ncomp - #completions
   end

   local str = ""
   if lastdot + lastsep ~= 0 then
      str = line:sub(1, lastsep + lastdot + 1)
   end
   str = str .. completions[ncomp]
   cur_pos = #str + 1
   return str, cur_pos
end
--}}}

--{{{ functions / terminal
-- runs terminal
function terminal(args)
  local args = args or ' -title "ba:~"'
  awful.util.spawn(config.terminal .. ' ' .. args, false)
end
--}}}

--{{{ functions / splitbywhitespace
function splitbywhitespace(str)
    values = {}
    start = 1
    splitstart, splitend = string.find(str, ' ', start)
    
    while splitstart do
        m = string.sub(str, start, splitstart-1)
        if m:gsub(' ','') ~= '' then
            table.insert(values, m)
        end

        start = splitend+1
        splitstart, splitend = string.find(str, ' ', start)
    end

    m = string.sub(str, start)
    if m:gsub(' ','') ~= '' then
        table.insert(values, m)
    end

    return values
end
--}}}

--{{{ functions / taginfo
function ti()
  local t = awful.tag.selected()
  local v = ""

  v = v .. "<span font_desc=\"Verdana Bold 20\">" .. t.name .. "</span>\n"
  v = v .. tostring(t) .. "\n\n"
  v = v .. "clients: " .. #t:clients() .. "\n\n"

  local i = 1
  for op, val in pairs(awful.tag.getdata(t)) do
    if op == "layout" then val = awful.layout.getname(val) end
    if op == "keys" then val = '#' .. #val end
    v =  v .. string.format("%2s: %-12s = %s\n", i, op, tostring(val))
    i = i + 1
  end

	naughty.notify{ text = v:sub(1,#v-1), timeout = 0, margin = 10 }
end
--}}}

--{{{ functions / clientinfo
function ci()
  local v = ""

  -- object
  local c = client.focus
  v = v .. tostring(c)

  -- geometry
  local cc = c:geometry()
  local signx = (cc.x >= 0 and "+")
  local signy = (cc.y >= 0 and "+")
  v = v .. " @ " .. cc.width .. 'x' .. cc.height .. signx .. cc.x .. signy .. cc.y .. "\n\n"

  local inf = {
    "name", "icon_name", "type", "class", "role", "instance", "pid",
    "icon_name", "skip_taskbar", "id", "group_id", "leader_id", "machine",
    "screen", "hide", "minimize", "size_hints_honor", "titlebar", "urgent",
    "focus", "opacity", "ontop", "above", "below", "fullscreen", "transient_for"
   }

  for i = 1, #inf do
    v =  v .. string.format("%2s: %-16s = %s\n", i, inf[i], tostring(c[inf[i]]))
  end

  naughty.notify{ text = v:sub(1,#v-1), timeout = 0, margin = 10 }
end
--}}}

--{{{ functions / widgettext
-- format widget output
function widgettext(label, value, labelcolor, valuecolor)
	local lc = labelcolor or beautiful.widget_label
	local vc = valuecolor or beautiful.widget_value
	return 	'<span color="' .. lc .. '">' .. label .. ' </span><span color="' .. vc .. '">'  .. value .. '</span>' .. config.widgets.space
end
--}}}

--{{{ functions / islidclosed
function islidclosed()
  if true then return false end
	local f = io.open("/proc/acpi/button/lid/LID/state")
	local state = f:read()
	f:close()
	if state:find("closed") then
		return true
	else
		return false
	end
end
lidclosed = islidclosed()
--}}}

--{{{ functions / sendkey
fakekeys = {}
function sendkey(codes)
  local f = function()
    for i = 1, #codes do root.fake_input("key_press", codes[i]) end
    for i = #codes, 1, -1 do root.fake_input("key_release", codes[i]) end
    awful.hooks.timer.unregister(fakekeys[1])
    table.remove(fakekeys, 1)
  end
  table.insert(fakekeys, f)
  awful.hooks.timer.register(0.05, f)
end
--}}}

--{{{ functions / utficon
function utficon(code)
	return 	'<span font_desc="DejaVu Sans 8">&#' .. code .. ';</span>'
end
--}}}

--{{{ functions / logwatch
function log_watch()
  if not inot then return end
  local events, nread, errno, errstr = inot:nbread()
  if events then
    for i, event in ipairs(events) do
      for logname, log in pairs(config.logs) do
        if event.wd == log.wd then log_changed(logname) end
      end
    end
  end
end

function log_changed(logname)
  local log = config.logs[logname]
  local text = ""

  -- open the file and seek to previous length
  local f = io.open(log.file)
  f:seek("set", log.len)

  -- read new lines into a table
  local lines = {}
  if log.len then
    for line in f:lines() do table.insert(lines, line) end
  end

  -- remember length and close file
  log.len = f:seek("end")
  f:close()

  for _, l in ipairs(lines) do
    -- check if ignored
    local ignored = false
    for i, phr in ipairs(log.ignore or {}) do
      if l:find(phr) then ignored = true; break end
    end

    if not ignored and not log.quiet and not config.logs_quiet then

      -- escape string
      l = awful.util.escape(l)

      -- make substitutions
      if log.subst then
        for from, to in pairs(log.subst) do l = l:gsub(from, to) end
      end
     
      -- wrap lines if too long
      l = awful.util.linewrap(l, 80, l:find(" "))

      -- colorize
      if log.color then
        for match, color in pairs(log.color) do 
          l = l:gsub(match, "<span color='"..color.."'>%1</span>")
        end
      end

      text = text .. l .. "\n"
    end
  end

  -- display log updates
  if #text > 0 then
    naughty.notify{
      title = '<span color="white">' .. logname .. "</span>: " .. log.file,
      text = text:sub(1, #text-1),
      hover_timeout = 0.2, timeout = 0,
    }
  end
end

local errno, errstr
inot, errno, errstr = inotify.init(true)
if not inot then
  naughty.notify{text = "Failed to initialize inotify: " .. errstr }
else
  for logname, log in pairs(config.logs) do
    log_changed(logname)
    log.wd, errno, errstr = inot:add_watch(log.file, { "IN_MODIFY" })
  end
end
--}}}

--{{{ functions / getclient
function getclient(prop, val)
  for i, c in ipairs(client.get()) do
    if c[prop] == val then
      return c
    end
  end
end
--}}}

--{{{ functions / popterm
function popterm()
  local c = getclient("instance", "popterm")
  if not c then
    terminal("-name popterm -font 6x10")
  elseif c.minimized then
    c.minimized = false
    client.focus = c
    c:raise()
  else
    c.minimized = true
  end
end
--}}}

--{{{ functions / restore_focus
function restore_focus(screen, cli)
  if not client.focus or not client.focus:isvisible() then
    local c = awful.client.focus.history.get(screen, 0)
    if c and cli ~= c then client.focus = c end
  end
end
--}}}

--{{{ functions / prompt
prompt = require("obvious.popup_run_prompt")
function prompt.exec(preset)
  prompt.settings = awful.util.table.join(prompt.defaults, prompt.presets.default, preset)
  prompt.run_prompt()
end
--}}}

--{{{ functions / kill
function kill(line)
  local name,pid,sig = line:match("(%a+) (%d+).-(.*)")
  awful.util.spawn("kill " .. (sig or "") .. " " .. pid, false)
end

function kill_completion(cmd, cur_pos, ncomp)
  local ps = {}
  local g = io.popen("ps hxuc")
  for line in g:lines() do
    local out = splitbywhitespace(line)
    table.insert(ps, out[11] .. " " .. out[2])
  end
  g:close()

  if cur_pos ~= #cmd + 1 and cmd:sub(cur_pos, cur_pos) ~= " " then return cmd, cur_pos end

  local matches = {}
  for i, j in ipairs(ps) do
    if ps[i]:find("^" .. cmd:sub(1, cur_pos)) then table.insert(matches, ps[i]) end
  end

  if #matches == 0 then return cmd, cur_pos end
  table.sort(matches)
  while ncomp > #matches do ncomp = ncomp - #matches end

  -- return match and position
  return matches[ncomp], cur_pos
end
--}}}

--{{{ functions / calculator
function calculator(expr)
  val = awful.util.eval("return " .. expr)
  local calc = naughty.notify({
    text = expr .. ' = <span color="white">' .. val .. "</span>",
    timeout = 0,
    run = function(n)
      n.die()
      awful.util.spawn_with_shell("echo ".. n.val .. " | xsel -i")
    end,
  })
  calc.val = val
end
--}}}

--{{{ functions / dictionary
function dictionary(word)
  local fr = awful.util.pread("dict -d wn " .. word .. " 2>&1")
  naughty.notify({ text = '<span font_desc="Sans 7">'..fr..'</span>', timeout = 0 })
end
--}}}

--}}}

--{{{ vars / obvious / prompts
prompt.presets = {

  default = {
    position = "top",
    width = 1, height = 35, border_width = 0, opacity = 0.9, margin = { top = 12, left = 12 },
    slide = true, move_speed = 0.003, move_amount = 1,
  },

  run =  {
    completion_function = awful.completion.shell,
    run_function = function(s) local rv = awful.util.spawn(s, true); if rv then naughty.notify({ text = awful.util.escape(rv) }) end end,
    history = os.getenv("HOME") .. "/.cache/awesome/history",
    args = { prompt = "<span color='orange'>Run</span>: ", fg_cursor = "orange",
             bg_cursor = beautiful.bg_normal, ul_cursor = "single", },
  },

  lua = {
    completion_function = lua_completion,
    run_function = function(s) local r, msg = pcall(awful.util.eval, s); if not r then naughty.notify({ text = awful.util.escape(msg) }) end end,
    history = os.getenv("HOME") .. "/.cache/awesome/history_eval",
    args = { prompt = "<span color = '#D1FF00'>Lua</span>: ", fg_cursor = "#D1FF00",
             bg_cursor = beautiful.bg_normal, ul_cursor = "single", },
  },

  calc = {
    completion_function = lua_completion,
    run_function = calculator,
    history = os.getenv("HOME") .. "/.cache/awesome/history_calc",
    args = { prompt = "<span color='#00A5AB'>Calc</span>: ", fg_cursor = "#00A5AB",
             bg_cursor = beautiful.bg_normal, ul_cursor = "single", selectall = true, },
  },

  dict = {
    completion_function = function() return end,
    run_function = dictionary,
    history = os.getenv("HOME") .. "/.cache/awesome/history_dict",
    args = { prompt = "<span color='#008DFA'>Dict</span>: ", fg_cursor = "#008DFA", 
             bg_cursor = beautiful.bg_normal, ul_cursor = "single", selectall = true, },
  },

  kill = {
    completion_function = kill_completion,
    run_function = kill,
    history = "",
    args = { prompt = "<span color='#FF4F4F'>Kill</span>: ", fg_cursor = "#FF4F4F", 
             bg_cursor = beautiful.bg_normal, ul_cursor= "single", },
  },

}
--}}}

--{{{ widgets

--{{{ widgets / wifi
function dump_autoap()
	os.execute('curl -s http://gw/user/autoap.htm  > /tmp/.awesome.autoap &')
end

function show_netpopup()
  naughty.destroy(netpopup)
  local iwconfig = awful.util.pread("/sbin/iwconfig " .. config.widgets.wifi)
  local ifconfig = awful.util.pread("/sbin/ifconfig " .. config.widgets.wifi)
  local route = awful.util.pread("/bin/ip route")
  local iwgetid = awful.util.pread("/sbin/iwgetid -c")

  local start, endd = iwconfig:find('".*"')
  if not start or not endd then return end
  local essid = iwconfig:sub(start+1, endd-1)

  start, endd = iwconfig:find("Rate.* Mb/s")
  if not start or not endd then return end
  local rate = iwconfig:sub(start+5,endd-5)

  local start, endd = ifconfig:find("inet addr:.* Bcast")
  if not start or not endd then return end
  local ip = ifconfig:sub(start+10, endd-5)

  local start, endd = route:find("via %d+%.%d+%.%d+%.%d+ dev " .. config.widgets.wifi)
  if not start or not endd then return end
  local gw = route:sub(start+4,endd-9)

  local start, endd = iwgetid:find("Channel:%d+")
  if not start or not endd then return end
  local channel = iwgetid:sub(start+8,endd)

  local autoap = get_autoap()
  netpopup = naughty.notify({ text = "<b>essid: </b>" .. essid .. " (channel " .. channel .. ", " .. rate .. " mbps" .. ")\n" ..
    ((autoap and ("<b>autoap essid: </b>" .. autoap.ap .. "\n")) or "") ..
    ((autoap and ("<b>autoap gw: </b>" .. autoap.gw .. "\n")) or "" ) ..
    ((autoap and ("<b>autoap packet loss: </b>" .. autoap.loss .. "\n")) or "" ) ..
    "<b>ip: </b>" .. ip .. "\n" ..
    "<b>gw: </b>" .. gw,
    timeout = 5, hover_timeout = 0.2 })
end


function get_autoap()
   local ap = ""
   local f = io.open('/tmp/.awesome.autoap')
   if not f then return end
   local line = f:read("*a")
   f:close()
   if not line then return end

   local aar, beg = line:find('<title>')
   if not aar or not beg then return end
   if line:sub(beg+32, beg+32) == 'S' then ap = "<span color=\"#FF602E\">searching...</span>" 
   elseif line:sub(beg+32,beg+32) == 'C' then 
	   endd = line:find('</title>', beg) 
	   ap = line:sub(beg+47,endd-2)
   end


   local start, endd = line:find("rescanning%. %d+%% packet loss")
   if not start or not endd then return end
   local loss = line:sub(start+12,endd-12)
   
   if last_ap and ap ~= last_ap then naughty.notify({title = "AutoAP network", text = ap, timeout = 10})
   last_ap = ap end
   return { ap = ap, loss = loss, gw = gw}
end

local function get_wifi()
	local v = ''
	local a = io.open('/sys/class/net/'..config.widgets.wifi..'/wireless/link')

  if not a then
    netup = nil
    return '<span color="#D9544C">off</span>'
  end
  v = math.floor(a:read() / 0.7)
	a:close()
	if v == "0" then 
		  v = '<span color="#D9544C">down</span>'
		  netup = nil 
	else 
		  v = v .. '%'
	 	  netup = 1 
	end
	return v 
end

wifiwidget = widget({
	type = 'textbox',
	name = 'wifiwdget'
})

wifiwidget.buttons = join(
  awful.button({}, 1, function () run_or_raise("wicd-client -n >& /dev/null", { class = "Wicd-client.py" } )  end, nil, "show networks"),
  awful.button({}, 2, show_netpopup, nil, "show autoap status"),
  awful.button({}, 3, function () terminal("-name iwconfig -e watch -n1 /sbin/iwconfig "..config.widgets.wifi) end, nil, "show iwconfig")
)

wifiwidget.mouse_enter = function() show_netpopup() end
wifiwidget.mouse_leave = function() naughty.destroy(netpopup) end

awful.doc.set(wifiwidget, { class = "widgets", description = "This widget shows WIFI range", name = "wifiwidget" })

--}}}

--{{{ widgets / net
netwidget = widget({
	type = 'textbox',
	name = 'netwidget',

})
netwidget.buttons = join(
  awful.button({}, 3, function () terminal("-name fping -e fping -le 10.6.6.1 google.com") end),
  awful.button({}, 1, function () terminal("-name mtr -e mtr google.com") end)
)
netwidget.width = 100

function get_net()
	return wicked.widgets.net()
end
--}}}

--{{{ widgets / cpugraph 
cpugraphwidget = widget({
	type = 'graph',
	name = 'cpugraphwidget',
	align = 'left'
})
cpugraphwidget.buttons = join(
  awful.button({}, 3, function () terminal("-name top -e top") end),
  awful.button({}, 1, function () terminal("-name htop -e htop --sort-key PERCENT_CPU") end)
)

cpugraphwidget.height = 0.85
cpugraphwidget.width = 40
cpugraphwidget.bg = '#000000'
cpugraphwidget.border_color = '#000000'
cpugraphwidget.grow = 'right'

cpugraphwidget:plot_properties_set('cpu', {
--    fg = '#6E6958',
    fg = '#252020',
--    fg_center = '#285577',
--    fg_end = '#634141',
    vertical_gradient = true
})

awful.doc.set(cpugraphwidget, "cpugraph")
--}}}

--{{{ widgets / battery 
batterywidget = widget({
	type = 'textbox',
	name = 'batterywidget',
	align = 'right'
})


local function get_bat()
	local color = 'orange'
	local v = ''
	local a = io.open('/sys/class/power_supply/BAT0/status')
  if not a then return end
	local status = a:read()
	a:close()
	local b = io.open('/sys/class/power_supply/BAT0/current_now')
	local current = b:read()
	b:close()
	if status == "Full" or tonumber(current) == 0 then 
    v = ''
	else
		local a = io.open('/sys/class/power_supply/BAT0/energy_full')
		local full = a:read()
		a:close()
		local a = io.open('/sys/class/power_supply/BAT0/energy_now')
		local now = a:read()
		a:close() 

		bat = math.floor(now*100/full)
		
		if status == "Discharging" then 
			if 	bat < 11 then color="#D9544C"
			elseif 	bat < 31 then color="#D9A24C"
			else 		      color="#D9CD4C"
			end
		elseif status == "Charging" then color="#ABD94C"
		end
		
		v = widgettext('BAT', bat .. '%',nil,color)
	end

	return v 
end
--}}}

--{{{ widgets / memgraph
memgraphwidget = widget({
	type = 'graph',
	name = 'memgraphwidget',
	align = 'left'
})
memgraphwidget.buttons = join(
  awful.button({}, 3, function () terminal("-name top -e top") end),
  awful.button({}, 1, function () terminal("-name htop -e htop --sort-key PERCENT_MEM") end)
)

memgraphwidget.height = 0.85
memgraphwidget.width = 40
memgraphwidget.bg = '#000000'
memgraphwidget.border_color = '#000000'
memgraphwidget.grow = 'right'

memgraphwidget:plot_properties_set('cache', {
    fg = '#0F120F',
    vertical_gradient = false
})


memgraphwidget:plot_properties_set('used', {
--    fg = '#6E6958',
    fg = '#202520',
--    fg_center = '#285577',
--    fg_end = '#285577',
    vertical_gradient = false
})


function get_mem()
    -- Return MEM usage values
    local f = io.open('/proc/meminfo')

    ---- {{ Get data
    for line in f:lines() do
        line = splitbywhitespace(line)

        if line[1] == 'MemTotal:' then
            mem_total = math.floor(line[2]/1024)
        elseif line[1] == 'MemFree:' then
            free = math.floor(line[2]/1024)
        elseif line[1] == 'Buffers:' then
            buffers = math.floor(line[2]/1024)
        elseif line[1] == 'Cached:' then
            cached = math.floor(line[2]/1024)
        end
    end
    f:close()

    ---- {{ Calculate percentage
    mem_free=free+buffers+cached
    mem_inuse=mem_total-mem_free

    mem_usepercent = math.floor(mem_inuse/mem_total*100)
    mem_cache_percent = math.floor((cached+buffers)/mem_total*100)

    return {mem_usepercent, mem_cache_percent, mem_total, mem_free}
end
--}}}

--{{{ widgets / cputemp
cputempwidget = widget({
    type = 'textbox',
    name = 'cputempwidget',
    align = 'left',
})

local function get_cputemp()
	local f = io.open('/sys/class/hwmon/hwmon1/device/temp1_input')
	local v = f:read() / 1000
	f:close()
	return v
end
--}}}

--{{{ widgets / fan
fanwidget = widget({
    type = 'textbox',
    name = 'fanwidget',
    align = 'left',
})


local function get_fan()
	local f = io.open('/sys/class/hwmon/hwmon1/device/fan1_input')
	local v = f:read()
	f:close()
	return v
end
--}}}

--{{{ widgets / mounts 				FIXME: very dirty
function get_mounts()
   local v = {}
   local f = io.open('/tmp/.awesome.df')
   if not f then return end
   local l = f:lines() 
   for line in l do
   	for p,q in pairs(config.widgets.watchmount) do
		if line:find(q) ~= nil then 
			local tmp = {}
   	         	for id in line:gmatch("%S+") do table.insert(tmp,id) end
			if #tmp > 6 then tmp[6]=tmp[6]..' '..tmp[7] end -- hack: space in mountpoint
			table.insert(v,{tmp[6], tmp[4], q})
		end
	end

   end
   f:close()
   return v
end

function dump_mounts()
	os.execute('df -h > /tmp/.awesome.df &')
end

function mountlist()
    local w = { layout = awful.widget.layout.horizontal.rightleft }

    local function update()
        local mnts = get_mounts()
        if not mnts or #mnts == 0 then return end
        local len = w.len or #w
        -- Add more widgets
        if len < #mnts then
            for i = len + 1, #mnts do
                w[i] = widget({ type = "textbox", align = "right" })
                awful.doc.set(w[i], { name = "mountwidget", description = "Mount widget", class = "widgets" })
            end
        -- Remove widgets
        elseif len > #mnts then
            for i = #mnts + 1, len do
                w[i] = nil
            end
        end
        -- Update widgets text
        for i,mnt in ipairs(mnts) do
            local tmp = {}
            local esc=string.gsub(mnt[1],' ','\\ ')
            w[i].text = mnt[1]:gsub(mnt[3],''):upper() ..
                       '<span color="' .. beautiful.widget_value .. '">' .. mnt[2] .. '</span>' ..
                        config.widgets.space
			
            w[i].buttons = join(

              awful.button({}, 1,
              function ()
                local action
                for m, spwn in pairs(config.widgets.autostart) do
                  if mnt[1]:lower():find(m) then
                    action = spwn
                    break
                  end
                end
                if not action then action = config.widgets.autostart.default end
                action = action:gsub("%%f", esc)
                awful.util.spawn_with_shell(action)
              end, nil, "Open"),

              awful.button({}, 2,
              function ()
                local action = config.widgets.autostart.default
                action = action:gsub("%%f", esc)
                awful.util.spawn_with_shell(action)
              end, nil, "Browse"),

              awful.button({}, 3,
              function ()
                awful.util.spawn("eject " .. esc, false)
                awful.util.spawn("pumount " .. esc, false)
                --awful.util.spawn("pumount -l " .. esc)
              end, nil, "Unmount")

            )
        end
    end
    awful.hooks.timer.register(1, update)
    update()
    return w
end
mountwidget = mountlist()
--}}}

--{{{ widgets / mail
mailwidget = widget({ type = "textbox", name = "mailwidget", align = "right"})

mailwidget.buttons = join(
  awful.button({ }, 1, function () awful.util.spawn('firefox http://gmail.com'); awful.tag.viewonly(shifty.name2tag('www')) end)
)

function get_mail()
   local f = io.open('/tmp/.awesome.mail')
   if not f then return end
   local count = f:read()
   f:close()
   if not count then return end
--   local inbox, lists = count:match( ("([^".." ".."]*)".." "):rep(2) )
--    dbg{count, inbox, lists}
   local inbox, lists = count:match("(%d+) (%d+)")
--   dbg{count,inbox,lists}
   if not inbox or not lists then return end
   local text = ''
   if tonumber(inbox) > 0 then text = text .. widgettext('MAIL', inbox, nil, "#99C399")  end
   if tonumber(lists) > 0 then text = text .. widgettext('LIST', lists, nil, "#99C399")  end
   mailwidget.text = text
end

function dump_mail()
--	os.execute('python ~/bin/gmail.py > /tmp/.awesome.mail &')
end
--}}}

--{{{ widgets / apt
aptwidget = widget({ type = "textbox", name = "aptwidget", align="right"})

aptwidget.buttons = join(
  awful.button({ }, 1, function () terminal("-name apt -geometry 169x55 -title aptitude -e sudo aptitude") end)
)

function get_apt()
  local f = io.open('/tmp/.awesome.apt')
  if not f then return end
  local apt = f:read()
  f:close()
  if not apt then return end
  if tonumber(apt) > 0 then
    aptwidget.text  = widgettext('APT', apt  , nil, '#99C399' )
  else 
    aptwidget.text = ''
  end
end

function dump_apt()
	os.execute("sudo apt-get upgrade -s | grep upgraded | tail -n1 | awk '{ print $1 }' > /tmp/.awesome.apt &")
end
--}}}

--{{{ widgets / clock
clockwidget = widget({ type = "textbox", })
awful.doc.set(clockwidget, { description = "System time", class = "widgets", name = "clockwidget" })

calendar = nil
local offset = 0 

function remove_calendar()
        if calendar ~= nil then
            naughty.destroy(calendar)
            calendar = nil
            offset = 0
        end
end

function showcalendar(inc_offset) 
        local save_offset = offset
        remove_calendar()
        if inc_offset == 666 then
                offset = 0
        else 
                offset = save_offset + inc_offset
        end
        local datespec = os.date("*t")
        datespec = datespec.year * 12 + datespec.month - 1 + offset
        datespec = (datespec % 12 + 1) .. " " .. math.floor(datespec / 12)
        local cal = awful.util.pread("cal -m " .. datespec)
        cal = string.gsub(cal, "^%s*(.-)%s*$", "%1")
        calendar = naughty.notify({ 
                    text = os.date("<b><span color=\"white\">%a, %d %B %Y</span></b>\n\n") .. cal, 
                    timeout = 0, hover_timeout = 0.5,
        })
end

clockwidget.buttons = join(
  awful.button({ }, 1, function () showcalendar(-1) end, nil, "Show previous month"),
  awful.button({ }, 2, function () showcalendar(666) end, nil, "Show current month"),
  awful.button({ }, 3, function () showcalendar(1) end, nil, "Show next month"),
  awful.button({ }, 4, function () showcalendar(-1) end, nil, "Show previous month"),
  awful.button({ }, 5, function () showcalendar(1) end, nil, "Show next month")
)

clockwidget.mouse_enter = function() showcalendar(0) end
clockwidget.mouse_leave = function () remove_calendar() end
--}}}

--{{{ widgets / systray
mysystray = widget({ type = "systray", name = "mysystray", align = "right" })
--}}}

--{{{ widgets / layoutbox
mylayoutbox = {}
for s = 1, screen.count() do
  mylayoutbox[s] = awful.widget.layoutbox(s, { })
  mylayoutbox[s].image = img
  mylayoutbox[s].resize = false
  mylayoutbox[s].buttons = join(
    awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
    awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
    awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
    awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)
  )
end
--}}}

--{{{ widgets / separators

-- separator widgets
sep_l = widget({
	type = 'textbox',
	align = 'left',
})
sep_l.text='<span font_desc="verdana 4"> </span>'

sep_r = widget({
	type = 'textbox',
	name = 'sep_r',
	align = 'right',
})
sep_r.text='       '
--}}}

--{{{ widgets / hook functions
function hook_1s()
  log_watch()
	local color,color2=''
	if lidclosed then return end

	cpugraphwidget:plot_data_add('cpu',wicked.widgets.cpu()[1])
	
	local a = get_mem()
	memgraphwidget:plot_data_add('used',a[1])
	memgraphwidget:plot_data_add('cache',a[1]+a[2])

	cputempwidget.text 	= widgettext('CPU', get_cputemp() .. '°C')
	fanwidget.text		= widgettext('FAN', string.format("%-4s",get_fan()))
	wifiwidget.text		= widgettext('WIFI', get_wifi())

	if netup then
	local b = wicked.widgets.net()
	if b['{'..config.widgets.wifi.. ' down_kb}'] > 0 then color = beautiful.widget_value; color = beautiful.widget_value else color = '#333333' end
	if b['{'..config.widgets.wifi.. ' up_kb}'] > 0 then color2 = beautiful.widget_value else color2 = '#333333' end
		netwidget.text = widgettext('NET', string.format('%3s <span color="#333333">/</span> %-3s', b['{'..config.widgets.wifi..' down_kb}'], b['{'..config.widgets.wifi.. ' up_kb}']), nil, color2)
	else 
		netwidget.text = ''
	end
	clockwidget.text = (rec or "") .. "<span font_desc='' color='#cccccc'>" .. os.date("%H<span color='#999999'>:</span>%M<span color='#999999'>:</span>%S") .. "</span> "
end
hook_1s()

function hook_3s ()
--	if lidclosed then return end
	dump_mounts()
	get_mounts()
end
hook_3s()

function hook_5s ()
	if lidclosed then return end
	batterywidget.text = get_bat()
--	get_mail()
	get_apt()
	dump_autoap()
	get_autoap()
end
hook_5s()

function hook_1m ()
	lidclosed = islidclosed()
	if lidclosed then return end
--	dump_mail()
end

function hook_10m ()
	dump_apt()
end
--}}}

--}}}

--{{{ panels 

--{{{ panels / widget
widgetbar = {}
for s = LCD, screen.count() do
  widgetbar[s] = awful.wibox({ position = "top", name = "widgetbar" .. s, screen = s,
                               fg = beautiful.fg_normal, bg = beautiful.bg_normal, height = 16 })
  widgetbar[s].widgets = {

    {
      sep_l,
      memgraphwidget,
      sep_l,
      cpugraphwidget,
      sep_l, sep_l, sep_l, sep_l,
      cputempwidget,
      fanwidget,
      wifiwidget,
      netwidget,
      layout = awful.widget.layout.horizontal.leftright,
    },

    clockwidget,
    sep_l, sep_l, sep_l, sep_l,
    sep_l, sep_l, sep_l, sep_l,
    mysystray,
    batterywidget,
    aptwidget,
    sep_r,
    mountwidget,
    --mailwidget,
    layout = awful.widget.layout.horizontal.rightleft,

  }

  awful.doc.set(widgetbar[s], { name = "widgetbar", class = "panels", description = "Panel with widgets" })
end
--}}}

--{{{ panels / separator
separatorbar = {}
for s = 1, screen.count() do
  separatorbar[s] = awful.wibox({ position = "top", name = "separatorbar" .. s,
                                  bg = beautiful.bg_normal, height = 3, screen = s })
end
--}}}

--{{{ panels / taglist+tasklist
mytaglist = {}
mytaglist.buttons = join(
  awful.button({ }, 1, awful.tag.viewonly, nil, "Switch to tag"),
  awful.button({ modkey }, 1, awful.client.movetotag, nil, "Move client to tag"),
  awful.button({ }, 3, function (tag) tag.selected = not tag.selected end, nil, "Toggle tag"),
  awful.button({ modkey }, 3, awful.client.toggletag, nil, "Toggle client on tag"),
  awful.button({ }, 4, awful.tag.viewnext, nil, "Switch to next tag"),
  awful.button({ }, 5, awful.tag.viewprev, nil, "Switch to previous tag")
)
mytasklist = {}
mytasklist.buttons = join(
  awful.button({ }, 1, function (c)
    if not c:isvisible() then awful.tag.viewonly(c:tags()[1]) end
    client.focus = c
    c:raise()
    end, nil, "Focus client"),
  awful.button({ }, 2, function ()
    if instance then
      instance:hide(); instance = nil
    else
      instance = awful.menu.clients({ width=250 })
    end
    end, nil, "Show menu with all clients"),
  awful.button({ }, 3, function (c) c.minimized = true end, nil, "Minimize client"),
  awful.button({ }, 4, function ()
    awful.client.focus.byidx(1)
    if client.focus then client.focus:raise() end
    end, nil, "Focus next client"),
  awful.button({ }, 5, function ()
    awful.client.focus.byidx(-1)
    if client.focus then client.focus:raise() end
    end, nil, "Focus previous client")
  )

mytagprompt = {}

for s = 1, screen.count() do
  -- Create a tag prompt widget
  mytagprompt[s] = widget({	type = 'textbox', })

  -- Create a taglist widget
  mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)
  awful.doc.set(mytaglist[s], { name = "mytaglist", class = "widgets", description = "Taglist widget" })

  -- Create a tasklist widget
  mytasklist[s] = awful.widget.tasklist(
    function(c)
	    local text, bg, status_image, icon = awful.widget.tasklist.label.currenttags(c, s)
      if not config.tasklist_noicons then
        return text, bg, status_image, icon
      else
        return text, bg, status_image
      end
    end,
  mytasklist.buttons)
  awful.doc.set(mytasklist[s], { name = "mytasklist", class = "widgets", description = "Tasklist widget" })
end
shifty.taglist = mytaglist

tabbar = {}
for s = 1, screen.count() do
  tabbar[s] = awful.wibox({ position = "top", name = "tabbar" .. s, screen = s,
                            fg = beautiful.fg_normal, bg = beautiful.bg_normal })
  tabbar[s].widgets = {
    mytaglist[s],
    mytagprompt[s],
    sep_l,
    mylayoutbox[s],
    sep_l,
    mytasklist[s],
    layout = awful.widget.layout.horizontal.leftright
  }
  awful.doc.set(tabbar[s], { name = "tabbar", class = "panels", description  = "Panel with tag/task-list" })
end
-- }}}

--}}}

-- {{{ bindings 

-- {{{ bindings / global
globalkeys = join(

-- {{{ bindings / global / spawns
  
  awful.doc.set_default({ group = "1. global actions" }),

  awful.key({ }, "KP_Insert",         function() sendkey({23}) end),
  awful.key({ modkey            }, "F1",          awful.help.run, nil, "help mode"),
  awful.key({ modkey            }, "slash",       awful.help.promptline, nil, "help prompt"),
  awful.key({ modkey, "Control" }, "F1",          awful.help.whatsthis, nil, "what's this"),
  awful.key({ modkey            }, "grave",       function () terminal() end, nil, "terminal"),
  awful.key({ modkey            }, "x",           function () awful.util.spawn("xkill", false) end, nil, "xkill"),
  awful.key({                   }, "XF86Launch1", popterm, nil, "popup terminal"),
  awful.key({                   }, "XF86PowerOff", popterm, nil, "popup terminal"),
  awful.key({ modkey, "Control" }, "grave",       function () terminal("-name tail -title log/awesome -e tail -fn0 /home/koniu/log/awesome") end, nil, "awesome log"),
  awful.key({                   }, "Print",       function () awful.util.spawn_with_shell("~/bin/shot") end, nil, "screenshot"),
  awful.key({ "Control"         }, "Print",       function () awful.util.spawn_with_shell("sleep 1s; ~/bin/shot -s") end, nil, "selective screenshot"),
  awful.key({ "Mod1"            }, "Print",       function () awful.util.spawn_with_shell("sleep 5s; ~/bin/shot") end, nil, "delayed screenshot"),
  awful.key({ "Control", "Mod1" }, "Delete",      function () terminal("-name htop -e htop --sort-key PERCENT_CPU") end),
  awful.key({ modkey, "Shift"   }, "r",           function ()
    if not rec or rec == "" then 
      rec = "<span color='red'>REC</span>"
      awful.util.spawn("recordmydesktop --no-sound") 
    else 
      rec = "<span color='yellow'>REC</span>"; 
      awful.util.spawn("pkill -USR1 recordmydesktop") end end, nil, "recordmydesktop"),
-- }}}

-- {{{ bindings / global / tag manipulation
  awful.doc.set_default({ group = "2. tag manipulation" }),
  awful.key({                   }, "XF86Back",    awful.tag.viewprev, nil, "previous tag"),
  awful.key({                   }, "XF86Forward", awful.tag.viewnext, nil, "next tag"),
  awful.key({  modkey           }, "Left",    awful.tag.viewprev, nil, "previous tag"),
  awful.key({  modkey           }, "Right", awful.tag.viewnext, nil, "next tag"),
  awful.key({  modkey           }, "XF86Back",    shifty.shift_prev, nil, "move tag left" ),
  awful.key({  modkey           }, "XF86Forward", shifty.shift_next, nil, "move tag right"),

  awful.key({ modkey            }, "t",           function() shifty.add({ rel_index = 1 }) end, nil, "new tag"),
  awful.key({ modkey, "Control" }, "t",           function() shifty.add({ rel_index = 1, nopopup = true }) end, nil, "new tag in bg"),
  awful.key({ modkey            }, "r",           shifty.rename, nil, "tag rename"),
  awful.key({ modkey            }, "w",           shifty.del, nil, "tag delete"),

  awful.key({ modkey            }, 'i',           ti, nil, "tag info"),
  awful.key({ modkey            }, 'p',           function()
    shifty.set(awful.tag.selected(mouse.screen), { screen = awful.util.cycle(screen.count(), mouse.screen + 1) })
  end
    , nil, "tag info"),
-- }}}

-- {{{ bindings / global / client manipulation
  awful.doc.set_default({ group = "3. client manipulation" }),
  awful.key({ "Shift"           }, "XF86Back",    shifty.send_prev, nil, "move to prev tag"),
  awful.key({ "Shift"           }, "XF86Forward", shifty.send_next, nil, "move to next tag"),
  awful.key({ "Control"         }, "XF86Back",    function () awful.client.focus.byidx(-1);  if client.focus then client.focus:raise() end end, nil, "focus previous"),
  awful.key({ "Control"         }, "XF86Forward", function () awful.client.focus.byidx(1);  if client.focus then client.focus:raise() end end, nil, "focus next"),
  awful.key({ "Mod4"         }, "Tab", function () awful.client.focus.byidx(1);  if client.focus then client.focus:raise() end end, nil, "focus next"),
  awful.key({ modkey, "Shift"   }, "XF86Back",    function () awful.client.swap.byidx(-1) end, nil, "swap with prev"),
  awful.key({ modkey, "Shift"   }, "XF86Forward", function () awful.client.swap.byidx(1) end, nil, "swap with next"),
-- }}}

-- {{{ bindings / global / mm keys
  awful.key({                 }, "XF86AudioStop",  function () mpc:stop() end),
  awful.key({                 }, "XF86AudioPlay",  function () mpc:toggle_play() end),
  awful.key({                 }, "XF86AudioNext",  function () mpc:next() end),
  awful.key({                 }, "XF86AudioPrev",  function () mpc:previous() end),
  awful.key({ "Control"       }, "XF86AudioPrev",  function () awful.util.spawn("mpc --no-status seek -10", false) end),
  awful.key({ "Control"       }, "XF86AudioNext",  function () awful.util.spawn("mpc --no-status seek +10", false) end),
  awful.key({                 }, "XF86AudioMute",  function () awful.util.spawn("amixer set Master toggle", false) end),
  awful.key({                 }, "XF86AudioRaiseVolume",  function () mpc:volume_up(5) end),
  awful.key({                 }, "XF86AudioLowerVolume",  function () mpc:volume_down(5) end),
-- }}}

-- {{{ bindings / global / default rc.lua keys

  awful.doc.set_default({ group = "default" }),
  awful.key({ modkey            }, "Escape",      awful.tag.history.restore, nil, "prev selected tags"),
  awful.key({ modkey, "Control" }, "j",           function () awful.screen.focus(1) end, nil, "next screen"),
  awful.key({ modkey, "Control" }, "k",           function () awful.screen.focus(-1) end, nil, "prev screen"),
  --awful.key({ modkey            }, "Tab",         function () awful.client.focus.history.previous(); if client.focus then client.focus:raise() end end, nil, "prev foused client"),
  awful.key({ modkey            }, "u",           awful.client.urgent.jumpto, nil, "jump to urgent"),

-- Standard program

  awful.key({ modkey, "Control" }, "r",           function () naughty.notify{ text = awful.util.escape(awful.util.restart()) } end, nil, "restart awesome"),
  awful.key({ modkey, "Shift"   }, "q",           awesome.quit, nil, "quit awesome"),

-- Layout manipulation
  awful.key({ modkey            }, "l",           function () awful.tag.incmwfact(0.05) end),
  awful.key({ modkey            }, "h",           function () awful.tag.incmwfact(-0.05) end),
  awful.key({ modkey, "Shift"   }, "h",           function () awful.tag.incnmaster(1) end),
  awful.key({ modkey, "Shift"   }, "l",           function () awful.tag.incnmaster(-1) end),
  awful.key({ modkey, "Control" }, "h",           function () awful.tag.incncol(1) end),
  awful.key({ modkey, "Control" }, "l",           function () awful.tag.incncol(-1) end),
  awful.key({ modkey            }, "space",       function () awful.layout.inc(layouts, 1) end),
  awful.key({ modkey, "Shift"   }, "space",       function () awful.layout.inc(layouts, -1) end),
--}}}

-- {{{ bindings / global / prompts
  awful.doc.set_default({ group = "9. prompts" }),
  awful.key({ "Mod1"          }, "F2",  function () prompt.exec(prompt.presets.run) end, nil, "run"),
  awful.key({ "Mod1"          }, "F1",  function () prompt.exec(prompt.presets.lua) end, nil, "lua"),
  awful.key({ modkey, "Mod1"  }, "c",   function () prompt.presets.calc.args.text = val and tostring(val); prompt.exec(prompt.presets.calc) end, nil, "calc"),
  awful.key({ modkey, "Mod1"  }, "d",   function () prompt.presets.dict.args.text = awful.util.pread("xsel -o"); prompt.exec(prompt.presets.dict) end, nil, "dict"),
  awful.key({ modkey, "Mod1"  }, "k",   function () prompt.exec(prompt.presets.kill) end, nil, "kill"),
-- }}}

-- {{{ bindings / global / prompts / tagjump
  awful.key({ "Mod5" }, "/", function ()
    wi = mytagprompt[mouse.screen]
    wi.bg_image = image("/home/koniu/.config/awesome/icons/arrow.png")

	  awful.prompt.run({
        fg_cursor = "#DDFF00", bg_cursor=beautiful.bg_normal, ul_cursor = "single",
        prompt = "   ", text = " ", selectall = true
      },
      wi,
      function(n) local t = shifty.name2tag(n); if t then awful.tag.viewonly(t) end end,
      function (cmd, cur_pos, ncomp) return shifty.completion(cmd, cur_pos, ncomp, { "existing" }) end,
      os.getenv("HOME") .. "/.cache/awesome/tagjump",
      nil,
      function() wi.bg_image = nil end)
  end, nil, "jump to tag")
-- }}}

-- }}}

)

-- {{{ bindings / global / shifty.getpos
for i=0, ( shifty.config.maxtags or 9 ) do
  table.insert(globalkeys, key({ modkey }, i,
  function ()
    local t = awful.tag.viewonly(shifty.getpos(i))
  end))
  table.insert(globalkeys, key({ modkey, "Control" }, i,
  function ()
    local t = shifty.getpos(i)
    t.selected = not t.selected
  end))
  table.insert(globalkeys, key({ modkey, "Control", "Shift" }, i,
  function ()
    if client.focus then
      awful.client.toggletag(shifty.getpos(i))
    end
  end))
  -- move clients to other tags
  table.insert(globalkeys, key({ modkey, "Shift" }, i,
    function ()
      if client.focus then
        t = shifty.getpos(i)
        awful.client.movetotag(t)
        awful.tag.viewonly(t)
      end
    end))
end
-- }}}

--{{{ bindings / client
clientkeys = join(
  awful.doc.set_default({ group = "3. client manipulation" }),
  awful.key({ modkey            }, "m",       function (c) c.maximized_horizontal = not c.maximized_horizontal
                                                     c.maximized_vertical = not c.maximized_vertical end, nil, "maximize"),
  awful.key({ modkey            }, "f",       function (c) c.fullscreen = not c.fullscreen end, nil, "fullscreen"),
  awful.key({ modkey, "Control" }, "space",   awful.client.floating.toggle, nil, "set floating"),
  awful.key({ modkey, "Control" }, "Return",  function (c) c:swap(awful.client.getmaster()) end, nil, "swap with master"),
  awful.key({ modkey            }, "o",       awful.client.movetoscreen, nil, "move to screen"),
  awful.key({ modkey, "Shift"   }, "r",       function (c) c:redraw() end, nil, "redraw"),
  awful.key({ modkey,           }, "q",       function (c) c:kill() end, nil, "kill client"),
  awful.key({ "Mod1", "Mod4"    }, "i",       ci),
  awful.key({ "Mod1", "Mod4"    }, "a",       function(c) c.ontop = not c.ontop end, nil, "toggle on top")
)
--}}}

-- {{{ bindings / set keys and buttons
awful.doc.set_default({})
root.buttons = join(
  awful.button({ }, 3, function () mymainmenu:toggle() end),
  awful.button({ }, 4, awful.tag.viewnext),
  awful.button({ }, 5, awful.tag.viewprev)
)
root.keys = globalkeys
shifty.config.clientkeys = clientkeys
shifty.config.globalkeys = globalkeys
-- }}}

-- }}}

-- {{{ hooks 

-- {{{ hooks / focus
awful.hooks.focus.register(function (c)
  -- see if the client needs scrolling
  local ws = awful.wibox.get_workarea(c.screen)
  local geom = c:geometry()
  if (geom.width > ws.width or geom.height > ws.height)
    and not (awful.client.dockable.get(c) or c.fullscreen) then
      awful.hooks.timer.register(0.01, scrollclient)
  end
  -- change border color
  if awful.client.floating.get(c) and not awful.client.dockable.get(c) then
    c.border_color = '#26241E'
  elseif not awful.client.ismarked(c) then 
    c.border_color = beautiful.border_focus
  end
end)
-- }}}

-- {{{ hooks / unfocus
awful.hooks.unfocus.register(function (c)
  -- kill scrolling timer
  awful.hooks.timer.unregister(scrollclient)
  -- change border color
  if not awful.client.ismarked(c) then
    if not awful.client.dockable.get(c) then 
      c.border_color = beautiful.border_normal
    end
  end
end)
-- }}}

-- {{{ hooks / marked
awful.hooks.marked.register(function (c)
    c.border_color = beautiful.border_marked
end)
-- }}}

-- {{{ hooks / unmarked 
awful.hooks.unmarked.register(function (c)
    c.border_color = beautiful.border_focus
end)
-- }}}

-- {{{ hooks / unmanage
awful.hooks.unmanage.register(function (c)
  restore_focus(c.screen)
end)
-- }}}

-- {{{ hooks / property
awful.hooks.property.register(function (c, prop)
  if type(c) == "client" and (prop == "minimized" or prop == "hide") then
    restore_focus(c.screen, c)
end
end)
-- }}}

-- {{{ hooks / tags
awful.hooks.tags.register(function (scr)
  restore_focus(scr)
  if #screen[scr]:tags() == 0 then mylayoutbox[scr].image = nil end
end)
-- }}}

-- {{{ hooks / mouse_enter
awful.hooks.mouse_enter.register(function (c)
    -- Sloppy focus, but disabled for magnifier layout
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
end)
-- }}}

--{{{ hooks / timers
awful.hooks.timer.register(1, hook_1s)
awful.hooks.timer.register(30, hook_1m)
awful.hooks.timer.register(3, hook_3s)
awful.hooks.timer.register(5, hook_5s)
awful.hooks.timer.register(600, hook_10m)
-- }}}

-- }}}

-- vim: foldmethod=marker:filetype=lua:expandtab:shiftwidth=2:tabstop=2:softtabstop=2:encoding=utf-8:textwidth=80
