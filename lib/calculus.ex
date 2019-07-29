defmodule Calculus do
  @moduledoc """
  Proof of concept inspired by church encoding

  ## Example

  ```
  iex> %Calculus{it: it0, returns: :ok} = Stack.new([1, 2, 3])
  iex> %Calculus{it: it1, returns: :ok} = Stack.push(it0, 0)
  iex> %Calculus{it: it2, returns: {:ok, 1}} = Stack.pop(it0)
  iex> %Calculus{it: it3, returns: [1, 2, 3]} = Stack.to_list(it0)
  iex> %Calculus{it: it4, returns: [0, 1, 2, 3]} = Stack.to_list(it1)
  iex> %Calculus{it: it5, returns: [2, 3]} = Stack.to_list(it2)
  iex> Enum.all?([it0, it1, it2, it3, it4, it5], &is_function/1)
  true

  iex> %Calculus{it: it0, returns: :ok} = Stack.new([])
  iex> %Calculus{it: it1, returns: returns} = Stack.pop(it0)
  iex> Enum.all?([it0, it1], &is_function/1)
  true
  iex> returns
  {:error, "Can't pop from empty instance of the Elixir.Stack"}

  iex> Stack.push(&({&2, &1}), 0)
  ** (RuntimeError) Instance of the type Elixir.Stack can't be created in other module Elixir.CalculusTest

  iex> %Calculus{it: it, returns: :ok} = Stack.new([1, 2, 3])
  iex> it.(:pop, :fake_security_key)
  ** (RuntimeError) For instance of the type Elixir.Stack got unsupported CMD=:pop with SECURITY_KEY=:fake_security_key
  ```
  """

  @enforce_keys [:it, :returns]
  defstruct @enforce_keys

  defmacro __using__(_) do
    quote location: :keep do
      import Calculus, only: [defcalculus: 2]
    end
  end

  defp add_security_key({:-> = exp, ctx, [left, right]}) do
    key = {
      :@,
      [context: Elixir, import: Kernel],
      [{:security_key, [context: Elixir], Elixir}]
    }

    new_left =
      case left do
        [{:when, ctx0, [e | es]}] -> [{:when, ctx0, [e, key | es]}]
        [e] -> [e, key]
      end

    {exp, ctx, [new_left, right]}
  end

  defmacro defcalculus(quoted_it, do: raw_eval_clauses) do
    default_eval_clause =
      quote location: :keep do
        cmd, security_key ->
          raise(
            "For instance of the type #{__MODULE__} got unsupported CMD=#{inspect(cmd)} with SECURITY_KEY=#{
              inspect(security_key)
            }"
          )
      end

    eval_clauses =
      raw_eval_clauses
      |> Enum.map(&add_security_key/1)
      |> Enum.concat(default_eval_clause)

    eval_fn = {:fn, [], eval_clauses}

    quote location: :keep do
      @security_key 64 |> :crypto.strong_rand_bytes() |> Base.encode64() |> String.to_atom()

      defp eval(fx, cmd) do
        case Function.info(fx, :module) do
          {:module, __MODULE__} ->
            %Calculus{it: unquote(quoted_it), returns: returns} = fx.(cmd, @security_key)
            %Calculus{it: unquote(eval_fn), returns: returns}

          {:module, module} ->
            "Instance of the type #{__MODULE__} can't be created in other module #{module}"
            |> raise
        end
      end

      defp pure(%Calculus{} = x) do
        eval(fn :new, @security_key -> x end, :new)
      end
    end
  end
end
