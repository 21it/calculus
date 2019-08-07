# Calculus

Encapsulation. One of the basic principles of modern software development. We hide implementation details of the entity and expose to outer world just safe interface for this entity. That's great idea because of many reasons. Erlang and Elixir ecosystem supports this principle a lot: we have private functions and macros inside our modules, we have internal states inside our processes. But unfortunately there is one place where encapsulation is completely broken at the moment (Erlang/OTP 22, Elixir 1.9.1). This place is term of user defined data type, like record or structure.

This package introduces another way to define a new data type and safe interface for it. Inspired by Alonzo Church. Powered by Lambda Calculus.

<img src="priv/img/logo.png" width="300"/>

## Installation

The package can be installed by adding `calculus` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:calculus, "~> 0.1.0"}
  ]
end
```

## Readme!

This pretty long readme contains detailed information about the problem which is the cause of this library, also description of idea which is foundation of this library and step-by-step example. I strongly recommend to read it, but if you are sure that you don't need these details and you can figure out everything from concrete examples, you can find them here:

- Simple `Stack` data type example (smart constructor, push and pop methods)
  - [code](https://github.com/timCF/calculus/blob/master/test/support/stack.ex)
  - [tests](https://github.com/timCF/calculus/blob/master/test/stack_test.exs)
- OOP-like `User` data type example (smart constructor, setters, getters, methods)
  - [code](https://github.com/timCF/calculus/blob/master/test/support/user.ex)
  - [tests](https://github.com/timCF/calculus/blob/master/test/user_test.exs)

## Problem

First of all, let's figure out what's wrong with Elixir structs. For instance let's consider `URI` data type which is part of standard library (Elixir 1.9.1).

First statement:

- **default constructor `%URI{}` of data type `URI` is always public**

Somebody can say "hey, this is not a constructor function, it's a syntactic sugar for value, literal Elixir term". But anyway, this is **expression** and value of this expression is Elixir struct of `URI` type. For simplicity I'll call this thing as **default constructor**. And this default constructor is always public. Indeed, you can write in any place or your program something like this:

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

Is `uri` term valid value of the `URI` type? Probably not, let's try to do something with it:

```elixir
iex> URI.to_string(uri)

** (FunctionClauseError) no function clause matching in String.contains?/2
```

Oops, this value of `URI` type caused exception. Default constructor does not validate arguments, and this is a problem in our case because `host` at least have to be value of `String.t` type. As a solution of this problem, developers introduced concept of [smart constructors](https://wiki.haskell.org/Smart_constructors). Do we have a smart constructor for `URI` type? Probably here it is:

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

Beautiful. We have a smart constructor which creates value of the type `URI` properly. But remember our first statement? Default constructor is always public, which means that we can just **hope** that people will use smart constructor instead of default one. Concept of the smart constructors implies fact that we will hide unsafe default constructors. But we can't reach it with Elixir structs.

Second statement:

- **all fields of `URI` value are public**

That's also true, because we can access any field of `URI` value in any place of our program (where this value exists):

```elixir
iex> uri = URI.parse("https://hello.world")
iex> %URI{host: host} = uri
iex> host
"hello.world"
```

Concept of Elixir structs does not distinguish fields which are meant to be used in external world and fields which are meant only for internal usage. Sad but true, we just can write some documentation and **hope** that people will read it, follow our guidelines and will not change or rely on data which is meant to be private.

Third statement:

- **all fields of `URI` value are mutable (in functional meaning)**

This sentence looks weird because all Erlang/Elixir terms are immutable, right? I will explain what I meant by example:

```elixir
iex> uri0 = URI.parse("https://hello.world")
iex> uri1 = %URI{uri0 | port: -80}
iex> URI.to_string(uri1)
"https://hello.world:-80"
```

Let's consider what happened here:

- We create proper `uri0` value with smart constructor
- We create new value `uri1` based on `uri0` by replacing the port with -80
- We apply `to_string` function to new `uri1` value (and what scares - it worked)

This means that even if smart constructor has been used to create proper value of the type `URI`, we can just **hope** that this proper value will not be corrupted later.

We have 3 statements about Elixir structures. Don’t you think that we rely on **hope** too much? As we know, "Hope is Not a Strategy" ©. What if I will say you that we can have real `smart constructors`, real `private fields`, real `immutable fields` and many other fun things almost for free? And we can do it without any relatively expensive stuff like processes? Well, we really can, and all that we need - just one simple thing. It is λ-expression.

## Idea

Mathematical theory says us that λ-calculus is Turing complete, it is a universal model of computation that can be used to simulate any Turing machine. This statement means that using λ-expressions we can express things which we don't have in our language by default.

For example, let's imagine that we don't have boolean type in Elixir (it's not so far from the truth). To implement boolean type from scratch, we should understand real nature of boolean type. What is the value of boolean type? This is the choice between 2 possibilities. And we have only 2 values of this type (true and false). So we should have 2 λ-expressions which are representing all possible choices between 2 possibilities. There is only one way how we can express this (well, we can swap λtrue and λfalse definitions, and it will be other way, but it will be isomorphic thing):

```elixir
iex> λtrue = fn x, _ -> x end
#Function<13.91303403/2 in :erl_eval.expr/5>
iex> λfalse = fn _, x -> x end
#Function<13.91303403/2 in :erl_eval.expr/5>
```

Now we have definitions of all values of `λbool` type without having `bool` type itself, let's implement `λand` function to show that it will behave in our λ-world the same way like `and` behaves in normal world. First of all, let's write signatures of both functions

```elixir
and(bool, bool)    :: bool
λand(λbool, λbool) :: λbool
```

As you can see, they are isomorphic. According type specifications, knowledge about boolean logic and our definitions of `λtrue` and `λfalse`, our new `λand` function will look like:

```elixir
iex> λand = fn left, right -> left.(right, left) end
#Function<13.91303403/2 in :erl_eval.expr/5>
```

Let's use pin operator and pattern matching to show that behaviour of `λand` function is correct (remember, we still can't use normal boolean type, because we imagined that it just not exist):

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

This library is based on idea described above. It just provides syntactic sugar to express new types in terms of λ-expressions to create new things which Elixir don't have by default. For simplicity, I'll just name these new kind of types as **λ-types**. Let's implement simple λ-type [Stack](https://en.wikipedia.org/wiki/Stack_(abstract_data_type)) which will have just `push` and `pop` methods:

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
- `do` block of code, any amount of clauses which describe behaviour of data type against incoming data. For simplicity let's name these clauses as **methods**

Every method returns `calculus` expression which have 2 parameters

- `state` is updated internal state of λ-type
- `return` is term which is sent to outer world as result of the method call

Let's run this code and check what do we have for our `Stack` λ-type (type "Stack." in iex and press "tab")

```elixir
iex> Stack.
is?/1       return/1
```

Not a lot. We have 2 functions `is?` and `return` which are generated by `defcalculus` macro. Let's check documentation generated for these functions:

```
iex(1)> h Stack.is?

  def is?(it)

  @spec is?(term()) :: boolean()

  • Accepts any term
  • Returns true if term is value of Stack λ-type, otherwise returns false

iex> h Stack.return

  def return(it)

  @spec return(Stack.t()) :: term()

  • Accepts value of Stack λ-type
  • Returns result of the latest called method of this value
```

The purpose of `is?` function is pretty obvious. But what about `return` function? Looks like it is related to `return` parameter of `calculus` expressions? Well, it is. Anyway, these 2 functions are accepting value of the `Stack` λ-type as an argument. And we can't create it now, because we even don't have a constructor. That is the main point of this library - type API is always explicit and controlled by developer. There is **NO** default public constructor. Let's create one constructor manually:

```elixir
@spec new(list) :: t
def new(state \\ []) when is_list(state) do
  construct(state)
end
```

Yes, this constructor it is just normal Elixir function. It can have any name, accept any amount of arguments, call other functions, do argument validations, raise exceptions, do whatever you want. And yes, this particular example is real `smart constructor` because it validates argument and accepts only lists. Just compare behaviours:

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

Now we can see the main difference between default constructor and smart constructor:

- default constructor implies the possibility of existence of invalid values of type
- smart constructor implies existence of **only valid** values of the type

That's beautiful, but what is this magical `t` type in typespec and `construct` expression which is returned by our smart constructor? Well, both these things are generated by `defcalculus` macro - `t` is our `Stack` type representation for Dialyzer, and `construct` is private expression which is doing one small thing. It accepts initial internal representation of λ-type (called `state` in our example) and creates value of this λ-type based on it. Essentially `construct` is a very simple private constructor, which has only one purpose - to lift given term from normal world to λ-world. If we write its type specification - it will be something like this:

```elixir
construct(t) :: λt
```

And there are 2 important statements about it

- `construct` constructor is always **private**
- `construct` constructor is **not** smart

This means that all validations and business-logic related checks should be done outside of it, in explicit user-defined smart constructor.

Anyway, now we have a real smart constructor and we can create values of `Stack` λ-type and play around with `is?` and `return` functions:

```elixir
iex> stack = Stack.new([1, 2, 3])
#Function<1.55753174/2 in Calculus.eval/2>
iex> Stack.is?(stack)
true
iex> Stack.is?([1, 2, 3])
false
iex> Stack.return(stack)
:ok
```

What is this `:ok` atom returned from last expression? Well, you can interpret it like "ok, the value of Stack λ-type has been created". In this example, `stack` value is just new value, directly from constructor. No any methods has been called yet, and this `:ok` value is thing which constructor is sending to outer world like "result of the latest called method". This behaviour is hardcoded to private `construct` expression for simplicity.

That's nice, but what about `push` and `pop` methods? As I said before, business-logic related methods are not provided by default. So let's implement them explicitly:

```elixir
@spec push(t, term) :: t
def push(it, x), do: eval(it, {:push, x})

@spec pop(t) :: t
def pop(it), do: eval(it, :pop)
```

Most likely you already guessed - this private `eval` expression has been generated by `defcalculus`. It accepts 2 arguments:

- first is value of λ-type
- second is method, defined in one of `defcalculus` clauses

Typespec of `eval` expression can look like:

```elixir
eval(λt, method) :: λt
```

This `eval` expression just takes method from normal world and evaluates it in λ-world where given λ-type exists. Like previously considered `construct` expression, `eval` is also **private** and **not** smart. This means that all validations and business-logic related checks should be done outside of it, in explicit user-defined method.

Now we finally have full definition of our `Stack` λ-type and can play around with smart constructors and methods:

```elixir
iex> Stack.
is?/1       new/0       new/1       pop/1       push/2      return/1
iex> s0 = Stack.new([1, 2, 3])
#Function<1.41704973/2 in Calculus.eval/2>
iex> s1 = Stack.push(s0, 99)
#Function<1.41704973/2 in Calculus.eval/2>
iex> s2 = Stack.pop(s1)
#Function<1.41704973/2 in Calculus.eval/2>
iex> Stack.return(s2)
{:ok, 99}
iex> s3 = s2 |> Stack.pop |> Stack.pop |> Stack.pop
#Function<1.41704973/2 in Calculus.eval/2>
iex> Stack.return(s3)
{:ok, 3}
iex> s4 = Stack.pop(s3)
#Function<1.41704973/2 in Calculus.eval/2>
iex> Stack.return(s4)
{:error, :empty_stack}
iex> s4 == Stack.pop(s4)
true
```

As you can see, our `Stack` λ-type works as normal stack should work. All methods and constructors are explicit and 100% controlled by developer (except special `is?` and `return` methods). And we don't have direct access to internal state (which is list in our case). This thing is called encapsulation. And this thing leads to a very interesting statement:

- **If developer of λ-type `T` implements all smart constructors and methods for `T` properly (validations of external arguments etc), then value of λ-type `T` is always valid in ANY place of ANY program.**

We are not relying on **hope** anymore! Smart constructors, smart methods and encapsulation is much better strategy then just hope, isn't it? But maybe somebody can say: "hey, real type of λ-type value is just a function, so we can call it and access internal state without methods, we can create new functions and corrupt existing values". Let's try it:

```elixir
iex> s0 = Stack.new([1, 2, 3])
#Function<1.75866925/2 in Stack.eval/2>
iex> s0.(:pop, nil)
** (RuntimeError) For value of the type Stack got unsupported METHOD=:pop with SECURITY_KEY=nil
iex> s1 = &({&1, &2})
#Function<13.91303403/2 in :erl_eval.expr/5>
iex> Stack.return(s1)
** (RuntimeError) Value of the type Stack can not be created in other module :erl_eval
```

Our attempts to hack `Stack` failed. This library uses some pretty simple tricks which are giving guarantees that value of λ-type can be **created** or **evaluated** only inside the module where λ-type itself was defined.

## Another example

As I mentioned before, there is another, more complex OOP-like example of [User](https://github.com/timCF/calculus/blob/master/test/support/user.ex) λ-type with some [tests](https://github.com/timCF/calculus/blob/master/test/user_test.exs). I'll put here few interesting statements about it:

- It uses private `record` as internal representation. I think records are the best types for this purpose because

  - records have nice syntax sugar for values and pattern matching (like structs)
  - you can define multiple records in one module (unlike structs)
  - record can be defined as **private** entity (unlike structs)
  - records are extremely fast in most cases (faster than structs)


- It implements concept of `private`, `immutable` and `public` fields through explicit setters, getters and methods

- In some methods like getter `get_name`, utility function `return` is called inside the method. It completely make sense for getters because they never change internal state of λ-type value, so we can just `return` desired value to outer world for simplicity.

It's cool example, check it out!

## Known issues

- Lambda types are inferior in performance to classical data types like records or structs. In average:

  - λ-type constructors and setters ~ `2` times slower then default constructors and setters for structs
  - λ-type getters ~ `6 - 12` times slower then pattern matching on structs (but this is still pretty nice performance)

I have very basic benchmarks for constructors, setters and getters of isomorphic `records`, `structs` and `λ-types`. You can run benchmarks with `mix bench` command in terminal. Here are results I got on my mac mini:


| Constructor             |            |
|-------------------------|------------|
| record (1 field size)   | 0.02 µs/op |
| struct (1 field size)   | 0.03 µs/op |
| record (15 fields size) | 0.05 µs/op |
| struct (15 fields size) | 0.08 µs/op |
| λ-type (1 field size)   | 0.11 µs/op |
| λ-type (15 fields size) | 0.14 µs/op |

| Setter                  |            |
|-------------------------|------------|
| record (1 field size)   | 0.03 µs/op |
| struct (1 field size)   | 0.04 µs/op |
| record (15 fields size) | 0.05 µs/op |
| struct (15 fields size) | 0.05 µs/op |
| λ-type (1 field size)   | 0.09 µs/op |
| λ-type (15 fields size) | 0.11 µs/op |

| Getter                  |            |
|-------------------------|------------|
| record (1 field size)   | 0.01 µs/op |
| record (15 fields size) | 0.01 µs/op |
| struct (1 field size)   | 0.01 µs/op |
| struct (15 fields size) | 0.02 µs/op |
| λ-type (1 field size)   | 0.12 µs/op |
| λ-type (15 fields size) | 0.12 µs/op |

I have a plans about further performance optimizations.

- We can't use pattern matching to access even public fields of values of λ-types because formally they are just functions. I don't think it can be fixed in general.

- At the moment we can't properly use Elixir protocols with values of λ-types (because of the same reason). I have couple ideas about it and maybe will fix it.

- Internal state of value of λ-type is vulnerable for reading (not writing!) through `Function.info/2` core function. At the moment I don't know how to fix it:

  ```elixir
  iex> stack = Stack.new([1, 2, 3])
  #Function<1.90529338/2 in Stack.eval/2>
  iex> Function.info(stack, :env)
  {:env, [{[1, 2, 3], :ok}, [1, 2, 3]]}
  ```

  It's possible to read internal state using this function, but it's still impossible to create new corrupted value of λ-type based on this internal state. So all immutable and private data is still really immutable.

- Because of encapsulation protection mechanism, it's very hard to persist values of λ-types using default `:erlang.term_to_binary` and `:erlang.binary_to_term` core functions. It's very hard to do hot code upgrades as well. I think it's more like feature than bug, because if it was possible - then it breaks encapsulation, because there are zero guarantees that new code behaves against given term like old one. This is idiomatically correct, new and old versions of the same λ-type are different types in reality:

  ```elixir
  iex> stack = Stack.new([1, 2, 3])
  #Function<1.125256447/2 in Stack.eval/2>
  iex> Stack.is?(stack)
  true
  iex> r Stack
  {:reloaded, Stack, [Stack]}
  iex(4)> Stack.is?(stack)
  false
  ```

  If you want serialization mechanism for your λ-type, just provide it explicitly with methods and smart constructors. For example `to_json` method + `from_json` smart constructor. JSON is just example, it can be anything you want - text, protobuf, even Erlang binary term format.

## Conclusion

Lambda calculus is extremely powerful way to extend type system of Erlang and Elixir. This small library (~150 lines of code) already gives foundation for fantastic things. Do you want OOP-like DSL to define data types in terms of private, public, immutable fields, constructors and methods? Take couple quote-unquote expressions and just do it. Do you want smart constructors and abstract data types? It's here. Do you want data types with multiple default constructors like [Maybe](http://hackage.haskell.org/package/base-4.12.0.0/docs/Data-Maybe.html) or [Either](http://hackage.haskell.org/package/base-4.12.0.0/docs/Data-Either.html) monads? Why not? With lambda calculus there are no limits in programming languages, there is only one limit - our imagination.

## Special thanks

- [Renzo Carbonara](https://ren.zone/) for introduction to λ-calculus and amazing [book](https://atypeofprogramming.com/)
- [Ulisses Almeida](https://github.com/ulissesalmeida) for debugging sessions
- [Andrey Chernykh](https://github.com/madeinussr) for discussions about naming and design

<tt style="display: table; text-align: center; margin-left: auto; margin-right: auto;">
  Made with ❤️ by
  <a href="http://itkach.uk" target="_blank">Ilja Tkachuk</a>
</tt>
