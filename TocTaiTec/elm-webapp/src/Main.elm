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
            }
      , projectiles = []
      , lastTime = 0
      }
    , Cmd.none
    )


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
    { slingshot | x = clamp 0 100 (slingshot.x + delta) }

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


-- VIEW

view : Model -> Html Msg
view model =
    div [ class "game-container" ]
        [ case model.gameState of
            Landing ->
                viewLanding
            
            Playing ->
                viewGame model
        ]

viewLanding : Html Msg
viewLanding =
    div [ class "landing" ]
        [ h1 [] [ text "Tomato Slingshot Battle" ]
        , button [ onClick StartGame ] [ text "Start New Game" ]
        ]

viewGame : Model -> Html Msg
viewGame model =
    div [ class "game" ]
        [ viewGameInfo model
        , viewGameArea model
        , viewSlingshot model.slingshot
        ]

viewGameInfo : Model -> Html Msg
viewGameInfo model =
    div [ class "game-info" ]
        [ text <| "Current Turn: " ++
            case model.currentPlayer of
                PlayerA -> "Player A"
                PlayerB -> "Player B"
        ]

viewGameArea : Model -> Html Msg
viewGameArea model =
    div [ class "game-area" ]
        (List.map viewProjectile model.projectiles)

viewProjectile : Projectile -> Html Msg
viewProjectile projectile =
    div
        [ class "tomato"
        , style "left" (String.fromFloat projectile.x ++ "%")
        , style "bottom" (String.fromFloat projectile.y ++ "%")
        , style "transform" "translate(-50%, 50%)"  -- Center the tomato on its position
        ]
        []

viewSlingshot : Slingshot -> Html Msg
viewSlingshot slingshot =
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
        , img [ src "./public/images/slingshot.png", alt "Slingshot" ] [] 
        ]
