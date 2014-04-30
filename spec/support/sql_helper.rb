module SqlHelper
  def sql(sql, field = nil)
    result = ActiveRecord::Base.connection.select_all(sql, 'SQL', [])
    hash   = result.to_hash
    result   = hash.map do |h|
      hash_map = h.map do |k, v|
        type         = result.column_types[k]
        casted_value = type.type_cast v
        [k, casted_value]
      end
      Hash[hash_map]
    end
    # binding.pry
    field ? result.map { |h| h[field] } : result
  end

  def install_extension
    sql "CREATE EXTENSION #{Dumbo::Extension.new.name}"
  end
end
