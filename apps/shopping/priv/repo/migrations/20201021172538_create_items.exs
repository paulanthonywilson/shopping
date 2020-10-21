defmodule Shopping.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items) do
      add :name, :string
      add :got?, :boolean, default: false, null: false
      add :important?, :boolean, default: false, null: false
      add :list_id, references(:lists, on_delete: :nothing)

      timestamps()
    end

    create index(:items, [:list_id])
    create index(:items, [:list_id, :name], unique: true)
  end
end
