module Game.Physics exposing (shootTomato, updateProjectiles)

import Game.Types exposing (..)
import Time
import Debug


-- WIN DETECTION

-- All possible winning combinations (using 0-based indices)
winningCombinations : List (List Int)
winningCombinations =
    [ [0, 1, 2]  -- Top horizontal (squares 1, 2, 3)
    , [3, 4, 5]  -- Middle horizontal (squares 4, 5, 6)
    , [6, 7, 8]  -- Bottom horizontal (squares 7, 8, 9)
    , [0, 3, 6]  -- Left vertical (squares 1, 4, 7)
    , [1, 4, 7]  -- Middle vertical (squares 2, 5, 8)
    , [2, 5, 8]  -- Right vertical (squares 3, 6, 9)
    , [0, 4, 8]  -- Diagonal (squares 1, 5, 9)
    , [2, 4, 6]  -- Diagonal (squares 3, 5, 7)
    ]

checkWinner : List Target -> Maybe Player
checkWinner targets =
    let
        -- Check if a specific player has won
        hasPlayerWon : Player -> Bool
        hasPlayerWon player =
            let
                -- Get indices of targets hit by this player
                hitIndices = 
                    targets
                        |> List.filter (\t -> t.hitBy == Just player)
                        |> List.map .id
                
                -- Check if any winning combination is satisfied
                hasWinningCombo combo =
                    List.all (\idx -> List.member idx hitIndices) combo
            in
            List.any hasWinningCombo winningCombinations
    in
    if hasPlayerWon PlayerA then
        Just PlayerA
    else if hasPlayerWon PlayerB then
        Just PlayerB
    else
        Nothing


-- SHOOTING AND PHYSICS

shootTomato : Model -> ( Model, Cmd Msg )
shootTomato model =
    let
        _ = Debug.log "Shot" { strength = model.slingshot.strength, x = model.slingshot.x }
        strength = model.slingshot.strength
        -- Use strength directly as target height percentage
        targetHeight = strength  -- strength is 0-100, perfect for percentage
        -- Fixed upward velocity with 5% angle
        velocityY = 40 + (strength * 0.6)  -- Fast upward movement
        -- Angle direction depends on slingshot facing direction
        velocityX = 
            case model.slingshot.direction of
                FacingRight -> velocityY * 0.05   -- 5% angle to the right
                FacingLeft -> velocityY * -0.05   -- 5% angle to the left
        newProjectile =
            { x = model.slingshot.x
            , y = 0  -- Start at ground
            , velocityX = velocityX  -- Movement based on slingshot direction
            , velocityY = velocityY
            , active = True
            , targetHeight = targetHeight  -- Store target height in projectile
            , lifetime = 0  -- Start lifetime at 0
            , shotBy = model.currentPlayer  -- Track who shot this
            }
        
        -- Switch player after shooting
        nextPlayer = 
            case model.currentPlayer of
                PlayerA -> PlayerB
                PlayerB -> PlayerA
    in
    ( { model 
        | projectiles = newProjectile :: model.projectiles
        , currentPlayer = nextPlayer
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
                    -- Phase 1: Flying (0 to 1.5 seconds)
                    -- Phase 2: Stopped at hitting coordinates (1.5 to 2.5 seconds)
                    -- Phase 3: Disappear (after 2.5 seconds)
                    
                    shouldDisappear = newLifetime > 2.5
                    isFlying = newLifetime < 1.5
                    
                    -- Apply gravity and movement only while flying
                    newVelocityY = 
                        if isFlying && proj.y < proj.targetHeight then
                            proj.velocityY + (gravity * deltaTime)
                        else
                            0
                            
                    newY = 
                        if isFlying && proj.y < proj.targetHeight then
                            -- Keep moving up until we reach target height, with gravity
                            min proj.targetHeight (proj.y + (newVelocityY * deltaTime))
                        else
                            -- Stay at current position (either reached target or stopped)
                            proj.y
                    
                    newX =
                        if isFlying then
                            -- Move horizontally while flying
                            proj.x + (proj.velocityX * deltaTime)
                        else
                            -- Stay at current position
                            proj.x
                in
                if shouldDisappear then
                    { proj | active = False }
                else if not isFlying then
                    -- Stopped at hitting coordinates (between 1.5 and 2.5 seconds)
                    { proj
                        | x = newX
                        , y = newY
                        , velocityX = 0
                        , velocityY = 0
                        , lifetime = newLifetime
                    }
                else if newY >= proj.targetHeight then
                    -- We've reached our target height during flight, stop moving vertically
                    { proj
                        | x = newX
                        , y = proj.targetHeight
                        , velocityX = proj.velocityX
                        , velocityY = 0
                        , lifetime = newLifetime
                    }
                else
                    -- Still moving up, with gravity affecting velocity
                    { proj
                        | x = newX
                        , y = newY
                        , velocityX = proj.velocityX
                        , velocityY = newVelocityY
                        , lifetime = newLifetime
                    }
        
        -- Check if a projectile hits a target
        checkHit : Projectile -> Target -> Bool
        checkHit proj target =
            let
                -- Check if projectile just stopped (at 1.5 seconds)
                justStopped = proj.lifetime >= 1.5 && proj.lifetime < 1.5 + deltaTime
                
                -- Check if projectile position overlaps with target
                -- Using half of target size for collision detection
                halfSize = target.size / 2
                distanceX = abs (proj.x - target.x)
                distanceY = abs (proj.y - target.y)
                
                isOverlapping = distanceX < halfSize && distanceY < halfSize
                
                -- Target must not be already hit
                notAlreadyHit = target.hitBy == Nothing
            in
            justStopped && isOverlapping && notAlreadyHit
        
        -- Update targets and check for hits
        updatedProjectiles = List.map updateProjectile model.projectiles
        
        -- For each target, check if any projectile hit it
        updateTargetWithHits : Target -> Target
        updateTargetWithHits target =
            let
                -- Find the first projectile that hit this target (if any)
                hitByProjectile = 
                    updatedProjectiles
                        |> List.filter (\proj -> checkHit proj target)
                        |> List.head
                
                -- Update hitBy if a projectile hit this target
                newHitBy = 
                    case hitByProjectile of
                        Just proj -> Just proj.shotBy
                        Nothing -> target.hitBy
            in
            { target | hitBy = newHitBy }
        
        -- Update target positions with bouncing
        updateTargetPosition : Target -> Target
        updateTargetPosition target =
            let
                -- Calculate new position
                newX = target.x + (target.velocityX * deltaTime)
                newY = target.y + (target.velocityY * deltaTime)
                
                -- Bounce off edges (0-100 range)
                (finalX, finalVelX) = 
                    if newX <= 0 then
                        (0, abs target.velocityX)  -- Bounce right
                    else if newX >= 100 then
                        (100, -(abs target.velocityX))  -- Bounce left
                    else
                        (newX, target.velocityX)
                
                (finalY, finalVelY) = 
                    if newY <= 0 then
                        (0, abs target.velocityY)  -- Bounce up
                    else if newY >= 100 then
                        (100, -(abs target.velocityY))  -- Bounce down
                    else
                        (newY, target.velocityY)
            in
            { target 
                | x = finalX
                , y = finalY
                , velocityX = finalVelX
                , velocityY = finalVelY
            }
        
        -- Update targets with position and hit detection
        updatedTargets = 
            model.targets
                |> List.map updateTargetWithHits
                |> List.map updateTargetPosition
        
        -- Check if there's a winner after updating targets
        winner = checkWinner updatedTargets
        
        newGameState = 
            case winner of
                Just player -> GameOver player
                Nothing -> model.gameState
    in 
    ( { model
        | projectiles = updatedProjectiles
            |> List.filter .active
        , targets = updatedTargets
        , lastTime = time
        , gameState = newGameState
      }
    , Cmd.none
    )
