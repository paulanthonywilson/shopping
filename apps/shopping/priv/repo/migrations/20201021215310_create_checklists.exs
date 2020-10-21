defmodule Shopping.Repo.Migrations.CreateChecklists do
  use Ecto.Migration

  def change do
    create table(:checklists) do
      add :name, :string

      timestamps()
    end
  end
end
