defmodule Game.Combination.Chouette do
  alias Game.Combination.Chouette, as: Chouette

  defstruct value: nil

  def match?(game) do
    dice_values = Game.dice_values(game)

    min_max = dice_values
    |> Enum.min_max
    |> Tuple.to_list

    middle_value =
      dice_values -- min_max
      |> Enum.at(0)

    if Enum.member?(min_max, middle_value) do
      %Chouette{value: middle_value}
    else
      nil
    end
  end

  def points(chouette) do
    :math.pow(chouette.value, 2) |> round
  end
end