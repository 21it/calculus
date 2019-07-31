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

  defcalculus user(id: id, name: name, balance: balance) = it do
    :get_name ->
      %Calculus{
        it: it,
        returns: name
      }

    {:set_name, new_name} ->
      %Calculus{
        it: user(it, name: new_name),
        returns: name
      }

    :get_id ->
      %Calculus{
        it: it,
        returns: id
      }

    {:deposit, amount} ->
      %Calculus{
        it: user(it, balance: balance + amount),
        returns: :ok
      }

    {:withdraw, amount} when amount <= balance ->
      %Calculus{
        it: user(it, balance: balance - amount),
        returns: :ok
      }

    {:withdraw, _} ->
      %Calculus{
        it: it,
        returns: :insufficient_funds
      }
  end

  def new(id: id, name: name) when is_integer(id) and id > 0 and is_binary(name) do
    %Calculus{it: it, returns: :ok} =
      %Calculus{
        it: user(id: id, name: name, balance: 0),
        returns: :ok
      }
      |> pure()

    it
  end

  def get_name(it) do
    %Calculus{returns: name} = eval(it, :get_name)
    name
  end

  def set_name(it, name) when is_binary(name) do
    eval(it, {:set_name, name})
  end

  def get_id(it) do
    %Calculus{returns: id} = eval(it, :get_id)
    id
  end

  def deposit(it, amount) when is_integer(amount) and amount > 0 do
    %Calculus{
      it: new_it,
      returns: :ok
    } = eval(it, {:deposit, amount})

    new_it
  end

  def withdraw(it, amount) when is_integer(amount) and amount > 0 do
    eval(it, {:withdraw, amount})
  end
end
