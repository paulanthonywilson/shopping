defmodule Shopping.Repo.Migrations.AddCategoryIdToItem do
  use Ecto.Migration

  def change do
    alter table(:items) do
      add :category_id, references(:categories, on_delete: :nothing), default: 0, null: false
    end
  end
end
