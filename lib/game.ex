defmodule Game do
  use Fsm,
      initial_state: :stopped,
      initial_data: %{ winner: nil }

  defstate stopped do
    defevent initialize, data: data do
      next_state(
        :waiting_for_players,
        Map.merge(data, %{
          waiting_for_players_since: DateTime.utc_now,
          players: [],
        })
      )
    end
  end

  defstate waiting_for_players do
    defevent add_player(player), data: data do
      next_state(
        :waiting_for_players,
        Map.merge(data, %{
          players: [player | data.players],
        })
      )
    end

    defevent start, data: data do
      next_state(
        :sorting_players,
        Map.merge(data, %{
          sorting_players_since: DateTime.utc_now,
          sort_challenge: Enum.map(data.players, fn(player) -> %{ player: player, die_value: nil } end),
          sorted_players: [],
        })
          |> Map.delete(:waiting_for_players_since)
      )
    end
  end

  defstate sorting_players do
    defevent throw_die(player), data: data do
      { new_state, new_data } = throw_die_helper(data, player, :rand.uniform(6))
      next_state(new_state, new_data)
    end

    defevent throw_die(player, die_value), data: data do
      { new_state, new_data } = throw_die_helper(data, player, die_value)
      next_state(new_state, new_data)
    end
  end

  def throw_die_helper(data, player, die_value) do
    %{
      players: players,
      sorted_players: sorted_players,
      sort_challenge: sort_challenge,
    } = data

    sort_challenge_players = sort_challenge |> Enum.map(fn(cm) -> cm.player end)

    in_challenge? =
      sort_challenge_players
      |> Enum.member?(player)

    unless in_challenge? do
      raise "Player not in challenge"
    end

    player_index = Enum.find_index(players, fn(x) -> x == player end)

    can_record_dice_value? = Enum.at(sort_challenge, player_index).die_value == nil
    unless can_record_dice_value? do
      raise "Cannot throw dice now"
    end

    sort_challenge = update_in(sort_challenge, [Access.at(player_index), Access.key!(:die_value)], fn(_) -> die_value end)

    challenge_completed? = Enum.all?(sort_challenge, fn(cm) -> cm.die_value != nil end)
    if challenge_completed? do
      min_die_value =
        sort_challenge
         |> Enum.map(fn(cm) -> cm.die_value end)
         |> Enum.min
      
      lucky_players = find_min_member_sequence(sort_challenge)
      
      remaining_members =
        sort_challenge
        |> Enum.reject(fn(cm) ->
          lucky_players |> Enum.member?(cm.player)
        end)
      
      sorted_players = lucky_players ++ sorted_players

      if length(players) - length(sorted_players) < 2 do
        { :started, Map.merge(data, %{
          sorted_players: sorted_players
        }) }
      else
        { :sorting_players, Map.merge(data, %{
          sorted_players: sorted_players,
          sort_challenge: update_in(remaining_members, [Access.all, Access.key!(:die_value)], fn(_) -> nil end),
        }) }
      end
    else
      { :sorting_players, Map.merge(data, %{
        sort_challenge: sort_challenge
      }) }
    end
  end

  def find_min_member_sequence([], accumulator) do
    accumulator
  end

  def find_min_member_sequence(sort_challenge, accumulator) do
    min_die_value =
      sort_challenge
        |> Enum.map(fn(cm) -> cm.die_value end)
        |> Enum.min
    
    challenge_members_by_die_value =
      sort_challenge
      |> Enum.group_by(fn(cm) -> cm.die_value end)
    
    lucky_members = challenge_members_by_die_value[min_die_value]

    if length(lucky_members) == 1 do
      lucky_member = lucky_members |> List.first

      new_sort_challenge =
        sort_challenge
        |> Enum.reject(fn(cm) -> cm.player == lucky_member.player end)
      find_min_member_sequence(new_sort_challenge, [ lucky_member.player | accumulator ])
    else
      accumulator
    end
  end

  def find_min_member_sequence(sort_challenge) do
    find_min_member_sequence(sort_challenge, [])
  end

  @min_players 2

  defmodule InsufficientNumberOfPlayersError do
    defexception [:message]

    def exception(value) do
      msg = "Got only #{value} players"
      %InsufficientNumberOfPlayersError{message: msg}
    end
  end

  def ensure_game_started(game) do
    if !game.started do
      raise "Game should be started"
    end
  end

  def start(game) do
    players_length = length(game.players)
    if players_length < @min_players do
      raise InsufficientNumberOfPlayersError, players_length
    end

    %{ game | status: :starting }
  end

  def dice_values(game) do
    [ game.cul_value | game.chouettes_values ]
  end

  def add_player(game, player) do
    %{game |
      players: [ player | game.players ],
      scores: [ 0 | game.scores ]
    }
  end

  def throw_chouettes(game) do
    ensure_game_started(game)

    %{game |
      chouettes_values: [:rand.uniform(6), :rand.uniform(6)],
    }
  end

  def throw_cul(game) do
    %{game | cul_value: :rand.uniform(6) }
  end

  def find_combinaison(game) do
    chouette = Game.Combination.Chouette.match? game
    veloute = Game.Combination.Veloute.match? game
    chouette_veloute = Game.Combination.ChouetteVeloute.match? game
    cul_de_chouette = Game.Combination.CulDeChouette.match? game

    cul_de_chouette || chouette_veloute || veloute || chouette
  end
end