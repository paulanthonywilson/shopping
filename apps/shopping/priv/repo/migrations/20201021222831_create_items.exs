defmodule Shopping.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items) do
      add :name, :string, null: false
      add :lcase_name, :string, null: false
      add :got?, :boolean, default: false, null: false
      add :important?, :boolean, default: false, null: false
      add :checklist_id, references(:checklists, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:items, [:checklist_id])
    create index(:items, [:lcase_name])
    create index(:items, [:checklist_id, :name], unique: true)
  end
end
