# app/models/transportador.rb
def self.top_semanal
  joins(:fretes)
    .where("fretes.created_at >= ?", 1.week.ago)
    .group(:id)
    .order("COUNT(fretes.id) DESC")
    .limit(3)
end
