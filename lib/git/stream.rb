module Git
  
  require 'time'
  
  #====================
  # Stream Classes
  # 
  # These classes must support the following methods
  # 
  #  to_s - write the command to the git protocol stream
  #====================
  
  class StreamCommit
    
    
    attr_accessor :branch, :mark, :author, :committer, :message, :ancestor, :changes
    
    def initialize()
      @branch = nil
      @mark = StreamMark.new
      @author = nil
      @committer = nil
      @message = nil
      @ancestor = nil
      @changes = []
    end
    
    def to_s 
      out = "commit refs/heads/#{branch.to_s}\n"
      out << "mark #{mark}\n" 
      out << "author #{author.name} <#{author.email}> #{author.date.rfc2822}\n" unless author == nil
      out << "committer #{committer.name} <#{committer.email}> #{committer.date.rfc2822}\n" unless committer == nil
      if (message == nil)
        out << StreamData.emit_empty_data
      else
        out << StreamData.emit_inline_data(message)
      end
      out << "from #{ancestor}\n" unless ancestor == nil
      changes.each do |c|
        out << c.to_s
      end
      out << "\n"
    end
  end
  
  class StreamMark

    @@mark_counter = 1
    
    def initialize(id = (@@mark_counter += 1))
      @id = id
    end
    
    def to_s
      ":#{@id}"
    end
  end
  
  # This class is used in the filemodify change on the commit stream
  # At this time only the inline mode data stream is supported
  class StreamFileModify
    
    attr_accessor :mode, :repository_path, :inline_data
    
    def initialize(repository_path, data)
      @mode = 100644
      @repository_path = repository_path
      @inline_data = data
    end
    
    def to_s
      "M #{mode} inline #{repository_path}\n#{StreamData.emit_inline_data(inline_data)}"
    end
  end
  
  class StreamFileDelete
    
    attr_accessor :repository_path
    
    def initialize(repository_path)
      @repository_path = repository_path
    end
    
    def to_s
      "D #{repository_path}\n"
    end
  end
  
  class StreamFileCopy
    
    attr_accessor :repository_path_from, :repository_path_to
    
    def initialize(repository_path_from, repository_path_to)
      @repository_path_from = repository_path_from
      @repository_path_to = repository_path_to
    end
    
    def to_s
      "C #{repository_path_from} #{repository_path_to}\n"
    end
    
  end
  
  class StreamFileRename
    
    attr_accessor :repository_path_from, :repository_path_to
    
    def initialize(repository_path_from,repository_path_to)
      @repository_path_from = repository_path_from
      @repository_path_to = repository_path_to
    end

    def to_s
      "R #{repository_path_from} #{repository_path_to}\n"
    end

  end
  
  class StreamFileDeleteAll
    
    def to_s
      "deleteall\n"
    end
  end
  
  # Represents a stream of data bytes in the git stream
  class StreamData
    
    def self.emit_inline_data(data_string)
      "data #{data_string.length}\n#{data_string}\n" 
    end
    
    def self.emit_empty_data
      "data 0\n\n"
    end
  end
  
  #====================
  # Stream Implementation
  #====================

  # This is an initial implementation of git fast-import/export streams
  # It is not complete!
  class Stream
    
    
  end
  
end