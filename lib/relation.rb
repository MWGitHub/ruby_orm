class Relation
  def initialize
    @query = ''
  end

  def select(input)
    @query += input
  end
end
