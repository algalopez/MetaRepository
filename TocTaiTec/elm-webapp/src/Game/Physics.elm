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
        strength = model.slingshot.strength
        -- Fixed upward velocity based on strength
        velocityY = 30 + (strength * 0.6)  -- Fast upward movement
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
                    -- Phase 2: Stopped at hitting coordinates (1.5 to 2.0 seconds) - reduced to 0.5s
                    -- Phase 3: Disappear (after 2.0 seconds)
                    
                    shouldDisappear = newLifetime > 2.0
                    isFlying = newLifetime < 1.5
                    
                    -- Apply gravity and movement only while flying
                    newVelocityY = 
                        if isFlying then
                            proj.velocityY + (gravity * deltaTime)
                        else
                            0
                            
                    newY = 
                        if isFlying then
                            -- Keep moving up with gravity
                            proj.y + (newVelocityY * deltaTime)
                        else
                            -- Stay at current position (stopped)
                            proj.y
                    
                    newX =
                        if isFlying then
                            -- Move horizontally while flying
                            proj.x + (proj.velocityX * deltaTime)
                        else
                            -- Stay at current position (stopped)
                            proj.x
                in
                if shouldDisappear then
                    { proj | active = False }
                else if not isFlying then
                    -- Stopped at hitting coordinates (between 1.5 and 2.0 seconds)
                    -- Keep the position where it stopped (don't update x or y)
                    { proj
                        | velocityX = 0
                        , velocityY = 0
                        , lifetime = newLifetime
                    }
                else
                    -- Still flying with gravity affecting velocity
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
                -- We need to check if it crossed the 1.5 second threshold this frame
                wasFlying = (proj.lifetime - deltaTime) < 1.5
                isStopped = proj.lifetime >= 1.5
                justStopped = wasFlying && isStopped
                
                -- Assume game area is about 1000px wide (average between min and max)
                -- This converts pixel size to percentage for collision detection
                avgGameWidth = 1000
                halfSizePercent = (target.size / 2) / avgGameWidth * 100
                
                -- Calculate absolute distances (in percentage units)
                distanceX = abs (proj.x - target.x)
                distanceY = abs (proj.y - target.y)
                
                -- The projectile hits if it's within the target's bounds
                isOverlapping = distanceX <= halfSizePercent && distanceY <= halfSizePercent
                
                -- Target must not be already hit
                notAlreadyHit = target.hitBy == Nothing
                
                -- Log collision check for square 1 (id = 0)
                _ = if justStopped && target.id == 0 then
                        Debug.log "Collision Check Square 1"
                            { square = { x = target.x, y = target.y }
                            , tomato = { x = proj.x, y = proj.y }
                            , hit = isOverlapping && notAlreadyHit
                            }
                    else
                        { square = { x = 0, y = 0 }
                        , tomato = { x = 0, y = 0 }
                        , hit = False
                        }
            in
            justStopped && isOverlapping && notAlreadyHit
        
        -- Update targets and check for hits
        updatedProjectiles = List.map updateProjectile model.projectiles
        
        -- Update target positions with bouncing
        updateTargetPosition : Target -> Target
        updateTargetPosition target =
            let
                -- Calculate new position
                newX = target.x + (target.velocityX * deltaTime)
                newY = target.y + (target.velocityY * deltaTime)
                
                -- Assume game area is about 1000px wide and 800px tall (average size)
                -- Convert pixel size to percentage for bounds checking
                avgGameWidth = 1000
                avgGameHeight = 800
                halfSizePercentX = (target.size / 2) / avgGameWidth * 100
                halfSizePercentY = (target.size / 2) / avgGameHeight * 100
                
                -- Bounce off edges (0-100 range)
                -- The square should bounce when its edge reaches the screen boundary
                (finalX, finalVelX) = 
                    if newX - halfSizePercentX <= 0 then
                        (halfSizePercentX, abs target.velocityX)  -- Bounce right
                    else if newX + halfSizePercentX >= 100 then
                        (100 - halfSizePercentX, -(abs target.velocityX))  -- Bounce left
                    else
                        (newX, target.velocityX)
                
                (finalY, finalVelY) = 
                    if newY - halfSizePercentY <= 0 then
                        (halfSizePercentY, abs target.velocityY)  -- Bounce up when BOTTOM edge reaches 0
                    else if newY + halfSizePercentY >= 100 then
                        (100 - halfSizePercentY, -(abs target.velocityY))  -- Bounce down when TOP edge reaches 100
                    else
                        (newY, target.velocityY)
            in
            { target 
                | x = finalX
                , y = finalY
                , velocityX = finalVelX
                , velocityY = finalVelY
            }
        
        -- First, update target positions with bouncing
        updatedTargetPositions = List.map updateTargetPosition model.targets
        
        -- Then, check for hits using the UPDATED target positions
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
        
        -- Update targets with hit detection using updated positions
        updatedTargets = 
            updatedTargetPositions
                |> List.map updateTargetWithHits
        
        -- Deactivate projectiles that hit a target
        deactivateHitProjectiles : Projectile -> Projectile
        deactivateHitProjectiles proj =
            let
                -- Check if this projectile hit any target
                hitAnyTarget = 
                    updatedTargets
                        |> List.any (\target -> 
                            case target.hitBy of
                                Just player -> 
                                    player == proj.shotBy && checkHit proj target
                                Nothing -> 
                                    False
                        )
            in
            if hitAnyTarget then
                { proj | active = False }
            else
                proj
        
        -- Apply deactivation to projectiles that hit targets
        finalProjectiles = List.map deactivateHitProjectiles updatedProjectiles
        
        -- Check if there's a winner after updating targets
        winner = checkWinner updatedTargets
        
        newGameState = 
            case winner of
                Just player -> GameOver player
                Nothing -> model.gameState
    in 
    ( { model
        | projectiles = finalProjectiles
            |> List.filter .active
        , targets = updatedTargets
        , lastTime = time
        , gameState = newGameState
      }
    , Cmd.none
    )
