defmodule Stack do
  use Calculus

  defcalculus it do
    {:push, x} when is_integer(x) ->
      %Calculus{it: [x | it], returns: :ok}

    :pop ->
      case it do
        [] ->
          returns = {:error, "Can't pop from empty instance of the #{__MODULE__}"}
          %Calculus{it: it, returns: returns}

        [x | xs] ->
          %Calculus{it: xs, returns: {:ok, x}}
      end

    :to_list ->
      %Calculus{it: it, returns: it}
  end

  def new(it) when is_list(it), do: pure(%Calculus{it: it, returns: :ok})
  def push(it, x), do: eval(it, {:push, x})
  def pop(it), do: eval(it, :pop)
  def to_list(it), do: eval(it, :to_list)
end
