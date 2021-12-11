class CreateKubernetes < ActiveRecord::Migration[6.1]
  def change
    create_table :kubernetes do |t|

      t.timestamps
    end
  end
end
