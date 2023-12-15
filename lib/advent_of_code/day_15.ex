defmodule AdventOfCode.Day15 do

  defp get_parsed_input() do
    
    input = AdventOfCode.Input.get!(15, 2023)
    |> String.replace("\n", "")

    # input = "HASH"

    # input = "rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7"

    String.split(input, ",", trim: true)
    
  end

  # https://elixirforum.com/t/converting-to-ascii/33713
  defp to_ascii(string) when is_binary(string) do
    :binary.first(string)
  end

  def part1(_args) do

    # start with a current value of 0. Then, for each character in the string starting from the beginning:

    #   Determine the ASCII code for the current character of the string.
    #   Increase the current value by the ASCII code you just determined.
    #   Set the current value to itself multiplied by 17.
    #   Set the current value to the remainder of dividing itself by 256.

    input = get_parsed_input()

    hash_values = Enum.map(input, fn word -> 

      letters = String.split(word, "", trim: true)

      Enum.reduce(letters, 0, fn letter, acc -> 
        ascii = to_ascii(letter)
        
        current_value = acc + ascii
        # |> IO.inspect()

        current_value = current_value * 17
        # |> IO.inspect()

        rem(current_value, 256)
        # |> IO.inspect()

      end)

    end)

    Enum.sum(hash_values)

  end

  defp get_hash(word) do
    letters = String.split(word, "", trim: true)

    Enum.reduce(letters, 0, fn letter, acc -> 
      ascii = to_ascii(letter)
      
      current_value = acc + ascii

      current_value = current_value * 17

      rem(current_value, 256)

    end)
  end

  defp replace_item_in_list(list, index, new_item) do
    Enum.with_index(list)
    |> Enum.map(fn ({item, i}) -> 
      if i == index do
        new_item
      else
        item
      end
    end)
  end

  def part2(_args) do

    input = get_parsed_input()

    box_states = Enum.reduce(input, %{}, fn instruction, acc -> 

      IO.inspect(instruction, label: "instruction")

      label = String.split(instruction, "=", trim: true)
      |> List.first()
      |> String.replace("-", "")

      hash = get_hash(label)
      |> IO.inspect(label: "hash")
    
      type = if String.contains?(instruction, "-") do
        :remove
      else
        :add
      end

      new_acc = case type do
        :add -> 
          [label, focal_len] = String.split(instruction, "=", trim: true)

          box = acc[hash] || []

          lens_already_present = Enum.any?(box, fn lens -> 
            elem(lens, 0) == label
          end)

          new_box = if lens_already_present do

            already_present_index = Enum.find_index(box, fn lens -> 
              elem(lens, 0) == label
            end)

            replace_item_in_list(box, already_present_index, {label, focal_len})
          else
            box ++ [{label, focal_len}]
          end

          Map.put(acc, hash, new_box)
        :remove -> 
          label = String.replace(instruction, "-", "")

          box = acc[hash] || []

          new_box = Enum.filter(box, fn lens -> 
            elem(lens, 0) != label
          end)

          Map.put(acc, hash, new_box)
      end

    end)

    Enum.flat_map(box_states, fn {box_num, box} -> 
      # The focusing power of a single lens is the result of multiplying together:

      #   One plus the box number of the lens in question.
      #   The slot number of the lens within the box: 1 for the first lens, 2 for the second lens, and so on.
      #   The focal length of the lens.

      Enum.with_index(box)
      |> Enum.map(fn {{lens, focal_len}, i} -> 
        
        (box_num + 1) * (i + 1) * String.to_integer(focal_len)
      end)
    end)
    |> Enum.sum()

  end
end
