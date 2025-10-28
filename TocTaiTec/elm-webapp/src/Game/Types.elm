module Game.Types exposing (..)

import Time


type GameState
    = Landing
    | Playing


type Player
    = PlayerA
    | PlayerB


type alias Slingshot =
    { x : Float  -- position from 0 to 100 (percentage)
    , strength : Float  -- from 0 to 100
    , isLoading : Bool
    }


type alias Projectile =
    { x : Float
    , y : Float
    , velocityX : Float
    , velocityY : Float
    , active : Bool
    , targetHeight : Float  -- Target height percentage (0-100)
    , lifetime : Float  -- Time in seconds the projectile has existed
    }


type alias Model =
    { gameState : GameState
    , currentPlayer : Player
    , slingshot : Slingshot
    , projectiles : List Projectile
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