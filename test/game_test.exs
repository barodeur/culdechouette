defmodule GameTest do
  use ExUnit.Case
  doctest Game

  describe "Initialize game" do
    test "Game should wait for players" do
      game = Game.new
      assert game.state == :stopped
      game = Game.initialize(game)
      assert game.state == :waiting_for_players
    end
  end

  describe "Add players to game" do
    setup do
      game =
        Game.new
        |> Game.initialize
      [game: game]
    end

    test "Add two players", context do
      player_1 = %Player{username: "Player 1"}
      player_2 = %Player{username: "Player 2"}

      game =
        context[:game]
        |> Game.add_player(player_1)
        |> Game.add_player(player_2)
      
      assert length(game.data.players) == 2
    end
  end

  describe "Sort players" do
    setup do
      player_1 = %Player{username: "Player 1"}
      player_2 = %Player{username: "Player 2"}
      player_3 = %Player{username: "Player 3"}
      player_4 = %Player{username: "Player 4"}

      game =
        Game.new
        |> Game.initialize
        |> Game.add_player(player_1)
        |> Game.add_player(player_2)
        |> Game.add_player(player_3)
        |> Game.add_player(player_4)
        |> Game.start
      
      [game: game, player_1: player_1, player_2: player_2, player_3: player_3, player_4: player_4]
    end

    test "Sort three players", context do
      game =
        context[:game]
        |> Game.throw_die(context[:player_1], 1)
        |> Game.throw_die(context[:player_2], 2)
        |> Game.throw_die(context[:player_3], 3)
        |> Game.throw_die(context[:player_4], 3) # player_2, player_1
        |> Game.throw_die(context[:player_3], 1)
        |> Game.throw_die(context[:player_4], 1) # player_2, player_1 - nothing happened
        |> Game.throw_die(context[:player_3], 2)
        |> Game.throw_die(context[:player_4], 1) # player_3, player_4, player_2, player_1,

      
      assert game.state == :started
      assert game.data.sorted_players == [
        context[:player_3],
        context[:player_4],
        context[:player_2],
        context[:player_1]
      ]
    end    
  end
end