defmodule Day07 do
  @moduledoc """
  Documentation for Day07.
  """

  def part1() do
    mem = data()

    phases_generator()
    |> Enum.map(fn phase -> amp(mem, phase) end)
    |> Enum.max()
  end

  def part2() do
    mem = data()

    phases_generator(5)
    |> Enum.map(fn phase -> amp_feedback(mem, phase) end)
    |> Enum.max()
  end

  def phases_generator(start \\ 0) do
    stop = start + 4

    for a <- start..stop,
        b <- start..stop,
        b != a,
        c <- start..stop,
        c != b,
        c != a,
        d <- start..stop,
        d != c,
        d != b,
        d != a,
        e <- start..stop,
        e != d,
        e != c,
        e != b,
        e != a,
        do: [a, b, c, d, e]
  end

  def part1_test1() do
    # ex1
    mem = [3, 15, 3, 16, 1002, 16, 10, 16, 1, 16, 15, 15, 4, 15, 99, 0, 0]
    phases = [4, 3, 2, 1, 0]
    43_210 = amp(mem, phases)

    # ex2
    mem = [
      3,
      23,
      3,
      24,
      1002,
      24,
      10,
      24,
      1002,
      23,
      -1,
      23,
      101,
      5,
      23,
      23,
      1,
      24,
      23,
      23,
      4,
      23,
      99,
      0,
      0
    ]

    phases = [0, 1, 2, 3, 4]
    54_321 = amp(mem, phases)

    # ex3
    mem = [
      3,
      31,
      3,
      32,
      1002,
      32,
      10,
      32,
      1001,
      31,
      -2,
      31,
      1007,
      31,
      0,
      33,
      1002,
      33,
      7,
      33,
      1,
      33,
      31,
      31,
      1,
      32,
      31,
      31,
      4,
      31,
      99,
      0,
      0,
      0
    ]

    phases = [1, 0, 4, 3, 2]
    65_210 = amp(mem, phases)
  end

  def part2_test() do
    mem = [
      3,
      26,
      1001,
      26,
      -4,
      26,
      3,
      27,
      1002,
      27,
      2,
      27,
      1,
      27,
      26,
      27,
      4,
      27,
      1001,
      28,
      -1,
      28,
      1005,
      28,
      6,
      99,
      0,
      0,
      5
    ]

    phases = [9, 8, 7, 6, 5]
    139_629_729 = amp_feedback(mem, phases)
  end

  def amp(mem, phases) do
    Enum.reduce(phases, {[], nil, nil, 0}, fn phase, {_, _, _, input} ->
      opcode(mem, [phase, input])
    end)
    |> elem(3)
  end

  def amp_feedback(mem, phases) do
    state = for phase <- phases, into: %{}, do: {phase, {mem, 0, [phase]}}

    Stream.cycle(phases)
    # ugly, ignore for now...
    |> Enum.take(5 * 1000)
    |> Enum.reduce_while({state, 0}, fn phase, {state, output} ->
      {mem, ip, input} = state[phase]
      input = input ++ [output]

      case opcode(mem, ip, input) do
        {mem, ip, input, output} ->
          state = Map.put(state, phase, {mem, ip, input})
          {:cont, {state, output}}

        :halt ->
          {:halt, input}
      end
    end)
    |> hd()
  end

  def opcode(mem, input),
    do: opcode(mem, 0, input)

  def opcode(mem, ip, input) do
    [code | rest] = read_cache(mem, ip)

    parsed_code =
      code
      |> Integer.to_string()
      |> String.pad_leading(5, "0")
      |> String.reverse()
      |> String.to_charlist()

    opcode(parsed_code, rest, mem, ip, input)
  end

  def opcode([?1, ?0, ref1, ref2, _], [pos1, pos2, respos | _rest], mem, ip, input) do
    res = op(&(&1 + &2), {ref1, pos1}, {ref2, pos2}, mem)
    {mem, ip} = save(mem, respos, res, ip, 4)
    opcode(mem, ip, input)
  end

  def opcode([?2, ?0, ref1, ref2, _], [pos1, pos2, respos | _rest], mem, ip, input) do
    res = op(&(&1 * &2), {ref1, pos1}, {ref2, pos2}, mem)
    {mem, ip} = save(mem, respos, res, ip, 4)
    opcode(mem, ip, input)
  end

  def opcode([?3, ?0, _, _, _], [pos | _rest], mem, ip, [input | rest]) do
    {mem, ip} = save(mem, pos, input, ip, 2)
    opcode(mem, ip, rest)
  end

  def opcode([?4, ?0, ref1, _, _], [pos | _rest], mem, ip, input) do
    output = read({ref1, pos}, mem)
    {mem, ip + 2, input, output}
  end

  def opcode([?5, ?0, ref, ipref, _], [pos, ippos | _rest], mem, ip, input) do
    new_ip = read({ipref, ippos}, mem)

    if op(&(&1 > 0), {ref, pos}, mem),
      do: opcode(mem, new_ip, input),
      else: opcode(mem, ip + 3, input)
  end

  def opcode([?6, ?0, ref, ipref, _], [pos, ippos | _rest], mem, ip, input) do
    new_ip = read({ipref, ippos}, mem)

    if op(&(&1 == 0), {ref, pos}, mem),
      do: opcode(mem, new_ip, input),
      else: opcode(mem, ip + 3, input)
  end

  def opcode([?7, ?0, ref1, ref2, _], [pos1, pos2, respos | _rest], mem, ip, input) do
    res = if op(&(&1 < &2), {ref1, pos1}, {ref2, pos2}, mem), do: 1, else: 0
    {mem, ip} = save(mem, respos, res, ip, 4)
    opcode(mem, ip, input)
  end

  def opcode([?8, ?0, ref1, ref2, _], [pos1, pos2, respos | _rest], mem, ip, input) do
    res = if op(&(&1 == &2), {ref1, pos1}, {ref2, pos2}, mem), do: 1, else: 0
    {mem, ip} = save(mem, respos, res, ip, 4)
    opcode(mem, ip, input)
  end

  def opcode([?9, ?9 | _], _rest, _mem, _ip, _input) do
    :halt
  end

  defp read({?0, pos}, mem), do: Enum.at(mem, pos)
  defp read({?1, val}, _mem), do: val

  defp write(mem, pos, val), do: List.replace_at(mem, pos, val)

  defp read_cache(mem, ip) do
    Enum.slice(mem, ip, 4)
  end

  defp save(mem, pos, res, ip, n) do
    mem = write(mem, pos, res)
    ip = ip + n
    {mem, ip}
  end

  defp op(fun, pos, mem) do
    read(pos, mem) |> fun.()
  end

  defp op(fun, pos1, pos2, mem) do
    arg1 = read(pos1, mem)
    arg2 = read(pos2, mem)
    fun.(arg1, arg2)
  end

  def data() do
    [
      3,
      8,
      1001,
      8,
      10,
      8,
      105,
      1,
      0,
      0,
      21,
      42,
      67,
      84,
      97,
      118,
      199,
      280,
      361,
      442,
      99_999,
      3,
      9,
      101,
      4,
      9,
      9,
      102,
      5,
      9,
      9,
      101,
      2,
      9,
      9,
      1002,
      9,
      2,
      9,
      4,
      9,
      99,
      3,
      9,
      101,
      5,
      9,
      9,
      102,
      5,
      9,
      9,
      1001,
      9,
      5,
      9,
      102,
      3,
      9,
      9,
      1001,
      9,
      2,
      9,
      4,
      9,
      99,
      3,
      9,
      1001,
      9,
      5,
      9,
      1002,
      9,
      2,
      9,
      1001,
      9,
      5,
      9,
      4,
      9,
      99,
      3,
      9,
      1001,
      9,
      5,
      9,
      1002,
      9,
      3,
      9,
      4,
      9,
      99,
      3,
      9,
      102,
      4,
      9,
      9,
      101,
      4,
      9,
      9,
      102,
      2,
      9,
      9,
      101,
      3,
      9,
      9,
      4,
      9,
      99,
      3,
      9,
      102,
      2,
      9,
      9,
      4,
      9,
      3,
      9,
      1002,
      9,
      2,
      9,
      4,
      9,
      3,
      9,
      1001,
      9,
      2,
      9,
      4,
      9,
      3,
      9,
      102,
      2,
      9,
      9,
      4,
      9,
      3,
      9,
      102,
      2,
      9,
      9,
      4,
      9,
      3,
      9,
      1001,
      9,
      2,
      9,
      4,
      9,
      3,
      9,
      1002,
      9,
      2,
      9,
      4,
      9,
      3,
      9,
      102,
      2,
      9,
      9,
      4,
      9,
      3,
      9,
      1001,
      9,
      2,
      9,
      4,
      9,
      3,
      9,
      101,
      2,
      9,
      9,
      4,
      9,
      99,
      3,
      9,
      1001,
      9,
      1,
      9,
      4,
      9,
      3,
      9,
      101,
      2,
      9,
      9,
      4,
      9,
      3,
      9,
      1001,
      9,
      2,
      9,
      4,
      9,
      3,
      9,
      1002,
      9,
      2,
      9,
      4,
      9,
      3,
      9,
      101,
      2,
      9,
      9,
      4,
      9,
      3,
      9,
      1002,
      9,
      2,
      9,
      4,
      9,
      3,
      9,
      102,
      2,
      9,
      9,
      4,
      9,
      3,
      9,
      1002,
      9,
      2,
      9,
      4,
      9,
      3,
      9,
      101,
      1,
      9,
      9,
      4,
      9,
      3,
      9,
      101,
      2,
      9,
      9,
      4,
      9,
      99,
      3,
      9,
      101,
      1,
      9,
      9,
      4,
      9,
      3,
      9,
      1001,
      9,
      1,
      9,
      4,
      9,
      3,
      9,
      1002,
      9,
      2,
      9,
      4,
      9,
      3,
      9,
      1002,
      9,
      2,
      9,
      4,
      9,
      3,
      9,
      1002,
      9,
      2,
      9,
      4,
      9,
      3,
      9,
      1001,
      9,
      2,
      9,
      4,
      9,
      3,
      9,
      102,
      2,
      9,
      9,
      4,
      9,
      3,
      9,
      102,
      2,
      9,
      9,
      4,
      9,
      3,
      9,
      101,
      2,
      9,
      9,
      4,
      9,
      3,
      9,
      1001,
      9,
      2,
      9,
      4,
      9,
      99,
      3,
      9,
      102,
      2,
      9,
      9,
      4,
      9,
      3,
      9,
      102,
      2,
      9,
      9,
      4,
      9,
      3,
      9,
      1001,
      9,
      2,
      9,
      4,
      9,
      3,
      9,
      102,
      2,
      9,
      9,
      4,
      9,
      3,
      9,
      1001,
      9,
      2,
      9,
      4,
      9,
      3,
      9,
      102,
      2,
      9,
      9,
      4,
      9,
      3,
      9,
      102,
      2,
      9,
      9,
      4,
      9,
      3,
      9,
      101,
      1,
      9,
      9,
      4,
      9,
      3,
      9,
      1001,
      9,
      2,
      9,
      4,
      9,
      3,
      9,
      1002,
      9,
      2,
      9,
      4,
      9,
      99,
      3,
      9,
      101,
      1,
      9,
      9,
      4,
      9,
      3,
      9,
      101,
      1,
      9,
      9,
      4,
      9,
      3,
      9,
      102,
      2,
      9,
      9,
      4,
      9,
      3,
      9,
      1001,
      9,
      2,
      9,
      4,
      9,
      3,
      9,
      1001,
      9,
      2,
      9,
      4,
      9,
      3,
      9,
      1002,
      9,
      2,
      9,
      4,
      9,
      3,
      9,
      101,
      1,
      9,
      9,
      4,
      9,
      3,
      9,
      102,
      2,
      9,
      9,
      4,
      9,
      3,
      9,
      1001,
      9,
      1,
      9,
      4,
      9,
      3,
      9,
      1001,
      9,
      2,
      9,
      4,
      9,
      99
    ]
  end
end
