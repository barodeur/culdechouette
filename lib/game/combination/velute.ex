defmodule Game.Combination.Velute do
  alias Game.Combination.Velute, as: Velute

  defstruct sum_value: nil

  def match?(game) do
    sorted_dice_values = Game.dice_values(game) |> Enum.sort
    max_dice_value = Enum.at(sorted_dice_values, 2)
    sum_other_dice =
      sorted_dice_values
      |> Enum.slice(0, 2)
      |> Enum.sum

    if sum_other_dice == max_dice_value do
      %Velute{sum_value: max_dice_value}
    else
      nil
    end
  end

  def points velute do
    :math.pow(velute.sum_value, 2) |> round |> Kernel.*(2)
  end
end