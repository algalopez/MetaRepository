module Game.Types exposing (..)

import Time


type GameState
    = Landing
    | Playing
    | GameOver Player  -- Game ended with a winner


type Player
    = PlayerA
    | PlayerB


type alias Slingshot =
    { x : Float  -- position from 0 to 100 (percentage)
    , strength : Float  -- from 0 to 100
    , isLoading : Bool
    , direction : SlingshotDirection  -- which way the slingshot is facing
    }


type SlingshotDirection
    = FacingRight
    | FacingLeft


type alias Projectile =
    { x : Float
    , y : Float
    , velocityX : Float
    , velocityY : Float
    , active : Bool
    , targetHeight : Float  -- Target height percentage (0-100)
    , lifetime : Float  -- Time in seconds the projectile has existed
    , shotBy : Player  -- which player shot this projectile
    }


type alias Target =
    { id : Int
    , x : Float  -- position from 0 to 100 (percentage)
    , y : Float  -- position from 0 to 100 (percentage)
    , velocityX : Float  -- pixels per second
    , velocityY : Float  -- pixels per second
    , size : Float  -- size in percentage
    , hitBy : Maybe Player  -- which player hit this target (Nothing if not hit)
    }


type alias Model =
    { gameState : GameState
    , currentPlayer : Player
    , slingshot : Slingshot
    , projectiles : List Projectile
    , targets : List Target
    , lastTime : Int  -- Store time in milliseconds
    }


type Msg
    = StartGame
    | KeyPressed String
    | KeyReleased String
    | LoadSlingshot
    | ReleaseSlingshot
    | Shoot
    | Tick Time.Posix