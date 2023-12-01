defmodule AdventOfCode.Day01 do
  defp getFirstNumber(string) do
    IO.puts(string)
    split = String.split(string, ~r/\d/)
    IO.puts(String.length(List.first(split)))
    String.slice(string, String.length(List.first(split)), 1)
  end

  def part1(_args) do
    input = AdventOfCode.Input.get!(1, 2023)
    
    lines = String.split(input, "\n", trim: true)

    Enum.map(lines, fn line ->

      first = getFirstNumber(line)
      last = getFirstNumber(String.reverse(line))

      Integer.parse("#{first}#{last}") |> elem(0)
    end) |>
    Enum.reduce(0, fn currTotal, num -> currTotal + num end)
  
  end
  
  defp getFirstNumberP2(string) do
    run = Regex.run(~r/one|two|three|four|five|six|seven|eight|nine|\d/, string)
    
    res = transformFirstNumber(List.first(run))
  end

  defp getFirstNumberP2(string, isReverse) do
    run = Regex.run(~r/eno|owt|eerht|ruof|evif|xis|neves|thgie|enin|\d/, string)
    
    res = transformFirstNumberReverseLol(List.first(run))
  end

  defp transformFirstNumber(numStrOrInt) do
    case numStrOrInt do
      "one" -> "1"
      "two" -> "2"
      "three" -> "3"
      "four" -> "4"
      "five" -> "5"
      "six" -> "6"
      "seven" -> "7"
      "eight" -> "8"
      "nine" -> "9"
      _ -> "#{numStrOrInt}"
    end
  end

  defp transformFirstNumberReverseLol(numStrOrInt) do
    case numStrOrInt do
      "eno" -> "1"
      "owt" -> "2"
      "eerht" -> "3"
      "ruof" -> "4"
      "evif" -> "5"
      "xis" -> "6"
      "neves" -> "7"
      "thgie" -> "8"
      "enin" -> "9"
      _ -> "#{numStrOrInt}"
    end
  end


  def part2(_args) do
    input = AdventOfCode.Input.get!(1, 2023)
    
    lines = String.split(input, "\n", trim: true)

    Enum.map(lines, fn line ->

      first = getFirstNumberP2(line)
      last = getFirstNumberP2(String.reverse(line), true)
      IO.puts("first and last found")
      IO.puts("#{first}#{last}")

      Integer.parse("#{first}#{last}") |> elem(0)
    end) |>
    Enum.reduce(0, fn currTotal, num -> currTotal + num end)
  end
end
