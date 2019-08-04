defmodule Calculus.SetterBench do
  use Benchfella
  require Calculus.Support.Field1, as: Field1
  require Calculus.Support.Field15, as: Field15

  @value 0
  @new_value 1

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

  bench "setter, 1 field, struct" do
    {it, _, _} = bench_context |> elem(0)
    %Field1{f: f} = it
    {%Field1{it | f: @new_value}, f}
  end

  bench "setter, 1 field, record" do
    {_, it, _} = bench_context |> elem(0)
    Field1.t(f: f) = it
    {Field1.t(it, f: @new_value), f}
  end

  bench "setter, 1 field, l-type" do
    {_, _, it} = bench_context |> elem(0)
    Field1.calculus_set(it, @new_value)
  end

  bench "setter, 15 field, struct" do
    {it, _, _} = bench_context |> elem(1)
    %Field15{f: f} = it
    {%Field15{it | f: @new_value}, f}
  end

  bench "setter, 15 field, record" do
    {_, it, _} = bench_context |> elem(1)
    Field15.t(f: f) = it
    {Field15.t(it, f: @new_value), f}
  end

  bench "setter, 15 field, l-type" do
    {_, _, it} = bench_context |> elem(1)
    Field15.calculus_set(it, @new_value)
  end
end
