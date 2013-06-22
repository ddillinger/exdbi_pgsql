defimpl DBI, for: DBI.PostgreSQL do

  use DBI.Implementation

  alias DBI.PostgreSQL, as: T
  alias :pgsql, as: P

  Record.import DBI.PostgreSQL.Error, as: :error

  def query(T[conn: conn], statement, []) do
    process_result(P.squery(conn, statement))
  end
  def query(T[conn: conn], statement, bindings) do
    parsed_statement = DBI.Statement.parse(statement)
    {expr, bindings_list} =
    Enum.reduce(parsed_statement, {"", []}, fn
      (item, {expr, bindings_list}) ->
        if is_atom(item) do
          {expr <> "$#{length(bindings_list) + 1}", [bindings[item]|bindings_list]}
        else
          {expr <> item, bindings_list}
        end
    end)
    bindings_list = Enum.reverse bindings_list
    process_result(P.equery(conn, expr, bindings_list))
  end

  defp process_result({:ok, columns, rows}) do
    process_result({:ok, nil, columns, rows})
  end
  defp process_result({:ok, count}) do
    {:ok, result(count: count)}
  end
  defp process_result({:ok, count, columns, rows}) do
    column_names = lc {:column, name, _type, _size, _modifier, _format} inlist columns, do: name
    {:ok, result(count: count, columns: column_names, rows: rows)}
  end
  defp process_result({:error, {:error, severity, code, description, extra}}) do
    {:error, error(severity: severity, code: code, description: description, extra: extra)}
  end
end