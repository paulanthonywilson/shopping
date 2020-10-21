defmodule Shopping.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items) do
      add :name, :string
      add :got?, :boolean, default: false, null: false
      add :important?, :boolean, default: false, null: false
      add :checklist_id, references(:checklists, on_delete: :nothing)

      timestamps()
    end

    create index(:items, [:checklist_id])
  end
end
