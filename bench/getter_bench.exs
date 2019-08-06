defmodule Calculus.GetterBench do
  use Benchfella
  require Calculus.Support.Field1, as: Field1
  require Calculus.Support.Field15, as: Field15

  @value 0

  before_each_bench _ do
    {
      :ok,
      {
        {
          Field1.struct_new(@value),
          Field1.record_new(@value),
          Field1.calculus_new(@value)
        },
        {
          Field15.struct_new(@value),
          Field15.record_new(@value),
          Field15.calculus_new(@value)
        }
      }
    }
  end

  bench "struct (1 field size)" do
    {it, _, _} = bench_context |> elem(0)
    %Field1{f: f} = it
    f
  end

  bench "record (1 field size)" do
    {_, it, _} = bench_context |> elem(0)
    Field1.t(f: f) = it
    f
  end

  bench "l-type (1 field size)" do
    {_, _, it} = bench_context |> elem(0)
    Field1.calculus_get(it)
  end

  bench "struct (15 fields size)" do
    {it, _, _} = bench_context |> elem(1)
    %Field15{f: f} = it
    f
  end

  bench "record (15 fields size)" do
    {_, it, _} = bench_context |> elem(1)
    Field15.t(f: f) = it
    f
  end

  bench "l-type (15 fields size)" do
    {_, _, it} = bench_context |> elem(1)
    Field15.calculus_get(it)
  end
end
