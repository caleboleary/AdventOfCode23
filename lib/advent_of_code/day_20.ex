defmodule AdventOfCode.Day20 do

  defp get_parsed_input() do
    input = AdventOfCode.Input.get!(20, 2023)
    
#     input = "broadcaster -> a, b, c
# %a -> b
# %b -> c
# %c -> inv
# &inv -> a"

# input = "broadcaster -> a
# %a -> inv, con
# &inv -> b
# %b -> con
# &con -> output"

    String.split(input, "\n", trim: true)
    |> Enum.reduce(%{}, fn line, acc -> 
      [type_name, destinations] = String.split(line, " -> ", trim: true)

      {type, name} = cond do
        String.starts_with?(type_name, "%") -> {:flipflop, String.slice(type_name, 1..-1)}
        String.starts_with?(type_name, "&") -> {:conjunction, String.slice(type_name, 1..-1)}
        true -> {:broadcaster, type_name}
      end

      destinations = String.split(destinations, ", ", trim: true)

      Map.put(acc, name, %{type: type, destinations: destinations})

    end)
  end

  defp log_like_example(addition) do 

    {pulse_freq, target, source} = addition

    # IO.puts("#{source} -#{pulse_freq}-> #{target}")

  end

  defp get_conjunction_default_input(conjunction_name, input) do
    Enum.filter(input, fn {node_name, node_value} -> 
      destinations = node_value[:destinations]
      Enum.member?(destinations, conjunction_name)
    end)
    |> Enum.reduce(%{}, fn {node_name, node_value}, acc -> 
      Map.put(acc, node_name, :low)      
    end)
  end

  defp simulate_button_press(input, state) do

    # IO.inspect(input)

    default_queue = [{:low, "broadcaster", "button"}]

    default_node_state = state

    max_sim_steps = 100000

    Enum.reduce_while(0..max_sim_steps, {default_queue, default_node_state, %{high: 0, low: 1}}, fn sim_step, acc -> 

      {queue, node_state, counts} = acc
    
      {queued_tone, queued_target, queued_source} = Enum.at(queue, 0)
      # |> IO.inspect(label: "queued_tone, queued_target, queued_source")


      targeted_node = Map.get(input, queued_target)

      targeted_node = if targeted_node == nil do 
        # IO.inspect("Unknown node: #{queued_target}")
        %{type: :unknown, destinations: []}
      else
        targeted_node
      end

      targeted_node_type = targeted_node[:type]
      targeted_node_destinations = targeted_node[:destinations]
      targeted_node_state = Map.get(node_state, queued_target)

      {additions_to_queue, new_node_state} = cond do
        targeted_node_type == :broadcaster -> 
          # "When it receives a pulse, it sends the same pulse to all of its destination modules."
          {Enum.map(targeted_node_destinations, fn dest -> {queued_tone, dest, queued_target} end), node_state}
        targeted_node_type == :flipflop -> 
          # "Flip-flop modules (prefix %) are either on or off; they are initially off. 
          # If a flip-flop module receives a high pulse, it is ignored and nothing happens. 
          # However, if a flip-flop module receives a low pulse, it flips between on and off. 
          # If it was off, it turns on and sends a high pulse. If it was on, it turns off and sends a low pulse."
          case queued_tone do
            :low -> 
              case targeted_node_state do
                :off -> {
                    Enum.map(targeted_node_destinations, fn dest -> 
                      {:high, dest, queued_target}
                    end), 
                    Map.put(node_state, queued_target, :on)
                  }
                :on -> {
                    Enum.map(targeted_node_destinations, fn dest -> 
                      {:low, dest, queued_target}
                    end), 
                    Map.put(node_state, queued_target, :off)
                  }
              end
            :high -> {[], node_state}
          end
        targeted_node_type == :conjunction -> 
          # Conjunction modules (prefix &) remember the type of the most recent pulse received from each of their connected input modules;
          # they initially default to remembering a low pulse for each input. 
          # When a pulse is received, the conjunction module first updates its memory for that input. 
          # Then, if it remembers high pulses for all inputs, it sends a low pulse; otherwise, it sends a high pulse.
          last_received_for_this_input = targeted_node_state[queued_source]
          last_received_for_this_input = if last_received_for_this_input == nil do :low else last_received_for_this_input end

          new_targeted_node_state = Map.put(targeted_node_state, queued_source, queued_tone)

          new_node_state = Map.put(node_state, queued_target, new_targeted_node_state)

          if (Enum.all?(new_targeted_node_state, fn {_, value} -> value == :high end)) do
            {
              Enum.map(targeted_node_destinations, fn dest -> 
                {:low, dest, queued_target}
              end), 
              new_node_state
            }
          else
            {
              Enum.map(targeted_node_destinations, fn dest -> 
                {:high, dest, queued_target}
              end), 
              new_node_state
            }
          end
        true -> 
          # IO.inspect("Unknown node type: #{targeted_node_type}")
          {[], node_state}
      end
      # |> IO.inspect(label: "additions_to_queue, new_node_state")

      new_counts = %{
        high: counts[:high] + Enum.count(additions_to_queue, fn {tone, _, _} -> tone == :high end),
        low: counts[:low] + Enum.count(additions_to_queue, fn {tone, _, _} -> tone == :low end)
      }

      new_queue = Enum.slice(queue, 1..-1) ++ additions_to_queue
      # |> IO.inspect(label: "new_queue")

      Enum.each(additions_to_queue, fn addition -> 
        log_like_example(addition)
      end)

      if (new_queue == []) do
        {:halt, {[], node_state, new_counts}}
      else
        {:cont, {new_queue, new_node_state, new_counts}}
      end
    end)

  end

  def part1(_args) do

    input = get_parsed_input()

    default_node_state = Enum.reduce(input, %{}, fn {node_name, node_value}, acc -> 
      type = node_value[:type]

      Map.put(acc, node_name, cond do
        type == :broadcaster -> nil
        type == :flipflop -> :off
        type == :conjunction -> get_conjunction_default_input(node_name, input)
        true -> nil
      end)
      
    end)

    counts = Enum.reduce(0..999, {default_node_state, %{high: 0, low: 0}}, fn _sim_index, acc -> 

      {node_state, counts} = acc

      result = simulate_button_press(input, node_state)
      # |> IO.inspect(label: "sim_result")

      {_, new_state, new_counts} = result

      # IO.inspect(new_counts, label: "new_counts")

      new_counts = %{
        high: counts[:high] + new_counts[:high],
        low: counts[:low] + new_counts[:low]
      }

      {new_state, new_counts}

    end)
    |> elem(1)
    |> IO.inspect(label: "counts")

    counts[:low] * counts[:high]
    # 217812500 too low 

  end

  defp simulate_button_press_p2(input, state) do

    # IO.inspect(input)

    default_queue = [{:low, "broadcaster", "button"}]

    default_node_state = state

    max_sim_steps = 100000

    default_worked_queue = []

    Enum.reduce_while(0..max_sim_steps, {default_queue, default_node_state, %{high: 0, low: 1}, default_worked_queue}, fn sim_step, acc -> 

      {queue, node_state, counts, worked_queue} = acc
    
      {queued_tone, queued_target, queued_source} = Enum.at(queue, 0)
      # |> IO.inspect(label: "queued_tone, queued_target, queued_source")


      targeted_node = Map.get(input, queued_target)

      targeted_node = if targeted_node == nil do 
        # IO.inspect("Unknown node: #{queued_target}")
        %{type: :unknown, destinations: []}
      else
        targeted_node
      end

      targeted_node_type = targeted_node[:type]
      targeted_node_destinations = targeted_node[:destinations]
      targeted_node_state = Map.get(node_state, queued_target)

      {additions_to_queue, new_node_state} = cond do
        targeted_node_type == :broadcaster -> 
          # "When it receives a pulse, it sends the same pulse to all of its destination modules."
          {Enum.map(targeted_node_destinations, fn dest -> {queued_tone, dest, queued_target} end), node_state}
        targeted_node_type == :flipflop -> 
          # "Flip-flop modules (prefix %) are either on or off; they are initially off. 
          # If a flip-flop module receives a high pulse, it is ignored and nothing happens. 
          # However, if a flip-flop module receives a low pulse, it flips between on and off. 
          # If it was off, it turns on and sends a high pulse. If it was on, it turns off and sends a low pulse."
          case queued_tone do
            :low -> 
              case targeted_node_state do
                :off -> {
                    Enum.map(targeted_node_destinations, fn dest -> 
                      {:high, dest, queued_target}
                    end), 
                    Map.put(node_state, queued_target, :on)
                  }
                :on -> {
                    Enum.map(targeted_node_destinations, fn dest -> 
                      {:low, dest, queued_target}
                    end), 
                    Map.put(node_state, queued_target, :off)
                  }
              end
            :high -> {[], node_state}
          end
        targeted_node_type == :conjunction -> 
          # Conjunction modules (prefix &) remember the type of the most recent pulse received from each of their connected input modules;
          # they initially default to remembering a low pulse for each input. 
          # When a pulse is received, the conjunction module first updates its memory for that input. 
          # Then, if it remembers high pulses for all inputs, it sends a low pulse; otherwise, it sends a high pulse.
          last_received_for_this_input = targeted_node_state[queued_source]
          last_received_for_this_input = if last_received_for_this_input == nil do :low else last_received_for_this_input end

          new_targeted_node_state = Map.put(targeted_node_state, queued_source, queued_tone)

          new_node_state = Map.put(node_state, queued_target, new_targeted_node_state)

          if (Enum.all?(new_targeted_node_state, fn {_, value} -> value == :high end)) do
            {
              Enum.map(targeted_node_destinations, fn dest -> 
                {:low, dest, queued_target}
              end), 
              new_node_state
            }
          else
            {
              Enum.map(targeted_node_destinations, fn dest -> 
                {:high, dest, queued_target}
              end), 
              new_node_state
            }
          end
        true -> 
          # IO.inspect("Unknown node type: #{targeted_node_type}")
          new_node_state = Map.put(node_state, queued_target, queued_tone)
          {[], new_node_state}
      end
      # |> IO.inspect(label: "additions_to_queue, new_node_state")

      new_counts = %{
        high: counts[:high] + Enum.count(additions_to_queue, fn {tone, _, _} -> tone == :high end),
        low: counts[:low] + Enum.count(additions_to_queue, fn {tone, _, _} -> tone == :low end)
      }

      new_queue = Enum.slice(queue, 1..-1) ++ additions_to_queue
      # |> IO.inspect(label: "new_queue")

      new_worked_queue = worked_queue ++ Enum.slice(queue, 0..1)

      Enum.each(additions_to_queue, fn addition -> 
        log_like_example(addition)
      end)

      if (new_queue == []) do
        {:halt, {[], node_state, new_counts, new_worked_queue}}
      else
        {:cont, {new_queue, new_node_state, new_counts, new_worked_queue}}
      end
    end)

  end

  def part2(_args) do

    input = get_parsed_input()
    
    conjunctions = Enum.filter(input, fn {node_name, node_value} -> 
      node_value[:type] == :conjunction
    end)
    # |> Enum.map(fn {node_name, node_value} -> 
    #   # add a prop "roots" to node_value, which is a list of all nodes that target this conjunction
    #   {node_name, Map.put(node_value, :roots, Enum.filter(input, fn {name, value} -> 
    #     Enum.member?(value[:destinations], node_name)
    #   end))}
    # end)
    |> Enum.map(fn {node_name, node_value} -> 
      node_name
    end)

    # target = Enum.find(conjunctions, fn {name, value} -> 
    #   name == "vf"
    # end)

    default_node_state = Enum.reduce(input, %{}, fn {node_name, node_value}, acc -> 
      type = node_value[:type]

      Map.put(acc, node_name, cond do
        type == :broadcaster -> nil
        type == :flipflop -> :off
        type == :conjunction -> get_conjunction_default_input(node_name, input)
        true -> nil
      end)
      
    end)

    Enum.map(conjunctions, fn conjunction_name -> 
       #find first time a conjunction emits a :low
      state_data = Enum.reduce_while(0..100000, {default_node_state, %{high: 0, low: 0}, [], []}, fn sim_index, acc -> 

        {node_state, counts, relevant_node_history, worked_queue_list} = acc

        result = simulate_button_press_p2(input, node_state)

        {_, new_state, new_counts, worked_queue} = result
    
        new_counts = %{
          high: counts[:high] + new_counts[:high],
          low: counts[:low] + new_counts[:low]
        }

        # new_relevant_node_history = Enum.map(nt_nt_nodes_targeting_rx, fn {name, _} -> 
        #   {name, Map.get(new_state, name)}
        # end)

        new_relevant_node_history = []

        did_target_emit_low = Enum.any?(worked_queue, fn {tone, target, source} -> 
          source == conjunction_name && tone == :low
        end)

        if (did_target_emit_low) do
          IO.inspect("found conjunction that emits low #{conjunction_name}")
          IO.inspect(sim_index, label: "sim_index")
          
          {:halt, sim_index}
          # {:halt,{new_state, new_counts, relevant_node_history ++ [{sim_index, new_relevant_node_history}], worked_queue_list ++ [{sim_index, worked_queue}]}}
        else
          {:cont, {new_state, new_counts, relevant_node_history ++ [{sim_index, new_relevant_node_history}], worked_queue_list ++ [{sim_index, worked_queue}]}}
        end

      end)
    end)
    
    # 246,774,436,320,000 too low lmao
    # needed to add one to each

    #notes - what I did here was find all the cycles I could, then multiply them all, and that was the answer.
   

    true

    # nodes_targeting_rx = Enum.filter(input, fn {node_name, node_value} -> 
    #   destinations = node_value[:destinations]
    #   Enum.member?(destinations, "rx")
    # end)
    # |> IO.inspect(label: "nodes_targeting_rx")

    # nodes_targeting_nodes_targeting_rx = Enum.filter(input, fn {node_name, node_value} -> 
    #   destinations = node_value[:destinations]
    #   Enum.any?(destinations, fn dest -> 
    #     Enum.member?(
    #       Enum.map(nodes_targeting_rx, fn {name, _} -> 
    #         name
    #       end), dest
    #     )
    #   end)
    # end)
    # |> IO.inspect(label: "nodes_targeting_nodes_targeting_rx")

    # nt_nt_nodes_targeting_rx = Enum.filter(input, fn {node_name, node_value} -> 
    #   destinations = node_value[:destinations]
    #   Enum.any?(destinations, fn dest -> 
    #     Enum.member?(
    #       Enum.map(nodes_targeting_nodes_targeting_rx, fn {name, _} -> 
    #         name
    #       end), dest
    #     )
    #   end)
    # end)
    # |> IO.inspect(label: "nt_nt_nodes_targeting_rx")

    

    # #simulate 1000 steps, gather states of all above nodes and look for cycles
    # state_data = Enum.reduce(0..1, {default_node_state, %{high: 0, low: 0}, [], []}, fn sim_index, acc -> 

    #   {node_state, counts, relevant_node_history, worked_queue_list} = acc

    #   result = simulate_button_press_p2(input, node_state)
    #   # |> IO.inspect(label: "sim_result")

    #   {_, new_state, new_counts, worked_queue} = result

    #   # IO.inspect(new_counts, label: "new_counts")

    #   new_counts = %{
    #     high: counts[:high] + new_counts[:high],
    #     low: counts[:low] + new_counts[:low]
    #   }

    #   new_relevant_node_history = Enum.map(nt_nt_nodes_targeting_rx, fn {name, _} -> 
    #     {name, Map.get(new_state, name)}
    #   end)

    #   {new_state, new_counts, relevant_node_history ++ [{sim_index, new_relevant_node_history}], worked_queue_list ++ [{sim_index, worked_queue}]}

    # end)
    # |> elem(3)
    # |> IO.inspect(label: "worked_queue")

    # Enum.map(nt_nt_nodes_targeting_rx, fn {name, node_details} -> 
    #   Enum.map(node_details[:destinations], fn dest -> 
    #     IO.inspect(dest, label: "dest")

    #     Enum.filter(state_data, fn {sim_index, relevant_node_history} -> 
    #       {name, state} = Enum.at(relevant_node_history, 0)
    
    #       state[dest] == :high
    #     end)
    #     |> Enum.map(fn {sim_index, relevant_node_history} -> 
    #       sim_index
    #     end)
    #     |> IO.inspect(label: "relevant_node_history_filtered")
    #   end)
    # end)

    
    #find literally any where any state is :low
    # |> Enum.filter(fn {sim_index, relevant_node_history} -> 
    #   Enum.any?(relevant_node_history, fn {name, state} -> 
    #     Enum.any?(state, fn {source, state} -> 
    #       state == :low
    #     end)
    #   end)
    # end)

    # |> Enum.map(fn {sim_index, relevant_node_history} -> 
    #   #convert to string for dump
    #   Enum.join(
    #     Enum.map(relevant_node_history, fn {name, state} -> 
    #       IO.inspect({name, state}, label: "name, state")
          
    #       #example of state: %{"vf" => :high}
    #       state_str = Enum.join(
    #         Enum.map(state, fn {source, state} -> 
    #           "#{source}: #{state}"
    #         end), 
    #         ", "
    #       )
    #       |> IO.inspect(label: "state_str")
    #       "#{name}: #{state_str}"
    #     end), 
    #     ", "
    #   )
    # end)
    # |> Helpers.Utils.dump_to_file("day_20_part_2")

 

    # presses_until_rx = Enum.reduce_while(1000000000..2000000000, {default_node_state, %{high: 0, low: 0}}, fn sim_index, acc -> 
      
    #   Helpers.Utils.log_interval(sim_index, 10000, sim_index)

    #   {node_state, counts} = acc

    #   result = simulate_button_press(input, node_state)

    #   {_, new_state, new_counts} = result

    #   if (new_state[:rx] == :low) do
    #     IO.inspect(sim_index, label: "sim_index")
    #     {:halt, sim_index}
    #   else
    #     {:cont, {new_state, new_counts}}
    #   end
    
    # end)

   

  end
end
