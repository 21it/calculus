# Calculus

Encapsulation. One of the basic principles of modern software development. We hide implementation details of the entity and expose to outer world just safe interface for this entity. That's great idea because of many reasons. Erlang and Elixir ecosystem supports this principle a lot: we have private functions and macros inside our modules, we have internal states inside our processes. But unfortunately there is one place where encapsulation is completely broken at the moment (Erlang/OTP 22, Elixir 1.9.1). This place is term of user defined data type, like record or structure.

This package introduces another way to define a new data type and safe interface for it. Inspired by Alonzo Church. Powered by Lambda Calculus.

<img src="priv/img/logo.png" width="300"/>

## Problem

First of all, let's figure out what's wrong with Elixir structs. For instance let's consider `URI` data type which is part of standard library (Elixir 1.9.1).

First statement:

- **default data constructor `%URI{}` is always public**

You can say "hey, this is not a constructor function, it a syntactic sugar for literal term". But anyway, this is **expression** and value of this expression is Elixir struct with type `URI`. For simplicity I'll call this thing as "default constructor". And this default constructor is always public. Indeed, you can write in any place or your program something like this:

```elixir
iex> uri = %URI{host: :BANG}
%URI{
  authority: nil,
  fragment: nil,
  host: :BANG,
  path: nil,
  port: nil,
  query: nil,
  scheme: nil,
  userinfo: nil
}
```

Is `uri` term valid instance of the `URI` type? Probably not, let's try to do something with it:

```elixir
iex> URI.to_string(uri)

** (FunctionClauseError) no function clause matching in String.contains?/2
```

Oops, our self-made instance of `URI` type caused exception. Default constructor does not validate arguments, and this is a problem in our case because `host` at least have to be instance of `String.t` type. As a solution of this problem, developers introduced concept of [smart constructors](https://wiki.haskell.org/Smart_constructors). Do we have a smart constructor for `URI` type? Probably here it is:

```elixir
iex> uri = URI.parse("https://hello.world")
%URI{
  authority: "hello.world",
  fragment: nil,
  host: "hello.world",
  path: nil,
  port: 443,
  query: nil,
  scheme: "https",
  userinfo: nil
}
```

Beautiful. We have a smart constructor which creates instance of the type `URI` properly. But remember our first statement? Default constructor is always public, which means that we can just **HOPE** that people will use smart constructor instead of default one. Concept of the smart constructors implies fact that we will hide default unsafe constructors. But we can't reach it with Elixir structs.

Second statement:

- **all fields of `URI` instance are public**

That's also true, because we can access any field of `URI` type instance in any place of our program (where this instance exists):

```elixir
iex> uri = URI.parse("https://hello.world")
iex> %URI{host: host} = uri
iex> host
"hello.world"
```

Concept of Elixir structs does not distinguish fields which are meant to be used in external world and fields which are meant only for internal usage. Sad but true, we just can write some documentation and **HOPE** that people will read it and follow our guidelines.

Third statement:

- **all fields of `URI` instance are mutable (in functional meaning)**

This sentence looks weird because all Erlang/Elixir terms are immutable, right? I will explain what I meant by example:

```elixir
iex> uri = URI.parse("https://hello.world")
iex> uri = %URI{uri | port: -80}
iex> URI.to_string(uri)
"https://hello.world:-80"
```

Let's consider what happened here:

- We create proper `uri` value with smart constructor
- We create new value based on `uri` by replacing the port with -80
- We apply `to_string` function to new `uri` value (and what scares - it worked)

This means that even if smart constructor has been used to create proper value of the type `URI`, we can just **HOPE** that this proper value will not be corrupted later.

We have 3 statements about Elixir structures. Don’t you think that we rely on **HOPE** too much when we are using structures? As we know, `Hope is Not a Strategy ©`. What if I will say you that we can have `real smart constructors`, `real private fields`, `real immutable fields` and many other fun things almost for free? And we can do it without any relatively expensive stuff like processes? Well, we really can, and all that we need - just one simple thing. It is λ-expression.

## Idea

Mathematical theory says us that λ-calculus is Turing complete, it is a universal model of computation that can be used to simulate any Turing machine. This statement means that through λ-expressions we can express things which we don't have in our language by default.
For example, let's imagine that we don't have boolean type in Elixir (it's not so far from the truth). To implement boolean type from scratch, we should understand real nature of boolean type. What is the value of boolean type? This is the choice between 2 possibilities. And we have only 2 values of this type (true and false). So we should have 2 λ-expressions which are representing all possible choices between 2 possibilities. There is only one way how we can express this (we can swap λtrue and λfalse definitions, but it will be still isomorphic):

```elixir
iex> λtrue = fn x, _ -> x end
#Function<13.91303403/2 in :erl_eval.expr/5>
iex> λfalse = fn _, x -> x end
#Function<13.91303403/2 in :erl_eval.expr/5>
```

Now we have definitions of all `λbool` type values without having `bool` type itself, let's implement `λand` function to show that it will behave in our λ-world the same way like `and` behaves in normal world. First of all, let's write signatures of both functions

```elixir
and(bool, bool)    :: bool
λand(λbool, λbool) :: λbool
```

As you can see, they are isomorphic. According type specifications, knowledge about boolean logic and our definition of `λbool`, function `λand` will look like:

```elixir
iex> λand = fn left, right -> left.(right, left) end
#Function<13.91303403/2 in :erl_eval.expr/5>
```

Let's use pin operator and pattern matching to show that behaviour of `λand` function is correct:

```elixir
iex> ^λtrue = λand.(λtrue, λtrue)
#Function<13.91303403/2 in :erl_eval.expr/5>
iex> ^λfalse = λand.(λfalse, λtrue)
#Function<13.91303403/2 in :erl_eval.expr/5>
iex> ^λfalse = λand.(λtrue, λfalse)
#Function<13.91303403/2 in :erl_eval.expr/5>
iex> ^λfalse = λand.(λfalse, λfalse)
#Function<13.91303403/2 in :erl_eval.expr/5>
```

As you can see, if we know the **behaviour** of the thing - we can express it in terms of λ-expressions and create **isomorphic** λ-thing from the void. If we can **describe** thing - it exists (at least in λ-world).

##  Usage (simple example)

This library is based on idea described above. It just provides syntactic sugar to express new data type in terms of λ-expressions and create new things which Elixir don't have by default. Let's implement simple λ-type [Stack](https://en.wikipedia.org/wiki/Stack_(abstract_data_type)) which will have just `push` and `pop` methods:

```elixir
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
end
```

`defcalculus` is syntactic sugar, a macro which accepts 2 arguments:

- internal representation of your data type (parameter `state` in this example)
- `do` block of code, any amount of clauses which describe **behaviour** of data type

Every clause of `do` block returns `calculus` expression which have 2 parameters

- `state` is updated internal state of data type
- `return` is term which is sent to outer world as result of the method

Let's run this code and check what do we have for our `Stack` λ-type (type "Stack." in iex and press "tab")

```elixir
iex> Stack.return
return/1
```

Not a lot. We have just one function `return` which is probably generated by `defcalculus` macro. Let's check documentation generated for this function:

```
iex> h Stack.return

def return(it)

  • Accepts value of Stack λ-type
  • Returns result of the latest called method of this value
```

Looks like it is related to `return` parameter in `calculus` expressions? Well it is. Anyway, it accepts instance of the `Stack` λ-type as argument. And we can't create it, because we even don't have a constructor. That is the main point of this library - type API is always explicit and contolled by developer. There is **NO** default public constructor. Let's create one explicit constructor:

```elixir
def new(state \\ []) when is_list(state) do
  construct(state)
end
```

Yes, constructor it is just normal Elixir function. It can have any name, accept any amount of arguments, call other functions, do argument validations, raise exceptions, do whatever you want. And yes, this particular example is real `smart constructor` because it validates argument and accept only list. Just compare behaviours:

```elixir
iex> %URI{host: :BANG}
%URI{
  authority: nil,
  fragment: nil,
  host: :BANG,
  path: nil,
  port: nil,
  query: nil,
  scheme: nil,
  userinfo: nil
}
iex> Stack.new(:BANG)
** (FunctionClauseError) no function clause matching in Stack.new/1
```

Wait, but what is this magical `construct` expression which is returned by our smart constructor? Well, this private expression is generated by `defcalculus` macro and it's doing amazing things. It accepts initial internal representation of λ-type (called `state` in our example) and creates instance of this λ-type based on it. Expression `construct` is real constructor, which lifts given term from normal world to λ-world, if we write type specification it will be something like:

```elixir
construct(t) :: λt
```

And there are 2 important statements about it

- `construct` constructor is always **private**
- `construct` constructor is **not** smart

Which means that all validations, and business-logic related checks should be done outside of it, in explicit user-defined smart constructor.

## Installation

The package can be installed by adding `calculus` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:calculus, "~> 0.1.0"}
  ]
end
```
