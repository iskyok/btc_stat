class CompanyInvest < ApplicationRecord
  
  
  def self.update_all_company_id
    self.all.each do |row|
      company=Company.find_by(name: row.company_name)
      row.update(company_id: company.id) if company
    end
  end

end
