defmodule Game.Combination.ChouetteVelute do
  alias Game.Combination.ChouetteVelute, as: ChouetteVelute
  alias Game.Combination.Chouette, as: Chouette
  alias Game.Combination.Velute, as: Velute

  defstruct value: nil

  def match? game do
    chouette = Chouette.match? game
    velute = Velute.match? game

    if chouette && velute do
      %ChouetteVelute{value: velute.sum_value}
    else
      nil
    end
  end

  def points chouette_velute do
    %Velute{sum_value: chouette_velute.value}
    |> Velute.points
  end
end