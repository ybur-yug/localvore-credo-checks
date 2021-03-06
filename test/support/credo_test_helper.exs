defmodule Credo.TestHelper do
  defmacro __using__(_) do
    quote do
      use ExUnit.Case
      import CredoSourceFileCase
      import CredoCheckCase
    end
  end
end

defmodule CredoSourceFileCase do
  def to_source_file(source) do
    to_source_file(source, Faker.Lorem.word() <> ".ex")
  end
  def to_source_file(source, filename) do
    case Credo.SourceFile.parse(source, filename) do
      %{valid?: true} = source_file -> source_file
      _ -> raise "Source could not be parsed!"
    end
  end

  def to_source_files(list) do
    list
    |> Enum.map(&to_source_file/1)
  end
end

defmodule CredoCheckCase do
  use ExUnit.Case

  alias Credo.Service.SourceFileIssues

  def refute_issues(source_file, check \\ nil, params \\ []) do
    issues = issues_for(source_file, check, params)
    assert [] == issues, "There should be no issues, got #{Enum.count(issues)}: #{to_inspected(issues)}"
    issues
  end

  def assert_issue(source_file, callback) when is_function(callback) do
    assert_issue(source_file, nil, [], callback)
  end
  def assert_issue(source_file, check, callback) when is_function(callback) do
    assert_issue(source_file, check, [], callback)
  end

  def assert_issue(source_file, check \\ nil, params \\ [], callback \\ nil) do
    issues = issues_for(source_file, check, params)
    refute Enum.count(issues) == 0, "There should be one issue, got none."
    assert Enum.count(issues) == 1, "There should be only 1 issue, got #{Enum.count(issues)}: #{to_inspected(issues)}"
    if callback, do: callback.(issues |> List.first)
    issues
  end

  def assert_issues(source_file, callback) when is_function(callback) do
    assert_issues(source_file, nil, [], callback)
  end
  def assert_issues(source_file, check, callback) when is_function(callback) do
    assert_issues(source_file, check, [], callback)
  end
  def assert_issues(source_file, check \\ nil, params \\ [], callback \\ nil) do
    issues = issues_for(source_file, check, params)
    assert Enum.count(issues) > 0, "There should be multiple issues, got none."
    assert Enum.count(issues) > 1, "There should be more than one issue, got: #{to_inspected(issues)}"
    if callback, do: callback.(issues)
    issues
  end

  defp issues_for(source_files, nil, _) when is_list(source_files) do
    source_files
    |> Enum.flat_map(&(&1.issues))
  end
  defp issues_for(source_files, check, params) when is_list(source_files) do
    return_value =
      source_files
      |> check.run(params)

    if check.run_on_all? do
      source_files
      |> SourceFileIssues.update_in_source_files
      |> Enum.flat_map(&(&1.issues))
    else
      return_value
      |> Enum.flat_map(&(&1.issues))
    end
  end
  defp issues_for(source_file, nil, _), do: source_file.issues
  defp issues_for(source_file, check, params), do: check.run(source_file, params)


  def assert_trigger([issue], trigger), do: [assert_trigger(issue, trigger)]
  def assert_trigger(issue, trigger) do
    assert trigger == issue.trigger
    issue
  end

  def to_inspected(value) do
    value
    |> Inspect.Algebra.to_doc(%Inspect.Opts{})
    |> Inspect.Algebra.format(50)
    |> Enum.join("")
  end
end
