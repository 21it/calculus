defmodule Calculus.ConstructorBench do
  use Benchfella
  require Calculus.Support.Field1, as: Field1
  require Calculus.Support.Field15, as: Field15

  @value 0

  bench "constructor, 1 field, struct" do
    Field1.struct_new(@value)
  end

  bench "constructor, 1 field, record" do
    Field1.record_new(@value)
  end

  bench "constructor, 1 field, l-type" do
    Field1.calculus_new(@value)
  end

  bench "constructor, 15 field, struct" do
    Field15.struct_new(@value)
  end

  bench "constructor, 15 field, record" do
    Field15.record_new(@value)
  end

  bench "constructor, 15 field, l-type" do
    Field15.calculus_new(@value)
  end
end
