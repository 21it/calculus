defmodule Calculus do
  @moduledoc """
  New data types with real encapsulation.
  Create smart constructors, private and immutable fields, sum types and many other fun things.
  Inspired by Alonzo Church.
  """

  @doc """
  Imports `Calculus.defcalculus/2` macro
  """
  defmacro __using__(_) do
    quote location: :keep do
      import Calculus
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

  @doc """
  Macro to define λ-type
  """
  defmacro defcalculus(quoted_state, do: raw_eval_clauses) do
    quote location: :keep do
      unquote(__MODULE__).defcalculus(unquote(quoted_state), [], do: unquote(raw_eval_clauses))
    end
  end

  @doc """
  Macro to define λ-type
  """
  defmacro defcalculus(quoted_state, opts, do: raw_eval_clauses) do
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
            "For value of the type #{inspect(__MODULE__)} got unsupported METHOD=#{inspect(method)} with SECURITY_KEY=#{
              inspect(security_key)
            }"
          )
      end

    eval_fn = {
      :fn,
      [],
      first_defined_eval_clauses ++ middle_eval_clauses ++ last_eval_clauses
    }

    [export_return: export_return, generate_type: generate_type] =
      opts
      |> parse_opts()

    return_spec_ast =
      case generate_type do
        true ->
          quote location: :keep do
            @spec return(__MODULE__.t()) :: term
          end

        false ->
          quote location: :keep do
          end
      end

    return_ast =
      case export_return do
        true ->
          quote location: :keep do
            @doc """
            - Accepts value of `#{inspect(__MODULE__)}` λ-type
            - Returns result of the latest called method of this value
            """
            unquote(return_spec_ast)

            def return(it) do
              eval(it, :return)
            end
          end

        false ->
          quote location: :keep do
            defp return(it) do
              eval(it, :return)
            end
          end
      end

    generate_type_ast =
      case generate_type do
        true ->
          quote location: :keep do
            @opaque t :: __MODULE__.t()
          end

        false ->
          quote location: :keep do
          end
      end

    quote location: :keep do
      @security_key 64 |> :crypto.strong_rand_bytes() |> Base.encode64() |> String.to_atom()

      unquote(generate_type_ast)

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
        "Calculus expression expect keyword list, example: calculus(state: foo, return: bar), but got term #{inspect(some)}"
        |> raise
      end

      defp eval(it, method) do
        case :erlang.fun_info(it, :module) do
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
            "Value of the type #{inspect(__MODULE__)} can't be created in other module #{inspect(module)}"
            |> raise
        end
      end

      unquote(return_ast)

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

  @default_opts [export_return: true, generate_type: true]
  @opts_keys @default_opts |> Keyword.keys() |> Enum.sort()

  defp parse_opts(opts) do
    with true <- opts |> Keyword.keyword?(),
         true <- opts |> Keyword.values() |> Enum.all?(&is_boolean/1),
         keys <- opts |> Keyword.keys(),
         true <- keys |> Enum.all?(&(&1 in @opts_keys)),
         true <- keys == Enum.uniq(keys) do
      @default_opts
      |> Keyword.merge(opts)
      |> Enum.sort()
    else
      false ->
        "Expected defcalculus opts [export_return: bool, generate_type: bool], but got #{inspect(opts)}"
        |> raise
    end
  end
end
