require 'csv'

class Page < ActiveRecord::Base
  def self.to_csv
      CSV.generate do |csv|
        csv << column_names
        all.each do |page|
          csv << page.attributes.values_at(*column_names)
        end
      end
    end
end
