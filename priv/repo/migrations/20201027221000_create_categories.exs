defmodule Shopping.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :emoji, :string
      add :category_name, :string
      add :ordering, :integer

      timestamps()
    end

    create index(:categories, [:ordering], unique: true)
  end
end
