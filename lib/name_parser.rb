class NameParser
  def initialize(name)
    @name = name
  end

  def parse
    # return false if @name is not a String
    return false unless @name.is_a?(String)

    name_hash = {:first_name => nil, :middle_initial => nil, :last_name => nil}
    if @name.match(/,/)
      parts = @name.split(',')
      name_hash[:last_name] = parts[0]
      first_and_middle = parts[1].split

      if first_and_middle[1] && first_and_middle[1].size > 2
       name_hash[:first_name] = first_and_middle.join(' ')
      else
       name_hash[:first_name] = first_and_middle[0]
       name_hash[:middle_initial] = first_and_middle[1].first if first_and_middle[1]
      end
    else
      parts = @name.split
      name_hash[:first_name] = parts[0]

      if parts.size == 3
        if parts[1].size > 2
          name_hash[:first_name] += parts[1]
        else
          name_hash[:middle_initial] = parts[1].first if parts[1]
        end
      end

      name_hash[:last_name] = parts.size==3 ? parts[2] : parts[1]
    end

    # return false if all of the values are empty (nil, "")
    return false unless name_hash.values.any?{|x| x.present?}

    # default return the name hash
    name_hash
  end
end
