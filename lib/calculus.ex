defmodule Calculus do
  @moduledoc """
  Proof of concept inspired by church encoding.

  Example of λ-type `Stack` have:

  - `push/2` method
  - `pop/1` method

  Example of λ-type `User` have:

  - mutable `name` field (`get_name/1`, `set_name/2` methods)
  - immutable `id` field (`get_id/1` method)
  - private `balance` field (used internally in `deposit/2` and `withdraw/2` methods)

  ## Example

  ```
  iex> s0 = Stack.new([1, 2])
  iex> s1 = s0 |> Stack.push(0)
  iex> s2 = s1 |> Stack.pop()
  iex> s2 |> Stack.return()
  {:ok, 0}
  iex> s3 = s2 |> Stack.pop() |> Stack.pop
  iex> s3 |> Stack.return
  {:ok, 2}
  iex> s3 |> Stack.pop() |> Stack.return
  {:error, :empty_stack}
  iex> Enum.all?([s0, s1, s2, s3], &is_function/1)
  true

  iex> u0 = User.new(id: 1, name: "Jessy")
  iex> 1 = User.get_id(u0)
  iex> "Jessy" = User.get_name(u0)
  iex> u1 = User.set_name(u0, "Bob")
  iex> "Jessy" = User.return(u1)
  iex> "Bob" = User.get_name(u1)
  iex> u2 = User.deposit(u1, 100)
  iex> :ok = User.return(u2)
  iex> u3 = User.withdraw(u2, 50)
  iex> :ok = User.return(u3)
  iex> u4 = User.withdraw(u3, 51)
  iex> :insufficient_funds = User.return(u4)
  iex> Enum.all?([u0, u1, u2, u3, u4], &is_function/1)
  true

  iex> User.new(id: 1, name: "Jessy") |> User.deposit(100) |> User.set_name("Bob") |> User.withdraw(50) |> User.get_name
  "Bob"

  iex> u = User.new(id: 1, name: "Jessy")
  iex> u.(:get_name, :fake_security_key)
  ** (RuntimeError) For instance of the type Elixir.Calculus got unsupported CMD=:get_name with SECURITY_KEY=:fake_security_key

  iex> User.get_name(&({&2, &1}))
  ** (RuntimeError) Instance of the type Elixir.User can't be created in other module Elixir.CalculusTest
  ```
  """

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

  defmacro defcalculus(quoted_state, do: raw_eval_clauses) do
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
      |> case do
        {:__block__, _, []} -> []
        [_ | _] -> raw_eval_clauses
      end
      |> Enum.map(&add_security_key/1)
      |> Enum.concat(default_eval_clause)

    eval_fn = {:fn, [], eval_clauses}

    quote location: :keep do
      @security_key 64 |> :crypto.strong_rand_bytes() |> Base.encode64() |> String.to_atom()

      defmacrop calculus(state: state, return: return) do
        cmod = unquote(__MODULE__)

        quote location: :keep do
          unquote(cmod).new(unquote(state), unquote(return))
        end
      end

      defmacrop calculus(return: return, state: state) do
        cmod = unquote(__MODULE__)

        quote location: :keep do
          unquote(cmod).new(unquote(state), unquote(return))
        end
      end

      defmacrop calculus(some) do
        "Calculus expect keyword list, example: calculus(state: foo, return: bar). But got term #{
          inspect(some)
        }"
        |> raise
      end

      defp eval(it, cmd) do
        case Function.info(it, :module) do
          {:module, __MODULE__} ->
            cs = it.(cmd, @security_key)
            unquote(quoted_state) = unquote(__MODULE__).state(cs)
            unquote(__MODULE__).new(unquote(eval_fn), unquote(__MODULE__).return(cs))

          {:module, unquote(__MODULE__)} ->
            it
            |> unquote(__MODULE__).state()
            |> eval(cmd)

          {:module, module} ->
            "Instance of the type #{__MODULE__} can't be created in other module #{module}"
            |> raise
        end
      end

      @doc """
      - Accepts value of `#{inspect(__MODULE__)}` λ-type
      - Returns result of the latest called method of this value
      """
      def return(it) do
        unquote(__MODULE__).return(it)
      end

      defmacrop construct(state) do
        cmod = unquote(__MODULE__)

        quote location: :keep do
          fn :new, @security_key ->
            unquote(cmod).new(unquote(state), :ok)
          end
          |> eval(:new)
        end
      end
    end
  end

  #
  # define calculus data type as church-encoded type as well
  #

  require Record

  Record.defrecordp(:calculus,
    state: nil,
    return: nil
  )

  @security_key 64 |> :crypto.strong_rand_bytes() |> Base.encode64() |> String.to_atom()

  defp eval(it0, cmd) do
    case Function.info(it0, :module) do
      {:module, __MODULE__} ->
        calculus(
          state: calculus(state: state1, return: return1) = state0,
          return: return0
        ) = it0.(cmd, @security_key)

        it1 = fn
          :state, @security_key ->
            calculus(state: state0, return: state1)

          :return, @security_key ->
            calculus(state: state0, return: return1)

          cmd, security_key ->
            raise(
              "For instance of the type #{__MODULE__} got unsupported CMD=#{inspect(cmd)} with SECURITY_KEY=#{
                inspect(security_key)
              }"
            )
        end

        calculus(state: it1, return: return0)

      {:module, module} ->
        "Instance of the type #{__MODULE__} can't be created in other module #{module}"
        |> raise
    end
  end

  def new(state0, return0) do
    calculus(state: state1, return: :ok) =
      fn
        :new, @security_key ->
          calculus(
            state: calculus(state: state0, return: return0),
            return: :ok
          )
      end
      |> eval(:new)

    state1
  end

  def state(it) do
    calculus(state: ^it, return: return) = eval(it, :state)
    return
  end

  def return(it) do
    calculus(state: ^it, return: return) = eval(it, :return)
    return
  end
end
