#!/usr/bin/env ruby

require File.dirname(__FILE__) + '/../test_helper'

class TestStream < Test::Unit::TestCase
  def setup
    set_file_paths
  end
  
  def test_minimal_commit_stream
    t = Time.now
    
    commit = Git::StreamCommit.new
    commit.branch = "master"
    commit.committer = Git::Author.new("Arthur Developer","arthur@example.com",t)
    
    str = "commit refs/heads/master\n"
    str << "mark #{commit.mark}\n"
    str << "committer Arthur Developer <arthur@example.com> #{t.rfc2822}\n"
    str << "data 0\n"
    str << "\n\n"
    
    assert_equal str, commit.to_s
  end
  
  def test_single_file_add
    t = Time.now
    
    commit = Git::StreamCommit.new
    commit.branch = "master"
    commit.author = Git::Author.new("Arthur Developer","arthur@example.com",t)
    commit.committer = Git::Author.new("Jane Developer","jane@example.com",t+10)
    commit.message = "Adding a single file."
    commit.ancestor = "2e937ac5d5a6e95f4abb9f636273eaa6528f5dae"
    commit.changes << Git::StreamFileModify.new("p/e/added-file.txt","This is the contents of the\nadded file.")
    
    str = "commit refs/heads/master\n"
    str << "mark #{commit.mark}\n"
    str << "author Arthur Developer <arthur@example.com> #{t.rfc2822}\n"
    str << "committer Jane Developer <jane@example.com> #{(t+10).rfc2822}\n"
    str << "data 21\n"
    str << "Adding a single file.\n"
    str << "from 2e937ac5d5a6e95f4abb9f636273eaa6528f5dae\n"
    str << "M 100644 inline p/e/added-file.txt\n"
    str << "data 39\n"
    str << "This is the contents of the\nadded file.\n"
    str << "\n"
    
    assert_equal str, commit.to_s
  end
  
  def test_single_file_add
    t = Time.now
    
    commit = Git::StreamCommit.new
    commit.branch = "master"
    commit.author = Git::Author.new("Arthur Developer","arthur@example.com",t)
    commit.committer = Git::Author.new("Jane Developer","jane@example.com",t+10)
    commit.message = "Adding a single file."
    commit.ancestor = "2e937ac5d5a6e95f4abb9f636273eaa6528f5dae"
    commit.changes << Git::StreamFileModify.new("p/e/added-file.txt","This is the contents of the\nadded file.")
    
    str = "commit refs/heads/master\n"
    str << "mark #{commit.mark}\n"
    str << "author Arthur Developer <arthur@example.com> #{t.rfc2822}\n"
    str << "committer Jane Developer <jane@example.com> #{(t+10).rfc2822}\n"
    str << "data 21\n"
    str << "Adding a single file.\n"
    str << "from 2e937ac5d5a6e95f4abb9f636273eaa6528f5dae\n"
    str << "M 100644 inline p/e/added-file.txt\n"
    str << "data 39\n"
    str << "This is the contents of the\nadded file.\n"
    str << "\n"
    
    assert_equal str, commit.to_s
  end

  def test_multiple_changes
    t = Time.now
    
    commit = Git::StreamCommit.new
    commit.branch = "master"
    commit.author = Git::Author.new("Arthur Developer","arthur@example.com",t)
    commit.committer = Git::Author.new("Jane Developer","jane@example.com",t+10)
    commit.message = "Add/Delete/Rename/Copy/DeleteAll."
    commit.ancestor = "2e937ac5d5a6e95f4abb9f636273eaa6528f5dae"
    commit.changes << Git::StreamFileModify.new("p/e/added-file.txt","This is the contents of the\nadded file.")
    commit.changes << Git::StreamFileDelete.new("del-file.txt")
    commit.changes << Git::StreamFileRename.new("file1.txt","file2.txt")
    commit.changes << Git::StreamFileCopy.new("file2.txt","file3.txt")
    commit.changes << Git::StreamFileDeleteAll.new
    
    str = "commit refs/heads/master\n"
    str << "mark #{commit.mark}\n"
    str << "author Arthur Developer <arthur@example.com> #{t.rfc2822}\n"
    str << "committer Jane Developer <jane@example.com> #{(t+10).rfc2822}\n"
    str << "data 33\n"
    str << "Add/Delete/Rename/Copy/DeleteAll.\n"
    str << "from 2e937ac5d5a6e95f4abb9f636273eaa6528f5dae\n"
    str << "M 100644 inline p/e/added-file.txt\n"
    str << "data 39\n"
    str << "This is the contents of the\nadded file.\n"
    str << "D del-file.txt\n"
    str << "R file1.txt file2.txt\n"
    str << "C file2.txt file3.txt\n"
    str << "deleteall\n"
    str << "\n"
    
    assert_equal str, commit.to_s
  end
  
end
