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
import           XMonad.Layout.WindowNavigation
import XMonad.Layout.IndependentScreens
import XMonad.Actions.WindowBringer
import XMonad.Hooks.WorkspaceHistory (workspaceHistoryHook)
import XMonad.Util.SpawnOnce (spawnOnce)
import XMonad.Prompt
import XMonad.Prompt.Workspace
import XMonad.Prompt.Shell
import XMonad.Prompt.Ssh
import XMonad.Prompt.XMonad
import XMonad.Actions.CycleWS
import XMonad.Actions.Submap
import qualified Data.Map as M
-- import for layouts
import XMonad.Layout.Spiral
import Data.Ratio -- this makes the '%' operator available (optional)
import XMonad.Layout.Spiral
import XMonad.Layout.Grid
import XMonad.Layout.Spacing
import XMonad.Prompt
import XMonad.Prompt.Window
import XMonad.Prompt.FuzzyMatch
import XMonad.Actions.WindowNavigation
import Data.Char -- for toLower function
import XMonad.Actions.ShowText
import XMonad.Actions.MouseGestures
import XMonad.Layout.CenteredMaster
import XMonad.Layout.BinarySpacePartition as BSP
import           XMonad.Layout.Tabbed
import           XMonad.Layout.Simplest


myFuzzyMatch :: String -> String -> Bool
myFuzzyMatch [] _ = True
myFuzzyMatch _ [] = False
--myFuzzyMatch (x:xs) (y:ys) =  (x == y && myFuzzyMatch xs ys) || (x /=y && (myFuzzyMatch (x:xs) ys))
-- concise way of writing fuzzy match
myFuzzyMatch xxs@(x:xs) (y:ys) | toLower x == toLower y = myFuzzyMatch xs ys
                               | otherwise = myFuzzyMatch xxs ys

-- border control
myBorderWidth   = 4
myNormalBorderColor  = "#3b4252"
myFocusedBorderColor = "#bc96da"

myPromptConfig = def
                 {
                   position = Top
                 , promptBorderWidth = 0
                 , defaultText = ""
                 , alwaysHighlight = True
                 , height = 32
                 , font = "xft:DejaVu Sans Condensed-16:normal"
                , autoComplete = Just 500000
                , searchPredicate = fuzzyMatch
                 }
--myWorkspaces = ["1","2","3","4","5","6","7","8","9"]
myWorkspaces :: Forest String
myWorkspaces = [ Node "Browser" [] -- a workspace for your browser
               , Node "comm" [ Node "slack" []
                                      , Node "mail" []
                                      , Node "zoom" []
                                      ]
               , Node "H"       -- for everyday activity's
                   [ Node "local" []   --  with 4 extra sub-workspaces, for even more activity's
                   , Node "remote" []
                   , Node "papers" []
                   , Node "spotify" []
                   ]
               , Node "Pgm" -- for all your programming needs
                   [ Node "emacs" []
                   , Node "code"    [] -- documentation
                   , Node "joplin"    [] -- documentation
                   , Node "gitkraken"    [] -- documentation
                   ]
               ]
              
 -- | Add very simple decorations to windows of a layout.
myTabConfig = def { inactiveBorderColor = "#FF0000"
                  , activeTextColor = "#00FF00"}

zenMode = renamed [Replace "Zen"] $ zenSpace BSP.emptyBSP
 where
  zenSpace =
    spacingRaw False (Border 0 10 10 10) True (Border 10 10 10 10) True
   
myLayouts = spacing 4 $
            ---centerMaster Grid ||| layoutTall ||| layoutGrid ||| layoutFull
            --- zenMode ||| layoutTall ||| layoutGrid ||| layoutFull ||| centerMaster Grid
            tabbed shrinkText myTabConfig ||| BSP.emptyBSP ||| layoutGrid ||| centerMaster Grid
    where
      layoutTall = Tall 1 (3/100) (1/2)
      layoutSpiral = spiral (125 % 146)
      layoutGrid = Grid
      layoutMirror = Mirror (Tall 1 (3/100) (3/5))
      layoutFull = Full
-- spawn application on a workspace
spawnToWorkspace :: String -> String -> X ()
spawnToWorkspace program workspace = do
                                      spawn program
                                      windows $ W.greedyView workspace
myStartupHook = do
            spawnOnce "~/.screenlayout/wide-tall.sh"
            --spawnToWorkspace "emacs" "emacs" -- spawn emacs on its workspace
            --spawnToWorkspace "firefox" "Browser"
            --spawnToWorkspace "local terminal" "terminator -l tmux"
            --spawnToWorkspace "nautilus" "Home"
            --spawnToWorkspace "evince" "papers"
            --spawnToWorkspace "spotify" "spotify"
-- The main function.
-- (=<<) :: Monad m => (a -> m b) -> m a -> m b. An action that returns 'a' and a function that returns action 'b' on a.
-- (>>=) :: Monad m => m a -> (a -> m b) -> m b - runs an action and passes the return value to a function that returns another action.
-- The second action is performed as well.
--statusBar :: LayoutClass l Window
        -- => String    -- ^ the command line to launch the status bar
        -- -> PP        -- ^ the pretty printing options
        -- -> (XConfig Layout -> (KeyMask, KeySym))
                -- -- ^ the desired key binding to toggle bar visibility
        -- -> XConfig l -- ^ the base config
        -- -> IO (XConfig (ModifiedLayout AvoidStruts l))
-- withWindowNavigation :: (KeySym, KeySym, KeySym, KeySym) -> XConfig l -> IO (XConfig l)
--main = xmonad =<< statusBar myBar myPP toggleStrutsKey myConfig


main = do
      config <- withWindowNavigation (xK_w, xK_a, xK_s, xK_d) $ myConfig
      xmonad =<< statusBar myBar myPP toggleStrutsKey config
--main = xmonad $ myConfig

-- Command to launch the bar.
myBar = "xmobar"

-- Custom PP, configure it as you like. It determines what is being written to the bar.
myPP = xmobarPP {
                ppCurrent = xmobarColor "#429942" "" . wrap "<" ">"
                , ppTitle = xmobarColor "green" "" . shorten 40
                , ppVisible = const ""
                , ppHidden = const ""
                , ppSep = "-"
                , ppLayout = const ""
                }

   
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

passwordTool = "keepassxc || exit 1"
gestures = M.fromList
        [ ([], focus)
        , ([U], \w -> focus w >> windows W.swapUp)
        , ([D], \w -> focus w >> windows W.swapDown)
        , ([R, D], \_ -> sendMessage NextLayout)
        ]
-- Key binding to toggle the gap for the bar.
toggleStrutsKey XConfig {XMonad.modMask = modMask} = (modMask, xK_b)
nothing = 0
screenshotClipboard =
  "maim -s --hidecursor --format png /dev/stdout | xclip -selection clipboard -t image/png"
myKeys =
        [ ((mod4Mask .|. shiftMask, xK_z), spawn "xscreensaver-command -lock; xset dpms force off")
        , ((controlMask, xK_Print), spawn "sleep 0.2; scrot -s ~/Pictures/%Y-%m-%d-%T-screenshot.png ")
        , ((0, xK_Print), spawn "scrot")
        , ((mod4Mask, xK_p), spawn "rofi -show run")
        , ((nothing, xK_Print)                 , spawn screenshotClipboard)
        , ((mod4Mask .|. shiftMask, xK_p)         , spawn passwordTool)
        , ((mod4Mask,                           xK_r     ), sendMessage Rotate)
        , ((mod4Mask,                           xK_y     ), nextScreen)
        , ((mod4Mask,                           xK_s     ), sendMessage Balance)
        --, ((mod4Mask, xK_g     ), gotoMenu) -- quick menus for switching windows
        , ((mod4Mask , xK_g     ), windowPrompt
                                   myPromptConfig
                                       Goto allWindows)
        , ((mod4Mask .|. controlMask, xK_x), shellPrompt myPromptConfig)
        , ((mod4Mask .|. controlMask, xK_s), sshPrompt myPromptConfig)
        --, ((mod4Mask .|. controlMask, xK_x), xmonadPrompt myPromptConfig)
        , ((mod4Mask, xK_f), treeselectWorkspace myTreeConf myWorkspaces W.view) -- can change to view or greedy view
        , ((mod4Mask .|. shiftMask, xK_m     ), workspacePrompt def (windows . W.shift))
        , ((mod4Mask .|. shiftMask, xK_f), treeselectAction myTreeConf [ Node (TSNode "Weather"    "displays weather"      (spawn "metar -d KTTN | xmessage -nearmouse -center -timeout 1 -title Trenton -buttons OK:1 -default OK -file - ")) []
                                                        , Node (TSNode "zoom" "zoom conference" (spawn "zoom")) []
                                                        , Node (TSNode "Brightness" "Sets screen brightness using xbacklight" (return ()))
                                                                [ Node (TSNode "Bright" "FULL POWER!!"            (spawn "xbacklight -set 100")) []
                                                                , Node (TSNode "Normal" "Normal Brightness (50%)" (spawn "xbacklight -set 50"))  []
                                                                , Node (TSNode "Dim"    "Quite dark"              (spawn "xbacklight -set 10"))  []
                                                                ]
   ]) -- can change to view or greedy view
        , ((mod4Mask,               xK_z),     toggleWS) -- switch to previous workspace
        --, ((mod4Mask, xK_s), submap . M.fromList $ -- use the following snippet for nested keybindings
       --[ ((0, xK_n),     spawn "mpc next")
       --, ((0, xK_p),     spawn "mpc prev")
       --, ((0, xK_z),     spawn "mpc random")
       --, ((0, xK_space), spawn "mpc toggle")
       --])
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
        --, layoutHook = avoidStruts  $  layoutHook defaultConfig
        , layoutHook = avoidStruts $ myLayouts
        , borderWidth        = myBorderWidth
        , workspaces = toWorkspaces myWorkspaces
        , logHook = workspaceHistoryHook
        , startupHook = myStartupHook     -- Startup scripts
        , modMask = mod4Mask     -- Rebind Mod to the Windows key
        ,normalBorderColor  = myNormalBorderColor
        ,focusedBorderColor = myFocusedBorderColor
        } `additionalKeys` myKeys
