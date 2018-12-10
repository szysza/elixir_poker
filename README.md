# ElixirPoker
## Poker game implmented in Elixir.

## Inatallation
1. Clone the repository
2. Run
```mix deps.get mix run```

## Example games
### Player one wins
```
NEW GAME

Player 1 hand: ks kc kd 10s 9s
Player 2 hand: 3s 3h 8s 9d 10c

Player 1 won
```

### Player two wins
```
NEW GAME

Player 1 hand: 4s 4h 8s 9d 10c
Player 2 hand: 3s 3h 3d 3c 2s

Player 2 won
```

### Tie
```
Player 1 hand: 4s 4h 8s 9d 10c
Player 2 hand: 4c 4d 8c 9h 10d

It's a tie
```

### Invalid hand input
```
Player 1 hand: 4s 4h 8s 9d
Player 2 hand: 4c 4d 8c 9h 10d

This hand did't pass validation: 4S 4H 8S 9D, beacuse: Size of hand is 4, incorrect
```
