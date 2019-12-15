defmodule Day05 do
  @moduledoc """
  Documentation for Day05.
  """

  def part() do
    reset_mem() |> opcode()
  end

  def part1_test1() do
    q = [1, 0, 0, 0, 99]
    [2, 0, 0, 0, 99] = opcode(q)
    q = [2, 3, 0, 3, 99]
    [2, 3, 0, 6, 99] = opcode(q)
    q = [2, 4, 4, 5, 99, 0]
    [2, 4, 4, 5, 99, 9801] = opcode(q)
    q = [1, 1, 1, 4, 99, 5, 6, 0, 99]
    [30, 1, 1, 4, 2, 5, 6, 0, 99] = opcode(q)
    q = [1101, 100, -1, 4, 0]
    [1101, 100, -1, 4, 99] = opcode(q)
  end

  def part2_test() do
    # q = [3, 0, 4, 0, 99]
    # opcode(q)

    # q = [3, 3, 1107, -1, 8, 3, 4, 3, 99]
    # <8 -> 1, * -> 0
    # q = [3, 3, 1108, -1, 8, 3, 4, 3, 99]
    # 8 -> 1, * -> 0

    # q = [3, 9, 7, 9, 10, 9, 4, 9, 99, -1, 8]
    # <8 -> 1, * -> 0

    # q = [3, 9, 8, 9, 10, 9, 4, 9, 99, -1, 8]
    # 8 > 1, * -> 0

    q = [3, 12, 6, 12, 15, 1, 13, 14, 13, 4, 13, 99, -1, 0, 1, 9]
    # q = [3, 3, 1105, -1, 9, 1101, 0, 0, 12, 4, 12, 99, 1]
    # 0 -> 0, * -> 1
    opcode(q)
  end

  def opcode(mem),
    do: opcode(mem, 0)

  def opcode(mem, ip) do
    [code | rest] = read_cache(mem, ip)

    parsed_code =
      code
      |> Integer.to_string()
      |> String.pad_leading(5, "0")
      |> String.reverse()
      |> String.to_charlist()

    opcode(parsed_code, rest, mem, ip)
  end

  def opcode([?1, ?0, ref1, ref2, _], [pos1, pos2, respos | _rest], mem, ip) do
    res = op(&(&1 + &2), {ref1, pos1}, {ref2, pos2}, mem)
    {mem, ip} = save(mem, respos, res, ip, 4)
    opcode(mem, ip)
  end

  def opcode([?2, ?0, ref1, ref2, _], [pos1, pos2, respos | _rest], mem, ip) do
    res = op(&(&1 * &2), {ref1, pos1}, {ref2, pos2}, mem)
    {mem, ip} = save(mem, respos, res, ip, 4)
    opcode(mem, ip)
  end

  def opcode([?3, ?0, _, _, _], [pos | _rest], mem, ip) do
    res = IO.gets("Input: ") |> String.trim() |> String.to_integer()
    {mem, ip} = save(mem, pos, res, ip, 2)
    opcode(mem, ip)
  end

  def opcode([?4, ?0, ref1, _, _], [pos | _rest], mem, ip) do
    res = read({ref1, pos}, mem)
    IO.puts("Output: #{res}")
    opcode(mem, ip + 2)
  end

  def opcode([?5, ?0, ref, ipref, _], [pos, ippos | _rest], mem, ip) do
    new_ip = read({ipref, ippos}, mem)

    if op(&(&1 > 0), {ref, pos}, mem),
      do: opcode(mem, new_ip),
      else: opcode(mem, ip + 3)
  end

  def opcode([?6, ?0, ref, ipref, _], [pos, ippos | _rest], mem, ip) do
    new_ip = read({ipref, ippos}, mem)

    if op(&(&1 == 0), {ref, pos}, mem),
      do: opcode(mem, new_ip),
      else: opcode(mem, ip + 3)
  end

  def opcode([?7, ?0, ref1, ref2, _], [pos1, pos2, respos | _rest], mem, ip) do
    res = if op(&(&1 < &2), {ref1, pos1}, {ref2, pos2}, mem), do: 1, else: 0
    {mem, ip} = save(mem, respos, res, ip, 4)
    opcode(mem, ip)
  end

  def opcode([?8, ?0, ref1, ref2, _], [pos1, pos2, respos | _rest], mem, ip) do
    res = if op(&(&1 == &2), {ref1, pos1}, {ref2, pos2}, mem), do: 1, else: 0
    {mem, ip} = save(mem, respos, res, ip, 4)
    opcode(mem, ip)
  end

  def opcode([?9, ?9 | _], _rest, mem, _ip) do
    mem
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

  def reset_mem() do
    [
      3,
      225,
      1,
      225,
      6,
      6,
      1100,
      1,
      238,
      225,
      104,
      0,
      1102,
      17,
      65,
      225,
      102,
      21,
      95,
      224,
      1001,
      224,
      -1869,
      224,
      4,
      224,
      1002,
      223,
      8,
      223,
      101,
      7,
      224,
      224,
      1,
      224,
      223,
      223,
      101,
      43,
      14,
      224,
      1001,
      224,
      -108,
      224,
      4,
      224,
      102,
      8,
      223,
      223,
      101,
      2,
      224,
      224,
      1,
      223,
      224,
      223,
      1101,
      57,
      94,
      225,
      1101,
      57,
      67,
      225,
      1,
      217,
      66,
      224,
      101,
      -141,
      224,
      224,
      4,
      224,
      102,
      8,
      223,
      223,
      1001,
      224,
      1,
      224,
      1,
      224,
      223,
      223,
      1102,
      64,
      34,
      225,
      1101,
      89,
      59,
      225,
      1102,
      58,
      94,
      225,
      1002,
      125,
      27,
      224,
      101,
      -2106,
      224,
      224,
      4,
      224,
      102,
      8,
      223,
      223,
      1001,
      224,
      5,
      224,
      1,
      224,
      223,
      223,
      1102,
      78,
      65,
      225,
      1001,
      91,
      63,
      224,
      101,
      -127,
      224,
      224,
      4,
      224,
      102,
      8,
      223,
      223,
      1001,
      224,
      3,
      224,
      1,
      223,
      224,
      223,
      1102,
      7,
      19,
      224,
      1001,
      224,
      -133,
      224,
      4,
      224,
      102,
      8,
      223,
      223,
      101,
      6,
      224,
      224,
      1,
      224,
      223,
      223,
      2,
      61,
      100,
      224,
      101,
      -5358,
      224,
      224,
      4,
      224,
      102,
      8,
      223,
      223,
      101,
      3,
      224,
      224,
      1,
      224,
      223,
      223,
      1101,
      19,
      55,
      224,
      101,
      -74,
      224,
      224,
      4,
      224,
      102,
      8,
      223,
      223,
      1001,
      224,
      1,
      224,
      1,
      224,
      223,
      223,
      1101,
      74,
      68,
      225,
      4,
      223,
      99,
      0,
      0,
      0,
      677,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      1105,
      0,
      99999,
      1105,
      227,
      247,
      1105,
      1,
      99999,
      1005,
      227,
      99999,
      1005,
      0,
      256,
      1105,
      1,
      99999,
      1106,
      227,
      99999,
      1106,
      0,
      265,
      1105,
      1,
      99999,
      1006,
      0,
      99999,
      1006,
      227,
      274,
      1105,
      1,
      99999,
      1105,
      1,
      280,
      1105,
      1,
      99999,
      1,
      225,
      225,
      225,
      1101,
      294,
      0,
      0,
      105,
      1,
      0,
      1105,
      1,
      99999,
      1106,
      0,
      300,
      1105,
      1,
      99999,
      1,
      225,
      225,
      225,
      1101,
      314,
      0,
      0,
      106,
      0,
      0,
      1105,
      1,
      99999,
      107,
      677,
      677,
      224,
      102,
      2,
      223,
      223,
      1006,
      224,
      329,
      1001,
      223,
      1,
      223,
      1008,
      226,
      677,
      224,
      102,
      2,
      223,
      223,
      1006,
      224,
      344,
      1001,
      223,
      1,
      223,
      7,
      226,
      677,
      224,
      102,
      2,
      223,
      223,
      1005,
      224,
      359,
      1001,
      223,
      1,
      223,
      8,
      226,
      226,
      224,
      102,
      2,
      223,
      223,
      1006,
      224,
      374,
      1001,
      223,
      1,
      223,
      1007,
      226,
      226,
      224,
      102,
      2,
      223,
      223,
      1006,
      224,
      389,
      101,
      1,
      223,
      223,
      8,
      677,
      226,
      224,
      1002,
      223,
      2,
      223,
      1005,
      224,
      404,
      101,
      1,
      223,
      223,
      1108,
      677,
      226,
      224,
      102,
      2,
      223,
      223,
      1006,
      224,
      419,
      1001,
      223,
      1,
      223,
      1108,
      226,
      677,
      224,
      102,
      2,
      223,
      223,
      1006,
      224,
      434,
      101,
      1,
      223,
      223,
      1108,
      677,
      677,
      224,
      1002,
      223,
      2,
      223,
      1005,
      224,
      449,
      101,
      1,
      223,
      223,
      1008,
      677,
      677,
      224,
      1002,
      223,
      2,
      223,
      1006,
      224,
      464,
      101,
      1,
      223,
      223,
      7,
      677,
      226,
      224,
      1002,
      223,
      2,
      223,
      1006,
      224,
      479,
      101,
      1,
      223,
      223,
      108,
      677,
      677,
      224,
      1002,
      223,
      2,
      223,
      1005,
      224,
      494,
      101,
      1,
      223,
      223,
      107,
      226,
      677,
      224,
      1002,
      223,
      2,
      223,
      1006,
      224,
      509,
      101,
      1,
      223,
      223,
      107,
      226,
      226,
      224,
      102,
      2,
      223,
      223,
      1006,
      224,
      524,
      1001,
      223,
      1,
      223,
      1107,
      226,
      677,
      224,
      1002,
      223,
      2,
      223,
      1006,
      224,
      539,
      101,
      1,
      223,
      223,
      1008,
      226,
      226,
      224,
      102,
      2,
      223,
      223,
      1006,
      224,
      554,
      1001,
      223,
      1,
      223,
      8,
      226,
      677,
      224,
      1002,
      223,
      2,
      223,
      1006,
      224,
      569,
      101,
      1,
      223,
      223,
      1007,
      677,
      677,
      224,
      102,
      2,
      223,
      223,
      1005,
      224,
      584,
      1001,
      223,
      1,
      223,
      1107,
      677,
      226,
      224,
      1002,
      223,
      2,
      223,
      1006,
      224,
      599,
      101,
      1,
      223,
      223,
      7,
      226,
      226,
      224,
      1002,
      223,
      2,
      223,
      1005,
      224,
      614,
      101,
      1,
      223,
      223,
      108,
      677,
      226,
      224,
      1002,
      223,
      2,
      223,
      1005,
      224,
      629,
      1001,
      223,
      1,
      223,
      108,
      226,
      226,
      224,
      1002,
      223,
      2,
      223,
      1005,
      224,
      644,
      101,
      1,
      223,
      223,
      1007,
      677,
      226,
      224,
      1002,
      223,
      2,
      223,
      1006,
      224,
      659,
      101,
      1,
      223,
      223,
      1107,
      226,
      226,
      224,
      102,
      2,
      223,
      223,
      1005,
      224,
      674,
      1001,
      223,
      1,
      223,
      4,
      223,
      99,
      226
    ]
  end
end