defmodule CalculusTest do
  use ExUnit.Case
  doctest Calculus

  test "Empty calculus" do
    compiled =
      quote do
        defmodule EmptyCalculus do
          use Calculus

          defcalculus _ do
          end
        end
      end
      |> Code.compile_quoted()

    assert [{EmptyCalculus, _}] = compiled
  end

  test "NonEmpty calculus" do
    compiled =
      quote do
        defmodule NonEmptyCalculus do
          use Calculus

          defcalculus x do
            :hello -> calculus(state: x, return: :world)
          end
        end
      end
      |> Code.compile_quoted()

    assert [{NonEmptyCalculus, _}] = compiled
  end
end
