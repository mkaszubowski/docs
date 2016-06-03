defmodule Docs.TokenGenerator do
  def get_token(length \\ 20) do
    length
    |> :crypto.strong_rand_bytes
    |> Base.url_encode64
    |> binary_part(0, length)
  end
end
