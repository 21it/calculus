%{
  #
  # You can have as many configs as you like in the `configs:` field.
  configs: [
    %{
      #
      # Run any exec using `mix credo -C <name>`. If no exec name is given
      # "default" is used.
      #
      name: "default",
      #
      # These are the files included in the analysis:
      files: %{
        #
        # You can give explicit globs or simply directories.
        # In the latter case `**/*.{ex,exs}` will be used.
        #
        included: ["lib/", "src/", "web/", "apps/"],
        excluded: [~r"/_build/", ~r"/deps/"]
      },
      #
      # If you create your own checks, you must specify the source files for
      # them here, so they can be loaded by Credo before running the analysis.
      #
      requires: [],
      #
      # Credo automatically checks for updates, like e.g. Hex does.
      # You can disable this behaviour below:
      #
      check_for_updates: true,
      #
      # If you want to enforce a style guide and need a more traditional linting
      # experience, you can change `strict` to `true` below:
      #
      strict: true,
      #
      # If you want to use uncolored output by default, you can change `color`
      # to `false` below:
      #
      color: true,
      #
      # You can customize the parameters of any check by adding a second element
      # to the tuple.
      #
      # To disable a check put `false` as second element:
      #
      #     {Credo.Check.Design.DuplicatedCode, false}
      #
      checks: [
        {Credo.Check.Consistency.ExceptionNames},
        {Credo.Check.Consistency.LineEndings},
        {Credo.Check.Consistency.ParameterPatternMatching},
        {Credo.Check.Consistency.SpaceAroundOperators},
        {Credo.Check.Consistency.SpaceInParentheses},
        {Credo.Check.Consistency.TabsOrSpaces},

        # For some checks, like AliasUsage, you can only customize the priority
        # Priority values are: `low, normal, high, higher`
        #
        {Credo.Check.Design.AliasUsage, false},

        # For others you can set parameters

        # If you don't want the `setup` and `test` macro calls in ExUnit tests
        # or the `schema` macro in Ecto schemas to trigger DuplicatedCode, just
        # set the `excluded_macros` parameter to `[:schema, :setup, :test]`.
        #
        {Credo.Check.Design.DuplicatedCode, excluded_macros: []},

        # You can also customize the exit_status of each check.
        # If you don't want TODO comments to cause `mix credo` to fail, just
        # set this value to 0 (zero).
        #
        {Credo.Check.Design.TagTODO, priority: :low, exit_status: 0},
        {Credo.Check.Design.TagFIXME, priority: :low, exit_status: 0},
        {Credo.Check.Readability.FunctionNames},
        {Credo.Check.Readability.LargeNumbers},
        {Credo.Check.Readability.MaxLineLength, false},
        {Credo.Check.Readability.ModuleAttributeNames},
        {Credo.Check.Readability.ModuleDoc, false},
        {Credo.Check.Readability.ModuleNames, priority: :high},
        {Credo.Check.Readability.ParenthesesOnZeroArityDefs, priority: :high},
        {Credo.Check.Readability.ParenthesesInCondition, priority: :high},
        {Credo.Check.Readability.PredicateFunctionNames, priority: :high},
        {Credo.Check.Readability.PreferImplicitTry, false},
        {Credo.Check.Readability.RedundantBlankLines, priority: :low},
        {Credo.Check.Readability.StringSigils},
        {Credo.Check.Readability.TrailingBlankLine},
        {Credo.Check.Readability.TrailingWhiteSpace},
        {Credo.Check.Readability.VariableNames},
        {Credo.Check.Readability.Semicolons},
        {Credo.Check.Readability.SpaceAfterCommas, priority: :low},
        {Credo.Check.Refactor.DoubleBooleanNegation, priority: :high},
        {Credo.Check.Refactor.CondStatements},
        {Credo.Check.Refactor.CyclomaticComplexity, priority: :high, exit_status: 2, max_complexity: 12},
        {Credo.Check.Refactor.FunctionArity},
        {Credo.Check.Refactor.LongQuoteBlocks},
        {Credo.Check.Refactor.MatchInCondition},
        {Credo.Check.Refactor.NegatedConditionsInUnless, priority: :high, exit_status: 2},
        {Credo.Check.Refactor.NegatedConditionsWithElse, priority: :normal},
        {Credo.Check.Refactor.Nesting, max_nesting: 3, priority: :high, exit_status: 2},
        {Credo.Check.Refactor.PipeChainStart, false},
        {Credo.Check.Refactor.UnlessWithElse, priority: :higher, exit_status: 2},
        {Credo.Check.Warning.BoolOperationOnSameValues, priority: :high, exit_status: 2},
        {Credo.Check.Warning.IExPry, priority: :higher, exit_status: 2},
        {Credo.Check.Warning.IoInspect, priority: :higher, exit_status: 2},
        {Credo.Check.Warning.LazyLogging, false},
        {Credo.Check.Warning.OperationOnSameValues, priority: :higher, exit_status: 2},
        {Credo.Check.Warning.OperationWithConstantResult, priority: :higher, exit_status: 2},
        {Credo.Check.Warning.UnusedEnumOperation, priority: :higher, exit_status: 2},
        {Credo.Check.Warning.UnusedFileOperation, priority: :higher, exit_status: 2},
        {Credo.Check.Warning.UnusedKeywordOperation, priority: :higher, exit_status: 2},
        {Credo.Check.Warning.UnusedListOperation, priority: :higher, exit_status: 2},
        {Credo.Check.Warning.UnusedPathOperation, priority: :higher, exit_status: 2},
        {Credo.Check.Warning.UnusedRegexOperation, priority: :higher, exit_status: 2},
        {Credo.Check.Warning.UnusedStringOperation, priority: :higher, exit_status: 2},
        {Credo.Check.Warning.UnusedTupleOperation, priority: :higher, exit_status: 2},
        {Credo.Check.Warning.RaiseInsideRescue, priority: :higher, exit_status: 2},

        # Controversial and experimental checks (opt-in, just remove `, false`)
        #
        {Credo.Check.Refactor.ABCSize, false},
        {Credo.Check.Refactor.AppendSingleItem, priority: :normal},
        {Credo.Check.Refactor.VariableRebinding, priority: :normal},
        {Credo.Check.Warning.MapGetUnsafePass, priority: :high, exit_status: 0},
        {Credo.Check.Consistency.MultiAliasImportRequireUse, false},

        # Deprecated checks (these will be deleted after a grace period)
        #
        {Credo.Check.Readability.Specs, false},
        {Credo.Check.Warning.NameRedeclarationByAssignment, false},
        {Credo.Check.Warning.NameRedeclarationByCase, priority: :normal},
        {Credo.Check.Warning.NameRedeclarationByDef, priority: :normal},
        {Credo.Check.Warning.NameRedeclarationByFn, priority: :normal}

        # Custom checks can be created using `mix credo.gen.check`.
        #
      ]
    }
  ]
}
