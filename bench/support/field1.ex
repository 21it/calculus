defmodule Calculus.Support.Field1 do
  #
  # struct
  #

  defstruct f: nil
  def struct_new(f), do: %__MODULE__{f: f}

  #
  # record
  #

  require Record
  Record.defrecord(:t, f: nil)
  def record_new(f), do: t(f: f)

  #
  # λ-type
  #

  use Calculus

  defcalculus t(f: f) = state do
    :get_f -> calculus(state: state, return: f)
    {:set_f, x} -> calculus(state: t(state, f: x), return: f)
  end

  def calculus_new(x), do: t(f: x) |> construct()
  def calculus_get(it), do: it |> eval(:get_f) |> return()
  def calculus_set(it, x), do: it |> eval({:set_f, x})
end
