import XMonad
import XMonad.Layout.SubLayouts
import XMonad.Layout.SimpleDecoration
import XMonad.Layout.Tabbed
import XMonad.Hooks.DynamicLog
import XMonad.Layout.Renamed
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import XMonad.Layout.WindowNavigation
import XMonad.Util.EZConfig(additionalKeys)
import System.IO
import Data.Tree
import XMonad.Actions.TreeSelect
import XMonad.Hooks.WorkspaceHistory
import qualified XMonad.StackSet as W
import XMonad.Layout.IndependentScreens
import XMonad.Actions.WindowBringer
import XMonad.Hooks.WorkspaceHistory (workspaceHistoryHook)
import XMonad.Util.SpawnOnce (spawnOnce)
import XMonad.Prompt
import XMonad.Prompt.Workspace
--myWorkspaces = ["1","2","3","4","5","6","7","8","9"]
myWorkspaces :: Forest String
myWorkspaces = [ Node "Browser" [] -- a workspace for your browser
               , Node "Home"       -- for everyday activity's
                   [ Node "local terminal" []   --  with 4 extra sub-workspaces, for even more activity's
                   , Node "remote terminal" []
                   , Node "3" []
                   , Node "4" []
                   ]
               , Node "Programming" -- for all your programming needs
                   [ Node "emacs" []
                   , Node "code"    [] -- documentation
                   ]
               ]

myStartupHook = do
            spawnOnce "~/.screenlayout/wide-tall.sh"
-- The main function.
main = xmonad =<< statusBar myBar myPP toggleStrutsKey myConfig
--main = xmonad $ myConfig

-- Command to launch the bar.
myBar = "xmobar"

-- Custom PP, configure it as you like. It determines what is being written to the bar.
myPP = xmobarPP { ppCurrent = xmobarColor "#429942" "" . wrap "<" ">" }
myTreeConf =
  TSConfig
    { ts_hidechildren = True
    , ts_background = 0x70707070--0xc0c0c0c0
    , ts_font = "xft:DroidSansMono Nerd Font:size=14"
    , ts_node = (0xff000000, 0xff50d0db)
    , ts_nodealt = (0xff000000, 0xff10b8d6)
    , ts_highlight = (0xffffffff, 0xffff0000)
    , ts_extra = 0xff000000
    , ts_node_width = 200
    , ts_node_height = 30
    , ts_originX = 0
    , ts_originY = 0
    , ts_indent = 60
    , ts_navigate = XMonad.Actions.TreeSelect.defaultNavigation
    }
-- Key binding to toggle the gap for the bar.
toggleStrutsKey XConfig {XMonad.modMask = modMask} = (modMask, xK_b)
myKeys =
        [ ((mod4Mask .|. shiftMask, xK_z), spawn "xscreensaver-command -lock; xset dpms force off")
        , ((controlMask, xK_Print), spawn "sleep 0.2; scrot -s")
        , ((0, xK_Print), spawn "scrot")
        , ((mod4Mask, xK_p), spawn "rofi -show run")
        , ((mod4Mask, xK_g     ), gotoMenu) -- quick menus for switching windows
        , ((mod4Mask, xK_f), treeselectWorkspace myTreeConf myWorkspaces W.view) -- can change to view or greedy view
        , ((mod4Mask .|. shiftMask, xK_m     ), workspacePrompt def (windows . W.shift))
        , ((mod4Mask, xK_a), treeselectAction myTreeConf [ Node (TSNode "Weather"    "displays weather"      (spawn "metar -d KTTN | xmessage -nearmouse -center -timeout 1 -title Trenton -buttons OK:1 -default OK -file - ")) []
                                                        , Node (TSNode "zoom" "zoom conference" (spawn "zoom")) []
                                                        , Node (TSNode "Brightness" "Sets screen brightness using xbacklight" (return ()))
                                                                [ Node (TSNode "Bright" "FULL POWER!!"            (spawn "xbacklight -set 100")) []
                                                                , Node (TSNode "Normal" "Normal Brightness (50%)" (spawn "xbacklight -set 50"))  []
                                                                , Node (TSNode "Dim"    "Quite dark"              (spawn "xbacklight -set 10"))  []
                                                                ]
   ]) -- can change to view or greedy view
        ]
        -- ++

          --
          -- mod-[1..9], Switch to workspace N
          -- mod-shift-[1..9], Move client to workspace N
          --
        -- [((m .|. mod4Mask, k), windows $ f i)
        -- | (i, k) <- zip (myWorkspaces) [xK_1 .. xK_9]
        --, (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]

myConfig =   defaultConfig
        { manageHook = manageDocks <+> manageHook defaultConfig
        , layoutHook = avoidStruts  $  layoutHook defaultConfig
        , workspaces = toWorkspaces myWorkspaces
        , logHook = workspaceHistoryHook
        , startupHook = myStartupHook     -- Startup scripts
        , modMask = mod4Mask     -- Rebind Mod to the Windows key
        } `additionalKeys` myKeys