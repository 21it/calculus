defmodule Stack do
  use Calculus

  defcalculus state do
    {:push, x} ->
      calculus(state: [x | state], return: :ok)

    :pop ->
      case state do
        [] -> calculus(state: state, return: {:error, :empty_stack})
        [x | xs] -> calculus(state: xs, return: {:ok, x})
      end
  end

  def new(state) when is_list(state), do: construct(state)
  def push(it, x), do: eval(it, {:push, x})
  def pop(it), do: eval(it, :pop)
end
