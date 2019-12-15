defmodule Day04 do
  @moduledoc """
  Documentation for Day04.
  """

  def part1() do
    passwords() |> length()
  end

  def part2() do
    passwords()
    |> Enum.filter(fn p -> only_doubles?(p) end)
    |> length()
  end

  def passwords() do
    158_126..624_574
    |> Enum.map(fn p -> Integer.to_charlist(p) end)
    |> Enum.filter(fn p -> match_criteria?(p) end)
  end

  def only_doubles?([a, b, c, d, e, f]) do
    (a == b && b != c) ||
      (a != b && b == c && c != d) ||
      (b != c && c == d && d != e) ||
      (c != d && d == e && e != f) ||
      (d != e && e == f)
  end

  def match_criteria?(password),
    do: match_criteria?(password, false)

  def match_criteria?([_], have_double),
    do: have_double

  def match_criteria?([a, b | _rest], _have_double) when b < a,
    do: false

  def match_criteria?([a, a | rest], _have_double),
    do: match_criteria?([a | rest], true)

  def match_criteria?([_a, b | rest], have_double),
    do: match_criteria?([b | rest], have_double)
end
