defmodule User do
  use Calculus
  require Record

  Record.defrecordp(:user,
    id: nil,
    name: nil,
    balance: nil
  )

  @type user ::
          record(:user,
            id: pos_integer,
            name: String.t(),
            balance: integer
          )

  defcalculus it = user(name: name) do
    :get_name ->
      %Calculus{it: it, returns: name}
  end

  def new(id, name) when is_integer(id) and id > 0 and is_binary(name) do
    %Calculus{it: it, returns: :ok} =
      %Calculus{
        it: user(id: id, name: name, balance: 0),
        returns: :ok
      }
      |> pure()

    it
  end

  def get_name(it) do
    %Calculus{
      it: ^it,
      returns: name
    } = eval(it, :get_name)

    name
  end
end
