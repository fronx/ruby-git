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
    commit.committer = Git::Author.from_parts("Arthur Developer","arthur@example.com",t)
    
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
    commit.author = Git::Author.from_parts("Arthur Developer","arthur@example.com",t)
    commit.committer = Git::Author.from_parts("Jane Developer","jane@example.com",t+10)
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
    commit.author = Git::Author.from_parts("Arthur Developer","arthur@example.com",t)
    commit.committer = Git::Author.from_parts("Jane Developer","jane@example.com",t+10)
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
    commit.author = Git::Author.from_parts("Arthur Developer","arthur@example.com",t)
    commit.committer = Git::Author.from_parts("Jane Developer","jane@example.com",t+10)
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
  
  def test_temp_repo_baseline
    create_temp_repo_with_branched_data do |g|
      assert_equal 'blahblahblah3', g.cat_file('other_branch:test-file1')
      assert_equal 'blahblahblah2', g.cat_file('other_branch:test-file2')
      assert_equal 'blahblahblah1', g.cat_file('new_branch:test-file1')
      assert_equal 'blahblahblah2', g.cat_file('new_branch:test-file2')      
    end
  end

  def test_add_file_to_different_branch
    create_temp_repo_with_branched_data do |g|

      t = Time.new
      
      # make sure we are on 'new_branch'
      g.branch('new_branch').checkout

      # import a file into the 'other_branch'
      g.import_stream do |stream|
        stream.commit do |c|
          c.branch = g.branch('other_branch')
          c.committer = Git::Author.from_parts("Jane Developer","jane@example.com",t)
          c.message = "Test adding a single file to a different branch, without switching."
          c.modify_file("test-file1","testtesttesttest5")
          c.ancestor = g.log.object('other_branch').first
        end
      end
      
      assert_equal 'blahblahblah2', g.cat_file('other_branch:test-file2')
      assert_equal 'blahblahblah1', g.cat_file('new_branch:test-file1')
      assert_equal 'blahblahblah2', g.cat_file('new_branch:test-file2')      
      assert_equal "testtesttesttest5", g.cat_file('other_branch:test-file1')
    end
  end
  
  def create_temp_repo_with_branched_data
    in_temp_dir do |path|
      g = Git.clone(@wbare, 'branch_test')
      Dir.chdir('branch_test') do

        # create a basic repo with two branches and some content
        g.branch('new_branch').checkout

        new_file('test-file1', 'blahblahblah1')
        new_file('test-file2', 'blahblahblah2')
        
        g.add(['test-file1', 'test-file2'])
        g.commit("Initial commit.")
        
        g.branch('other_branch').checkout 
        
        new_file('test-file1', 'blahblahblah3')
        g.add(['test-file1'])
        g.commit("Second commit.")

        yield g     
      end
    end
  end
  
end
