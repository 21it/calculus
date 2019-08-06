defmodule Calculus.ConstructorBench do
  use Benchfella
  require Calculus.Support.Field1, as: Field1
  require Calculus.Support.Field15, as: Field15

  @value 0

  bench "struct (1 field size)" do
    Field1.struct_new(@value)
  end

  bench "record (1 field size)" do
    Field1.record_new(@value)
  end

  bench "l-type (1 field size)" do
    Field1.calculus_new(@value)
  end

  bench "struct (15 fields size)" do
    Field15.struct_new(@value)
  end

  bench "record (15 fields size)" do
    Field15.record_new(@value)
  end

  bench "l-type (15 fields size)" do
    Field15.calculus_new(@value)
  end
end
