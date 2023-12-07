defmodule AdventOfCode.Day07 do

  defp get_parsed_input() do 
    input = AdventOfCode.Input.get!(7, 2023)
    
    # 6440
#     input = "32T3K 765
# T55J5 684
# KK677 28
# KTJJT 220
# QQQJA 483"

    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [hand, bid] = String.split(line, " ")
      %{
        hand: hand, 
        bid: String.to_integer(bid)
      }
    end)
    
  end

  defp convert_hand_to_base15(hand) do
    String.replace(hand, "T", "a")
    |> String.replace("J", "b")
    |> String.replace("Q", "c")
    |> String.replace("K", "d")
    |> String.replace("A", "e")
  end

  defp convert_hand_to_base15pt2(hand) do
    String.replace(hand, "T", "a")
    |> String.replace("J", "1")
    |> String.replace("Q", "c")
    |> String.replace("K", "d")
    |> String.replace("A", "e")
  end

  defp get_hand_base_value(hand) do
    # AAAAA = 144,443
    # 13 
    # 130
    # 1300
    # 13000
    # 130000

    String.split(hand, "", trim: true)
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.map(fn {card, index} ->
      card_value = String.to_integer(card, 15) * (10 ** (index * 2))
    end)
    
  end  

  defp get_hand_value(hand) do
    base_value = get_hand_base_value(convert_hand_to_base15(hand)) |> Enum.sum()

    sorted_hand = String.split(hand, "", trim: true) |> Enum.sort() |> Enum.join("")

    cond do 
      Regex.match?(~r/([a-zA-Z1-9])\1{4}/, sorted_hand) -> base_value + 10000000000000000
      Regex.match?(~r/([a-zA-Z1-9])\1{3}/, sorted_hand) -> base_value + 1000000000000000
      Regex.match?(~r/([a-zA-Z1-9])\1{2}/, sorted_hand) && String.split(sorted_hand, "", trim: true) |> Enum.uniq() |> length() == 2 -> base_value + 100000000000000
      Regex.match?(~r/([a-zA-Z1-9])\1{2}/, sorted_hand) -> base_value + 10000000000000
      Regex.match?(~r/([a-zA-Z1-9])\1{1}/, sorted_hand) && String.split(sorted_hand, "", trim: true) |> Enum.uniq() |> length() == 3 -> base_value + 1000000000000
      Regex.match?(~r/([a-zA-Z1-9])\1{1}/, sorted_hand) -> base_value + 100000000000
      true -> base_value
    end

  end

  defp get_hand_valuept2(hand) do
    base_value = get_hand_base_value(convert_hand_to_base15pt2(hand)) |> Enum.sum()

    hand = if String.contains?(hand, "J") do
      get_strongest_hand_with_jokers(hand)
      |> Map.get(:hand)
    else
      hand
    end

    sorted_hand = String.split(hand, "", trim: true) |> Enum.sort() |> Enum.join("")

    cond do 
      Regex.match?(~r/([a-zA-Z1-9])\1{4}/, sorted_hand) -> base_value + 10000000000000000
      Regex.match?(~r/([a-zA-Z1-9])\1{3}/, sorted_hand) -> base_value + 1000000000000000
      Regex.match?(~r/([a-zA-Z1-9])\1{2}/, sorted_hand) && String.split(sorted_hand, "", trim: true) |> Enum.uniq() |> length() == 2 -> base_value + 100000000000000
      Regex.match?(~r/([a-zA-Z1-9])\1{2}/, sorted_hand) -> base_value + 10000000000000
      Regex.match?(~r/([a-zA-Z1-9])\1{1}/, sorted_hand) && String.split(sorted_hand, "", trim: true) |> Enum.uniq() |> length() == 3 -> base_value + 1000000000000
      Regex.match?(~r/([a-zA-Z1-9])\1{1}/, sorted_hand) -> base_value + 100000000000
      true -> base_value
    end

  end

  defp dump_to_file(input) do
    # write the hand values to a file
    hands = Enum.map(input, fn %{hand: hand} -> 
      hand
    end)
    |> Enum.join("\n")

    File.write!("hands.txt", hands)

    input
  end

  def part1(_args) do

    input = get_parsed_input()

    input
    |> Enum.map(fn %{hand: hand, bid: bid} ->
      %{hand: hand, bid: bid, value: get_hand_value(hand)}
    end)
    |> Enum.sort_by(fn %{value: value} -> value end)
    |> IO.inspect()
    # dump to file as json
    |> dump_to_file()
    |> Enum.with_index()
    |> Enum.reduce(0, fn {hand_obj, index}, acc -> 
      acc + (hand_obj[:bid] * (index + 1))
    end)
    
  end

  defp get_strongest_hand_with_jokers(hand) do
    replacements = ["2", "3", "4", "5", "6", "7", "8", "9", "T", "Q", "K", "A"]

    IO.inspect(hand)

    Enum.map(replacements, fn replacement ->
      String.replace(hand, "J", replacement)
    end)
    |> Enum.map(fn hand ->
      %{hand: hand, value: get_hand_value(hand)}
    end)
    |> Enum.sort_by(fn %{value: value} -> value end)
    |> IO.inspect()
    |> Enum.at(-1)

  end

  def part2(_args) do

    input = get_parsed_input()

    input
    |> Enum.map(fn %{hand: hand, bid: bid} ->
      %{hand: hand, bid: bid, value: get_hand_valuept2(hand)}
    end)
    |> Enum.sort_by(fn %{value: value} -> value end)
    |> dump_to_file()
    |> IO.inspect()
    |> Enum.with_index()
    |> Enum.reduce(0, fn {hand_obj, index}, acc -> 
      acc + (hand_obj[:bid] * (index + 1))
    end)
    
  end
end
