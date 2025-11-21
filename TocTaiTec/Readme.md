
# Week 2: TicTacToe

Just a regular tic tac toe game with the usual slingshots and tomatoes


# How to play the game

Just open the generated index.html file and click start game

Use the left and right arrows to move the slingshot
Use the down arrow to load power and release the key to throw a tomato
After throwing a tomato, it is the other player's turn

If you hit a target, it will become yours. If you are good you might be able to hit 2 targets at once (definitely ot a bug )
If you hit 3 targets that make a line, then you will win the game

The target hitting is a bit off, but here is where the AI starts making useless changes

## About the code

**Environment:**
- VSCode Studio
- Dev container plugin (To avoid installing anything locally)
- AI: Claude sonnet 3.5 and Claude sonnet 4.5 in agent mode
- Programming language: Elm 


**How to run the code:**

Initialize elm:
```
elm init
```

Make any code changes

Generate a javascript file from the elm code:
```
cd elm-webapp
elm make src/Main.elm --output elm.js
```

Start interactive tool:
```
elm reactor
```

Open localhost:8000, click the index and start playing

