module Git
  class Author
    attr_accessor :name, :email, :date
    
    def initialize(author_string = nil)
      if m = /(.*?) <(.*?)> (\d+) (.*)/.match(author_string)
        @name = m[1]
        @email = m[2]
        @date = Time.at(m[3].to_i)
      end
    end
    
    def self.from_parts(name, email, date = Time.now)
      a = Author.new
      a.name = name
      a.email = email
      a.date = date
      return a
    end
  end
end