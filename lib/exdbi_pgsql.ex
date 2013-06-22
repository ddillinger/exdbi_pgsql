defrecord DBI.PostgreSQL, conn: nil do

  alias :pgsql, as: P

  def connect(opts) do
     host = to_char_list(opts[:host] || "localhost")
     args = [host]
     unless nil?(opts[:username]) do
       args = [to_char_list(opts[:username])|args]
     end
     unless nil?(opts[:password]) do
       args = [to_char_list(opts[:password])|args]
     end
     options = [
                 database: if nil?(opts[:database]) do
                   :undefined
                 else
                   to_char_list(opts[:database])
                 end,
                 port: opts[:port] || 5432,
                 ssl: opts[:ssl] || false,
                 ssl_opts: opts[:ssl_opts] || :undefined,
                 timeout: opts[:timeout] || 5000,
               ]
     case apply(P, :connect, Enum.reverse([options|args])) do
       {:ok, conn} -> new(conn: conn)
     end
  end
end
