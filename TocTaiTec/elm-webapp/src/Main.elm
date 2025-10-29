module Main exposing (main)

import Browser
import Browser.Events exposing (onKeyDown, onKeyUp, onAnimationFrame)
import Html exposing (..)
import Html.Attributes exposing (class, style, src, alt)
import Html.Events exposing (onClick)
import Json.Decode as Decode exposing (field, string)

import Game.Types exposing (..)
import Game.Physics as Physics


-- MAIN

main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


-- MODEL

init : () -> ( Model, Cmd Msg )
init _ =
    ( { gameState = Landing
      , currentPlayer = PlayerA
      , slingshot = 
            { x = 50  -- start in the middle
            , strength = 0  -- strength starts at 0
            , isLoading = False
            , direction = FacingRight  -- default direction
            }
      , projectiles = []
      , targets = initTargets
      , lastTime = 0
      }
    , Cmd.none
    )


-- Initialize 9 targets in a 3x3 grid formation
initTargets : List Target
initTargets =
    let
        -- Grid positions for 3x3 formation in the middle of the screen
        positions = 
            [ (30, 40), (45, 40), (60, 40)  -- Bottom row
            , (30, 55), (45, 55), (60, 55)  -- Middle row
            , (30, 70), (45, 70), (60, 70)  -- Top row
            ]
        
        -- Different velocity patterns for each target (slower speeds)
        velocities =
            [ (8, 5), (-6, 8), (9, -4)
            , (-5, -6), (7, 7), (-8, 5)
            , (6, -7), (-8, -5), (5, 8)
            ]
        
        createTarget : Int -> ((Float, Float), (Float, Float)) -> Target
        createTarget id ((x, y), (vx, vy)) =
            { id = id
            , x = x
            , y = y
            , velocityX = vx
            , velocityY = vy
            , size = 12  -- 12% of screen size (bigger)
            , hitBy = Nothing  -- Not hit by anyone initially
            }
    in
    List.indexedMap createTarget (List.map2 Tuple.pair positions velocities)


-- UPDATE

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        StartGame ->
            ( { model | gameState = Playing }, Cmd.none )

        KeyPressed key ->
            case key of
                "ArrowLeft" ->
                    ( { model | slingshot = moveSlingshot model.slingshot -5 }, Cmd.none )
                
                "ArrowRight" ->
                    ( { model | slingshot = moveSlingshot model.slingshot 5 }, Cmd.none )
                
                "ArrowDown" ->
                    ( { model | slingshot = startLoading model.slingshot }, Cmd.none )
                
                _ ->
                    ( model, Cmd.none )

        KeyReleased key ->
            case key of
                "ArrowDown" ->
                    if model.slingshot.isLoading then
                        let
                            releasedModel = { model | slingshot = releaseSlingshot model.slingshot }
                        in
                        Physics.shootTomato releasedModel
                    else
                        ( model, Cmd.none )
                    
                _ ->
                    ( model, Cmd.none )

        Tick time ->
            let
                slingshot = model.slingshot
                updatedSlingshot = 
                    if slingshot.isLoading then
                        { slingshot | strength = min 100 (slingshot.strength + 2) }
                    else
                        { slingshot | strength = max 0 (slingshot.strength - 4) }
                modelWithUpdatedSlingshot = { model | slingshot = updatedSlingshot }
            in
            Physics.updateProjectiles time modelWithUpdatedSlingshot

        LoadSlingshot ->
            ( { model | slingshot = startLoading model.slingshot }, Cmd.none )

        ReleaseSlingshot ->
            ( { model | slingshot = releaseSlingshot model.slingshot }, Cmd.none )

        Shoot ->
            if not model.slingshot.isLoading then
                Physics.shootTomato model
            else
                ( model, Cmd.none )


-- SLINGSHOT HELPERS

moveSlingshot : Slingshot -> Float -> Slingshot
moveSlingshot slingshot delta =
    let
        newDirection = 
            if delta > 0 then
                FacingRight
            else if delta < 0 then
                FacingLeft
            else
                slingshot.direction
    in
    { slingshot 
        | x = clamp 0 100 (slingshot.x + delta)
        , direction = newDirection
    }

startLoading : Slingshot -> Slingshot
startLoading slingshot =
    { slingshot | isLoading = True }

releaseSlingshot : Slingshot -> Slingshot
releaseSlingshot slingshot =
    { slingshot | isLoading = False }  -- Keep the strength value for shooting


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
    case model.gameState of
        Playing ->
            Sub.batch
                [ onKeyDown (Decode.map KeyPressed (field "key" string))
                , onKeyUp (Decode.map KeyReleased (field "key" string))
                , onAnimationFrame Tick
                ]
        
        Landing ->
            Sub.none
        
        GameOver _ ->
            Sub.none


-- VIEW

view : Model -> Html Msg
view model =
    div [ class "game-container" ]
        [ case model.gameState of
            Landing ->
                viewLanding
            
            Playing ->
                viewGame model
            
            GameOver winner ->
                viewGameOver winner model
        ]

viewLanding : Html Msg
viewLanding =
    div [ class "landing" ]
        [ h1 [] [ text "Tomato Slingshot Battle" ]
        , button [ onClick StartGame ] [ text "Start New Game" ]
        ]

viewGameOver : Player -> Model -> Html Msg
viewGameOver winner model =
    let
        (winnerName, winnerColor) = 
            case winner of
                PlayerA -> ("Player A", "#4CAF50")  -- Green
                PlayerB -> ("Player B", "#f44336")  -- Red
    in
    div [ class "game" ]
        [ viewGameInfo model
        , viewGameArea model
        , viewSlingshot model.currentPlayer model.slingshot
        , div [ class "game-over-overlay" ]
            [ div [ class "winner-announcement" ]
                [ h1 
                    [ style "color" winnerColor
                    , style "margin" "0"
                    , style "font-size" "3em"
                    ] 
                    [ text (winnerName ++ " Wins!") ]
                , button 
                    [ onClick StartGame
                    , style "margin-top" "30px"
                    ] 
                    [ text "Play Again" ]
                ]
            ]
        ]

viewGame : Model -> Html Msg
viewGame model =
    div [ class "game" ]
        [ viewGameInfo model
        , viewGameArea model
        , viewSlingshot model.currentPlayer model.slingshot
        ]

viewGameInfo : Model -> Html Msg
viewGameInfo model =
    let
        (playerName, playerColor) = 
            case model.currentPlayer of
                PlayerA -> ("Player A", "#4CAF50")  -- Green
                PlayerB -> ("Player B", "#f44336")  -- Red
    in
    div [ class "game-info" ]
        [ div [] 
            [ text "Current Turn: "
            , span 
                [ style "color" playerColor
                , style "font-weight" "bold"
                ] 
                [ text playerName ]
            ]
        ]

viewGameArea : Model -> Html Msg
viewGameArea model =
    div [ class "game-area" ]
        (List.map viewTarget model.targets 
        ++ List.map viewProjectile model.projectiles)

viewTarget : Target -> Html Msg
viewTarget target =
    let
        (backgroundColor, borderColor) = 
            case target.hitBy of
                Just PlayerA ->
                    ("#4CAF50", "#388E3C")  -- Green for Player A
                
                Just PlayerB ->
                    ("#f44336", "#c62828")  -- Red for Player B
                
                Nothing ->
                    ("#ff9800", "#f57c00")  -- Orange for not hit
        
        imagePath = "./public/images/tictactoe_" ++ String.fromInt (target.id + 1) ++ ".png"
    in
    div
        [ class "target"
        , style "left" (String.fromFloat target.x ++ "%")
        , style "bottom" (String.fromFloat target.y ++ "%")
        , style "width" (String.fromFloat target.size ++ "%")
        , style "height" (String.fromFloat target.size ++ "%")
        , style "transform" "translate(-50%, -50%)"
        , style "background-color" backgroundColor
        , style "border-color" borderColor
        ]
        [ img 
            [ src imagePath
            , alt ("Target " ++ String.fromInt (target.id + 1))
            , style "width" "100%"
            , style "height" "100%"
            , style "object-fit" "contain"
            ] 
            []
        ]

viewProjectile : Projectile -> Html Msg
viewProjectile projectile =
    div
        [ class "tomato"
        , style "left" (String.fromFloat projectile.x ++ "%")
        , style "bottom" (String.fromFloat projectile.y ++ "%")
        , style "transform" "translate(-50%, 50%)"  -- Center the tomato on its position
        ]
        []

viewSlingshot : Player -> Slingshot -> Html Msg
viewSlingshot currentPlayer slingshot =
    let
        -- Determine the image based on player and direction
        imageFile = 
            case (currentPlayer, slingshot.direction) of
                (PlayerA, FacingRight) -> "slingshot_A1.png"
                (PlayerA, FacingLeft) -> "slingshot_A2.png"
                (PlayerB, FacingRight) -> "slingshot_B1.png"
                (PlayerB, FacingLeft) -> "slingshot_B2.png"
        
        imagePath = "./public/images/" ++ imageFile
    in
    div 
        [ class "slingshot"
        , style "left" (String.fromFloat slingshot.x ++ "%")
        , style "bottom" "0"
        ]
        [ div [ class "strength-bar" ]
            [ div 
                [ class "strength-bar-fill"
                , style "height" (String.fromFloat slingshot.strength ++ "%")
                ] 
                []
            ]
        , img [ src imagePath, alt "Slingshot" ] [] 
        ]
