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
  iex> Enum.all?([s0, s1, s2, s3], &Stack.is?/1)
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
  iex> Enum.all?([u0, u1, u2, u3, u4], &User.is?/1)
  true

  iex> User.new(id: 1, name: "Jessy") |> User.deposit(100) |> User.set_name("Bob") |> User.withdraw(50) |> User.get_name
  "Bob"

  iex> u = User.new(id: 1, name: "Jessy")
  iex> u.(:get_name, :fake_security_key)
  ** (RuntimeError) For value of the type User got unsupported METHOD=:get_name with SECURITY_KEY=:fake_security_key

  iex> User.get_name(&({&2, &1}))
  ** (RuntimeError) Value of the type User can't be created in other module CalculusTest
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
    first_defined_eval_clauses =
      quote location: :keep do
        :return, @security_key ->
          calculus(state: state, return: return)

        :is?, @security_key ->
          calculus(state: state, return: true)
      end

    middle_eval_clauses =
      raw_eval_clauses
      |> case do
        {:__block__, _, []} -> []
        [_ | _] -> raw_eval_clauses
      end
      |> Enum.map(&add_security_key/1)

    last_eval_clauses =
      quote location: :keep do
        method, security_key ->
          raise(
            "For value of the type #{inspect(__MODULE__)} got unsupported METHOD=#{
              inspect(method)
            } with SECURITY_KEY=#{inspect(security_key)}"
          )
      end

    eval_fn = {
      :fn,
      [],
      first_defined_eval_clauses ++ middle_eval_clauses ++ last_eval_clauses
    }

    quote location: :keep do
      @security_key 64 |> :crypto.strong_rand_bytes() |> Base.encode64() |> String.to_atom()

      @opaque t :: __MODULE__.t()

      defmacrop calculus(state: state, return: return) do
        quote location: :keep do
          {unquote(state), unquote(return)}
        end
      end

      defmacrop calculus(return: return, state: state) do
        quote location: :keep do
          {unquote(state), unquote(return)}
        end
      end

      defmacrop calculus(some) do
        "Calculus expression expect keyword list, example: calculus(state: foo, return: bar), but got term #{
          inspect(some)
        }"
        |> raise
      end

      defp eval(it, method) do
        case Function.info(it, :module) do
          {:module, __MODULE__} ->
            #
            # TODO : test that "state" and "return" can not be overriden in "quoted_state" expression
            #
            calculus(state: state, return: return) = it.(method, @security_key)
            unquote(quoted_state) = state

            case method do
              :return -> return
              :is? -> return
              _ -> unquote(eval_fn)
            end

          {:module, module} ->
            "Value of the type #{inspect(__MODULE__)} can't be created in other module #{
              inspect(module)
            }"
            |> raise
        end
      end

      @doc """
      - Accepts value of `#{inspect(__MODULE__)}` λ-type
      - Returns result of the latest called method of this value
      """
      @spec return(__MODULE__.t()) :: term
      def return(it) do
        eval(it, :return)
      end

      @doc """
      - Accepts any term
      - Returns `true` if term is value of `#{inspect(__MODULE__)}` λ-type, otherwise returns `false`
      """
      @spec is?(term) :: boolean
      def is?(it) do
        try do
          eval(it, :is?)
        rescue
          _ -> false
        end
      end

      defmacrop construct(state) do
        quote location: :keep do
          fn :new, @security_key ->
            calculus(state: unquote(state), return: :ok)
          end
          |> eval(:new)
        end
      end
    end
  end
end
