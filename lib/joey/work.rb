module Joey
  class Work < Model
    
    define_properties :start_date, :end_date
    
    hash_populating_accessor :employer, "Page"
    hash_populating_accessor :location, "Page"
    hash_populating_accessor :position, "Page"
  end
end
