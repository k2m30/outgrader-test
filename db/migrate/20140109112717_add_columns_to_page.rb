class AddColumnsToPage < ActiveRecord::Migration
  def change
    add_column :pages, :title, :string
    add_column :pages, :original_html, :text
    add_column :pages, :adblock_html, :text
    add_column :pages, :outgrader_html, :text    
  end
end
