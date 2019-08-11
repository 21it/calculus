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

  test "Valid options for defcalculus/3" do
    compiled =
      quote do
        defmodule OptsCalculus do
          use Calculus

          defcalculus x, export_return: false, generate_opaque: false do
          end
        end
      end
      |> Code.compile_quoted()

    assert [{OptsCalculus, _}] = compiled
    refute :erlang.function_exported(OptsCalculus, :return, 1)
  end

  test "Invalid options for defcalculus/3" do
    assert_raise RuntimeError,
                 "Expected defcalculus opts [export_return: bool, generate_opaque: bool], but got [export_returnnnn: false, generate_opaque: false]",
                 fn ->
                   quote do
                     defmodule InvalidOptsCalculus do
                       use Calculus

                       defcalculus x, export_returnnnn: false, generate_opaque: false do
                       end
                     end
                   end
                   |> Code.compile_quoted()
                 end
  end
end
