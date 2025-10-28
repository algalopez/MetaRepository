module Game.Physics exposing (shootTomato, updateProjectiles)

import Game.Types exposing (..)
import Time
import Debug


-- SHOOTING AND PHYSICS

shootTomato : Model -> ( Model, Cmd Msg )
shootTomato model =
    let
        _ = Debug.log "Shot" { strength = model.slingshot.strength, x = model.slingshot.x }
        strength = model.slingshot.strength
        -- Use strength directly as target height percentage
        targetHeight = strength  -- strength is 0-100, perfect for percentage
        -- Fixed upward velocity
        velocityY = 40 + (strength * 0.6)  -- Fast upward movement
        newProjectile =
            { x = model.slingshot.x
            , y = 0  -- Start at ground
            , velocityX = 0  -- No horizontal movement
            , velocityY = velocityY
            , active = True
            , targetHeight = targetHeight  -- Store target height in projectile
            , lifetime = 0  -- Start lifetime at 0
            }
    in
    ( { model 
        | projectiles = newProjectile :: model.projectiles
        , currentPlayer = 
            case model.currentPlayer of
                PlayerA -> PlayerB
                PlayerB -> PlayerA
      }
    , Cmd.none
    )


updateProjectiles : Time.Posix -> Model -> ( Model, Cmd Msg )
updateProjectiles newTime model =
    let
        time = Time.posixToMillis newTime
        deltaTime = 
            if model.lastTime == 0 then
                0
            else
                (toFloat (time - model.lastTime)) / 1000  -- Convert to seconds

        gravity = -9.8 * 4  -- Increased gravity for better trajectory
                
        updateProjectile : Projectile -> Projectile
        updateProjectile proj =
            if not proj.active then
                proj
            else
                let
                    newLifetime = proj.lifetime + deltaTime
                    -- Make projectile disappear after 2 seconds
                    shouldDisappear = newLifetime > 2.0
                    
                    -- Apply gravity while moving up
                    newVelocityY = 
                        if proj.y < proj.targetHeight then
                            proj.velocityY + (gravity * deltaTime)
                        else
                            0
                            
                    newY = 
                        if proj.y < proj.targetHeight then
                            -- Keep moving up until we reach target height, with gravity
                            min proj.targetHeight (proj.y + (newVelocityY * deltaTime))
                        else
                            -- Stay at target height
                            proj.targetHeight
                    -- _ = Debug.log "Gravity" { newVelocity = newVelocityY, newY = newY }
                in
                if shouldDisappear then
                    { proj | active = False }
                else if newY >= proj.targetHeight then
                    -- We've reached our target height, stop moving
                    { proj
                        | y = proj.targetHeight
                        , velocityY = 0
                        , lifetime = newLifetime
                    }
                else
                    -- Still moving up, with gravity affecting velocity
                    { proj
                        | y = newY
                        , velocityY = newVelocityY
                        , lifetime = newLifetime
                    }
    in 
    ( { model
        | projectiles = List.map updateProjectile model.projectiles
            |> List.filter .active
        , lastTime = time
      }
    , Cmd.none
    )
