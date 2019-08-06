defmodule Stack do
  use Calculus

  @moduledoc """
  Simple `Stack` data type example.

  Internal representation of the `state` is list,
  but it's completely hidden inside this module.

  This data type have:

  - `push/2` method
  - `pop/1` method
  """

  defcalculus state do
    {:push, x} ->
      calculus(state: [x | state], return: :ok)

    :pop ->
      case state do
        [] -> calculus(state: state, return: {:error, :empty_stack})
        [x | xs] -> calculus(state: xs, return: {:ok, x})
      end
  end

  @spec new(list) :: t
  def new(state \\ []) when is_list(state), do: construct(state)

  @spec push(t, term) :: t
  def push(it, x), do: eval(it, {:push, x})

  @spec pop(t) :: t
  def pop(it), do: eval(it, :pop)
end
