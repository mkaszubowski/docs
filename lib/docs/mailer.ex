defmodule Docs.Mailer do
  use Mailgun.Client,
    domain: Application.get_env(:docs, :mailgun_domain),
    key: Application.get_env(:docs, :mailgun_key)

  def send_invitation(email_address, link) do
    IO.puts(inspect Application.get_env(:docs, :mailgun_domain))
    IO.puts(link)
    send_email(to: email_address,
               from: "docs@example.com",
               subject: "Invitation",
               text: link)
  end
end
