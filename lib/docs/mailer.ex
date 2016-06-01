defmodule Docs.Mailer do
  use Mailgun.Client,
    domain: Application.get_env(:docs, :mailgun_domain),
    key: Application.get_env(:docs, :mailgun_key)

  def send_invitation(email_address, token) do
    IO.puts(inspect Application.get_env(:docs, :mailgun_domain))
    send_email(to: email_address,
               from: "docs@example.com",
               subject: "Welcome!",
               text: "Welcome to HelloPhoenix!")
  end
end
