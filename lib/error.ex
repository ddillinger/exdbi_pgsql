defexception DBI.PostgreSQL.Error, severity: nil, code: nil, description: nil, extra: nil do
  def message(__MODULE__[severity: severity, code: code,
                         description: description]) do
    "(#{severity}) #{code} #{description}"
  end
end