defmodule Docs.Repo.Migrations.EnableFullTextSearchForPostgres do
  use Ecto.Migration

  def up do
    execute "CREATE extension if not exists pg_trgm;"
    execute "CREATE INDEX document_name_trgm_index ON documents USING gin (name gin_trgm_ops);"
  end

  def down do
    execute "DROP INDEX document_name_trgm_index;"
  end
end
