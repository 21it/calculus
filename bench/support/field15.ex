defmodule Calculus.Support.Field15 do
  #
  # struct
  #

  defstruct f0: nil,
            f1: nil,
            f2: nil,
            f3: nil,
            f4: nil,
            f5: nil,
            f6: nil,
            f7: nil,
            f8: nil,
            f9: nil,
            f10: nil,
            f11: nil,
            f12: nil,
            f13: nil,
            f: nil

  def struct_new(f), do: %__MODULE__{f: f}

  #
  # record
  #

  require Record

  Record.defrecord(:t,
    f0: nil,
    f1: nil,
    f2: nil,
    f3: nil,
    f4: nil,
    f5: nil,
    f6: nil,
    f7: nil,
    f8: nil,
    f9: nil,
    f10: nil,
    f11: nil,
    f12: nil,
    f13: nil,
    f: nil
  )

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
