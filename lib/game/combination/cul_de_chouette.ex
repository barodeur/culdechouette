defmodule Game.Combination.CulDeChouette do
  defstruct value: nil

  def match? game do
    uniq_dice_values = Game.dice_values(game) |> Enum.uniq

    case length(uniq_dice_values) do
      1 -> %Game.Combination.CulDeChouette{value: Enum.at(uniq_dice_values, 0)}
      _ -> nil
    end
  end

  def points cul_de_chouette do
    40 + 10 * cul_de_chouette.value
  end
end
